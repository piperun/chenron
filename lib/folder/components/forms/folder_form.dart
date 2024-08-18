import 'package:chenron/folder/components/folder_layouts/grid.dart';
import 'package:chenron/folder/components/folder_layouts/list.dart';
import 'package:chenron/responsible_design/breakpoints.dart';
import 'package:flutter/material.dart';

class FolderForm extends StatefulWidget {
  final Function addItem;

  FolderForm({required this.addItem});

  @override
  _FolderFormState createState() => _FolderFormState();
}

class _FolderFormState extends State<FolderForm> {
  bool folderLayout = true;
  final TextEditingController _searchController = TextEditingController();
  List<String> allFolders =
      List.generate(20, (index) => 'Folder $index'); // Example data
  List<String> filteredFolders = [];
  List<String> selectedFolders = [];

  @override
  void initState() {
    super.initState();
    filteredFolders = allFolders;
  }

  void _filterFolders(String query) {
    setState(() {
      filteredFolders = allFolders
          .where((folder) => folder.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleFolderSelection(String folder) {
    setState(() {
      if (selectedFolders.contains(folder)) {
        selectedFolders.remove(folder);
      } else {
        selectedFolders.add(folder);
      }
    });
  }

  void _toggleView() {
    setState(() {
      folderLayout = !folderLayout;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Folders',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _filterFolders,
                ),
              ),
              IconButton(
                onPressed: _toggleView,
                icon:
                    Icon(folderLayout ? Icons.list : Icons.grid_view_outlined),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.addItem(
                {'type': 'Folder', 'data': selectedFolders.join(', ')});
            setState(() {
              selectedFolders.clear();
              _searchController.clear();
              filteredFolders = allFolders;
            });
          },
          child: Text('Add Selected Folders'),
        ),
        const Divider(),
        Flexible(
            child: folderLayout
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: FolderGrid(
                      folders: filteredFolders,
                      selectedFolders: selectedFolders,
                      onFolderToggle: _toggleFolderSelection,
                    ),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: FolderList(
                      folders: filteredFolders,
                      selectedFolders: selectedFolders,
                      onFolderToggle: _toggleFolderSelection,
                    ),
                  )),
      ],
    );
  }
}
