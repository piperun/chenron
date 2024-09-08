import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder/read.dart';
import 'package:chenron/components/folder_form_view.dart';
import 'package:chenron/components/tag_chips.dart';
import 'package:chenron/folder/editor.dart';
import 'package:chenron/folder/viewer/folder_detail_view.dart';
import 'package:chenron/components/folder_layouts/grid.dart';
import 'package:chenron/components/folder_layouts/list.dart';
import 'package:chenron/responsible_design/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FolderViewSlug extends StatefulWidget {
  const FolderViewSlug({super.key});

  @override
  _FolderViewSlugState createState() => _FolderViewSlugState();
}

class _FolderViewSlugState extends State<FolderViewSlug> {
  bool _isGridView = true;
  String _searchQuery = '';
  final Set<String> _selectedFolders = {};
  late final _streamFolders;

  @override
  void initState() {
    super.initState();
    _streamFolders = Provider.of<AppDatabase>(context, listen: false)
        .watchAllFolders(mode: IncludeFolderData.tags);
  }

  void _onFolderToggle(String folderId) {
    setState(() {
      if (_selectedFolders.contains(folderId)) {
        _selectedFolders.remove(folderId);
      } else {
        _selectedFolders.add(folderId);
      }
    });
  }

  void _onFolderTap(BuildContext context, FolderObject folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderDetailView(folderId: folder.folder.id),
      ),
    );
  }

  void _onEditTap(BuildContext context, FolderObject folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderEditor(
          folderId: folder.folder.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Folders'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: Breakpoints.responsiveWidth(context),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search folders or tags...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FolderObject>>(
              stream: _streamFolders,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final folders = snapshot.data ?? [];
                final filteredFolders = folders.where((folder) {
                  final lowerQuery = _searchQuery.toLowerCase();
                  return folder.folder.title
                          .toLowerCase()
                          .contains(lowerQuery) ||
                      (folder.tags?.name.toLowerCase().contains(lowerQuery) ??
                          false);
                }).toList();

                Widget folderWidget;
                if (_isGridView) {
                  folderWidget = GridLayout<FolderObject>(
                    items: filteredFolders,
                    isItemSelected: (folder) =>
                        _selectedFolders.contains(folder.folder.id),
                    onItemToggle: (folder) => _onFolderToggle(folder.folder.id),
                    onTap: (folder) => _onFolderTap(context, folder),
                    itemBuilder: (folder) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(folder.folder.title),
                        if (folder.tags != null)
                          // TODO: this will be changed later on to probably use flutter's own InputChip.
                          Chips(
                            tags: [folder.tags!.name],
                            onTagTap: (tag) {/* Handle tag tap */},
                          ),
                        TextButton.icon(
                            onPressed: () => _onEditTap(context, folder),
                            icon: const Icon(Icons.edit),
                            label: const Text("Edit"))
                      ],
                    ),
                  );
                } else {
                  folderWidget = ListLayout<FolderObject>(
                    items: filteredFolders,
                    isItemSelected: (folder) =>
                        _selectedFolders.contains(folder.folder.id),
                    onItemToggle: (folder) => _onFolderToggle(folder.folder.id),
                    onTap: (folder) => _onFolderTap(context, folder),
                    itemBuilder: (folder) => Row(
                      children: [
                        Expanded(child: Text(folder.folder.title)),
                        if (folder.tags != null)
                          Chips(
                            tags: [folder.tags!.name],
                            onTagTap: (tag) {/* Handle tag tap */},
                          ),
                        TextButton.icon(
                            onPressed: () => _onEditTap(context, folder),
                            icon: const Icon(Icons.edit),
                            label: const Text("Edit"))
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      children: filteredFolders
                          .where((f) => f.tags != null)
                          .map((f) => Chip(label: Text(f.tags!.name)))
                          .toSet()
                          .toList(),
                    ),
                    Expanded(child: folderWidget),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
