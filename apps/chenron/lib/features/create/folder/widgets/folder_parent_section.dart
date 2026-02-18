import "dart:async";
import "package:database/main.dart";
import "package:flutter/material.dart";
import "package:database/database.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/section_card/section_card.dart";

import "package:signals/signals_flutter.dart";

class FolderParentSection extends StatefulWidget {
  final List<Folder> selectedFolders;
  final ValueChanged<List<Folder>> onFoldersChanged;
  final String? currentFolderId;

  const FolderParentSection({
    super.key,
    required this.selectedFolders,
    required this.onFoldersChanged,
    this.currentFolderId,
  });

  @override
  State<FolderParentSection> createState() => _FolderParentSectionState();
}

class _FolderParentSectionState extends State<FolderParentSection> {
  final AppDatabase _db =
      locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;

  Future<void> _showFolderSelectionDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => _FolderSelectionDialog(
        db: _db,
        selectedFolders: widget.selectedFolders,
        onSelect: widget.onFoldersChanged,
        currentFolderId: widget.currentFolderId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardSection(
      sectionIcon: const Icon(Icons.folder),
      title: Text(
        "Parent Folders",
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      description: Text(
        "Add this folder to existing folders (optional)",
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...widget.selectedFolders.map((folder) => Chip(
                  label: Text(folder.title),
                  onDeleted: () {
                    final updated =
                        List<Folder>.from(widget.selectedFolders)
                          ..remove(folder);
                    widget.onFoldersChanged(updated);
                  },
                  deleteIconColor: theme.colorScheme.error,
                )),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text("Add Folder"),
              onPressed: _showFolderSelectionDialog,
            ),
          ],
        ),
      ],
    );
  }
}

class _FolderSelectionDialog extends StatefulWidget {
  final AppDatabase db;
  final List<Folder> selectedFolders;
  final void Function(List<Folder>) onSelect;
  final String? currentFolderId;

  const _FolderSelectionDialog({
    required this.db,
    required this.selectedFolders,
    required this.onSelect,
    this.currentFolderId,
  });

  @override
  State<_FolderSelectionDialog> createState() => _FolderSelectionDialogState();
}

class _FolderSelectionDialogState extends State<_FolderSelectionDialog> {
  late Set<Folder> _selectedFolders;
  String _searchQuery = "";
  List<Folder> _allFolders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedFolders = Set.from(widget.selectedFolders);
    unawaited(_loadFolders());
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

  List<Folder> get _filteredFolders => _allFolders.where((f) {
        // Exclude current folder from selection
        if (widget.currentFolderId != null && f.id == widget.currentFolderId) {
          return false;
        }
        return f.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text("Select Parent Folders"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search folders...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredFolders.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  _searchQuery.isEmpty
                      ? "No folders available"
                      : "No folders found matching '$_searchQuery'",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredFolders.length,
                  itemBuilder: (context, index) {
                    final folder = _filteredFolders[index];
                    final isSelected = _selectedFolders.contains(folder);
                    return CheckboxListTile(
                      title: Text(folder.title),
                      subtitle: folder.description.isNotEmpty
                          ? Text(
                              folder.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      value: isSelected,
                      onChanged: (selected) {
                        setState(() {
                          if (selected!) {
                            _selectedFolders.add(folder);
                          } else {
                            _selectedFolders.remove(folder);
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
