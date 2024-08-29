import 'package:chenron/database/database.dart';
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
                  hintText: 'Search folders...',
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
            child: StreamBuilder<List<Folder>>(
              stream: database.select(database.folders).watch(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final folders = snapshot.data ?? [];
                final filteredFolders = folders
                    .where((folder) => folder.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

                if (_isGridView) {
                  return FolderGrid(
                    folders: filteredFolders.map((f) => f.title).toList(),
                    selectedFolders: const [],
                    onFolderToggle: (folder) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FolderDetailView(
                              folderId: folders
                                  .firstWhere((f) => f.title == folder)
                                  .id),
                        ),
                      );
                    },
                  );
                } else {
                  return FolderList(
                    folders: filteredFolders.map((f) => f.title).toList(),
                    selectedFolders: const [],
                    onFolderToggle: (folder) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FolderDetailView(
                              folderId: folders
                                  .firstWhere((f) => f.title == folder)
                                  .id),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
