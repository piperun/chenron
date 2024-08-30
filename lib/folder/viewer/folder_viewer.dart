import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder/read.dart';
import 'package:chenron/folder/components/tag_chips.dart';
import 'package:chenron/folder/viewer/folder_detail_view.dart';
import 'package:chenron/folder/components/folder_layouts/grid.dart';
import 'package:chenron/folder/components/folder_layouts/list.dart';
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

  void _onFolderToggle(String folderId) {
    setState(() {
      if (_selectedFolders.contains(folderId)) {
        _selectedFolders.remove(folderId);
      } else {
        _selectedFolders.add(folderId);
      }
    });
  }

  void _onFolderTap(BuildContext context, FolderWithTags folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderDetailView(folderId: folder.folder.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context, listen: false);
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
            child: StreamBuilder<List<FolderWithTags>>(
              stream: database.watchAllFoldersWithTags(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final folders = snapshot.data ?? [];
                final filteredFolders = folders.where((folderWithTags) {
                  final lowerQuery = _searchQuery.toLowerCase();
                  return folderWithTags.folder.title
                          .toLowerCase()
                          .contains(lowerQuery) ||
                      (folderWithTags.tag?.name
                              .toLowerCase()
                              .contains(lowerQuery) ??
                          false);
                }).toList();

                Widget folderWidget;
                if (_isGridView) {
                  folderWidget = GridLayout<FolderWithTags>(
                    items: filteredFolders,
                    isItemSelected: (folder) =>
                        _selectedFolders.contains(folder.folder.id),
                    onItemToggle: (folder) => _onFolderToggle(folder.folder.id),
                    onTap: (folder) => _onFolderTap(context, folder),
                    itemBuilder: (folder) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(folder.folder.title),
                        if (folder.tag != null)
                          // TODO: this will be changed later on to probably use flutter's own InputChip.
                          Chips(
                            tags: [folder.tag!.name],
                            onTagTap: (tag) {/* Handle tag tap */},
                          ),
                      ],
                    ),
                  );
                } else {
                  folderWidget = ListLayout<FolderWithTags>(
                    items: filteredFolders,
                    isItemSelected: (folder) =>
                        _selectedFolders.contains(folder.folder.id),
                    onItemToggle: (folder) => _onFolderToggle(folder.folder.id),
                    onTap: (folder) => _onFolderTap(context, folder),
                    itemBuilder: (folder) => Row(
                      children: [
                        Expanded(child: Text(folder.folder.title)),
                        if (folder.tag != null)
                          Chips(
                            tags: [folder.tag!.name],
                            onTagTap: (tag) {/* Handle tag tap */},
                          ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      children: filteredFolders
                          .where((f) => f.tag != null)
                          .map((f) => Chip(label: Text(f.tag!.name)))
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
