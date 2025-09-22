import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:flutter/material.dart";
import "package:chenron/database/database.dart";
import "package:chenron/locator.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:signals/signals_flutter.dart";

class FolderPicker extends StatefulWidget {
  final void Function(List<Folder> selectedFolders) onFoldersSelected;

  const FolderPicker({
    super.key,
    required this.onFoldersSelected,
  });

  @override
  State<FolderPicker> createState() => _FolderPickerState();
}

class _FolderPickerState extends State<FolderPicker> {
  late final AppDatabase _db;
  final Set<Folder> _selectedFolders = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final dbHandler =
        await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
    _db = dbHandler.appDatabase;
    await _loadInitialFolder();
  }

  Future<void> _loadInitialFolder() async {
    try {
      final results = await _db.getAllFolders();
      if (results.isNotEmpty) {
        setState(() {
          final defaultFolder = results.map((r) => r.data).firstWhere(
                (f) => f.title == "default",
                orElse: () => results.first.data,
              );
          _selectedFolders.add(defaultFolder);
          _isLoading = false;
        });
        widget.onFoldersSelected(_selectedFolders.toList());
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showFolderSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => FolderSelectionDialog(
        db: _db,
        selectedFolders: _selectedFolders.toList(),
        onSelect: (folders) {
          setState(() {
            _selectedFolders.clear();
            _selectedFolders.addAll(folders);
          });
          widget.onFoldersSelected(_selectedFolders.toList());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Selected Folders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._selectedFolders.map((folder) => Chip(
                  label: Text(folder.title),
                  onDeleted: _selectedFolders.length > 1
                      ? () {
                          setState(() => _selectedFolders.remove(folder));
                          widget.onFoldersSelected(_selectedFolders.toList());
                        }
                      : null,
                )),
            ActionChip(
              avatar: const Icon(Icons.add),
              label: const Text("Add Folder"),
              onPressed: _showFolderSelectionDialog,
            ),
          ],
        ),
      ],
    );
  }
}

class FolderSelectionDialog extends StatefulWidget {
  final AppDatabase db;
  final List<Folder> selectedFolders;
  final void Function(List<Folder>) onSelect;

  const FolderSelectionDialog({
    super.key,
    required this.db,
    required this.selectedFolders,
    required this.onSelect,
  });

  @override
  State<FolderSelectionDialog> createState() => _FolderSelectionDialogState();
}

class _FolderSelectionDialogState extends State<FolderSelectionDialog> {
  late Set<Folder> _selectedFolders;
  String _searchQuery = "";
  List<Folder> _allFolders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedFolders = Set.from(widget.selectedFolders);
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    try {
      final results = await widget.db.getAllFolders();
      setState(() {
        _allFolders = results.map((r) => r.data).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Folder> get _filteredFolders => _allFolders
      .where((f) => f.title.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Folders"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search folders...",
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredFolders.length,
                  itemBuilder: (context, index) {
                    final folder = _filteredFolders[index];
                    return CheckboxListTile(
                      title: Text(folder.title),
                      value: _selectedFolders.contains(folder),
                      onChanged: (selected) {
                        setState(() {
                          if (selected!) {
                            _selectedFolders.add(folder);
                          } else {
                            if (_selectedFolders.length > 1) {
                              _selectedFolders.remove(folder);
                            }
                          }
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () {
            widget.onSelect(_selectedFolders.toList());
            Navigator.pop(context);
          },
          child: const Text("Done"),
        ),
      ],
    );
  }
}
