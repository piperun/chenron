import "package:flutter/material.dart";

class FolderForm extends StatefulWidget {
  final Function addItem;

  const FolderForm({super.key, required this.addItem});

  @override
  State<FolderForm> createState() => _FolderFormState();
}

class _FolderFormState extends State<FolderForm> {
  bool folderLayout = true;
  final TextEditingController _searchController = TextEditingController();
  List<String> allFolders =
      List.generate(20, (index) => "Folder $index"); // Example data
  List<String> filteredFolders = [];
  Set<String> selectedFolders = <String>{};

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
                    labelText: "Search Folders",
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
                {"type": "Folder", "data": selectedFolders.join(", ")});
            setState(() {
              selectedFolders.clear();
              _searchController.clear();
              filteredFolders = allFolders;
            });
          },
          child: const Text("Add Selected Folders"),
        ),
        const Divider(),
        Flexible(
            child: folderLayout
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filteredFolders.length,
                      itemBuilder: (context, index) {
                        final folder = filteredFolders[index];
                        return GestureDetector(
                          onTap: () => _toggleFolderSelection(folder),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedFolders.contains(folder)
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(child: Text(folder)),
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: ListView.builder(
                      itemCount: filteredFolders.length,
                      itemBuilder: (context, index) {
                        final folder = filteredFolders[index];
                        return ListTile(
                          title: Text(folder),
                          onTap: () => _toggleFolderSelection(folder),
                          selected: selectedFolders.contains(folder),
                        );
                      },
                    ),
                  )),
      ],
    );
  }
}
