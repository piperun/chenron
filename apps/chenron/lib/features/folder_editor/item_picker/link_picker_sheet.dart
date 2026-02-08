import "dart:async";

import "package:database/database.dart";
import "package:database/main.dart";
import "package:flutter/material.dart";

import "package:chenron/features/folder_editor/item_picker/item_picker_service.dart";
import "package:chenron/features/folder_editor/item_picker/widgets/picker_item_tile.dart";
import "package:chenron/features/folder_editor/item_picker/widgets/picker_search_bar.dart";
import "package:chenron/locator.dart";
import "package:signals/signals.dart";

class LinkPickerSheet extends StatefulWidget {
  final List<FolderItem> currentFolderItems;
  final VoidCallback? onCreateNew;

  const LinkPickerSheet({
    super.key,
    required this.currentFolderItems,
    this.onCreateNew,
  });

  @override
  State<LinkPickerSheet> createState() => _LinkPickerSheetState();
}

class _LinkPickerSheetState extends State<LinkPickerSheet> {
  late final ItemPickerService _service;
  List<LinkResult> _allLinks = [];
  List<LinkResult> _filteredLinks = [];
  final Set<String> _selectedIds = {};
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    final AppDatabase db =
        locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;
    _service = ItemPickerService(db);
    unawaited(_loadLinks());
  }

  Future<void> _loadLinks() async {
    final List<LinkResult> links = await _service.getAvailableLinks(
      currentFolderItems: widget.currentFolderItems,
    );
    if (mounted) {
      setState(() {
        _allLinks = links;
        _filteredLinks = links;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredLinks = _allLinks;
      } else {
        _filteredLinks = _allLinks
            .where((LinkResult link) =>
                link.data.path.toLowerCase().contains(_searchQuery))
            .toList();
      }
    });
  }

  void _toggleSelection(String linkId) {
    setState(() {
      if (_selectedIds.contains(linkId)) {
        _selectedIds.remove(linkId);
      } else {
        _selectedIds.add(linkId);
      }
    });
  }

  void _handleAdd() {
    final List<FolderItem> items = _allLinks
        .where((LinkResult link) => _selectedIds.contains(link.data.id))
        .map((LinkResult link) =>
            link.data.toFolderItem(null, tags: link.tags))
        .toList();
    Navigator.pop(context, items);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return _SheetContainer(
          child: Column(
            children: <Widget>[
              const _Handle(),
              _Header(onClose: () => Navigator.pop(context)),
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: PickerSearchBar(
                  onChanged: _onSearchChanged,
                  hintText: "Search links by URL...",
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredLinks.isEmpty
                        ? _EmptyState(
                            hasSearch: _searchQuery.isNotEmpty,
                            onCreateNew: widget.onCreateNew,
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _filteredLinks.length,
                            itemBuilder: (BuildContext context, int index) {
                              final LinkResult link = _filteredLinks[index];
                              final String linkId = link.data.id;
                              final String tagLine = link.tags.isNotEmpty
                                  ? link.tags
                                      .map((Tag t) => t.name)
                                      .join(", ")
                                  : "";
                              return PickerItemTile(
                                title: link.data.path,
                                subtitle:
                                    tagLine.isNotEmpty ? tagLine : null,
                                leadingIcon: Icons.link,
                                isSelected: _selectedIds.contains(linkId),
                                onToggle: () => _toggleSelection(linkId),
                              );
                            },
                          ),
              ),
              _Actions(
                selectedCount: _selectedIds.length,
                onCancel: () => Navigator.pop(context),
                onAdd: _selectedIds.isNotEmpty ? _handleAdd : null,
                onCreateNew: widget.onCreateNew,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetContainer extends StatelessWidget {
  final Widget child;

  const _SheetContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;

  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          Icon(Icons.link, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            "Add Existing Links",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: "Close",
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback? onCreateNew;

  const _EmptyState({required this.hasSearch, this.onCreateNew});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            hasSearch ? Icons.search_off : Icons.link_off,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            hasSearch
                ? "No links match your search"
                : "All links are already in this folder",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (onCreateNew != null) ...<Widget>[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onCreateNew,
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Create New Link"),
            ),
          ],
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback? onAdd;
  final VoidCallback? onCreateNew;

  const _Actions({
    required this.selectedCount,
    required this.onCancel,
    this.onAdd,
    this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: <Widget>[
          if (onCreateNew != null)
            TextButton.icon(
              onPressed: onCreateNew,
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Create New"),
            ),
          const Spacer(),
          TextButton(
            onPressed: onCancel,
            child: const Text("Cancel"),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.check, size: 18),
            label: Text("Add ($selectedCount)"),
          ),
        ],
      ),
    );
  }
}
