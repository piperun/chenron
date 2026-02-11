import "dart:async";

import "package:flutter/material.dart";

import "package:chenron/features/folder_editor/item_picker/widgets/picker_item_tile.dart";
import "package:chenron/features/folder_editor/item_picker/widgets/picker_search_bar.dart";
import "package:chenron/shared/bottom_sheet/bottom_sheet_scaffold.dart";
import "package:chenron/shared/bottom_sheet/sheet_action_bar.dart";
import "package:chenron/shared/empty_state/empty_state.dart";

/// A generic picker sheet that loads items, lets the user search and select,
/// then returns the selected items.
///
/// Type parameters:
/// - [T] — the raw item type loaded from the database.
/// - [R] — the result type returned when the user confirms selection.
class ItemPickerSheet<T, R> extends StatefulWidget {
  /// Loads available items asynchronously.
  final Future<List<T>> Function() loadItems;

  /// Extracts a unique ID from an item.
  final String Function(T item) itemId;

  /// Extracts a display title from an item.
  final String Function(T item) itemTitle;

  /// Extracts an optional subtitle from an item.
  final String? Function(T item)? itemSubtitle;

  /// Converts selected items into the result list.
  final List<R> Function(List<T> selectedItems) toResults;

  /// Icon and title for the sheet header.
  final IconData headerIcon;
  final String headerTitle;

  /// Icon shown in each item tile.
  final IconData itemIcon;

  /// Hint text for the search bar.
  final String searchHint;

  /// Icon shown when there are no items (not from search).
  final IconData emptyIcon;

  /// Message shown when all items are already in the folder.
  final String emptyMessage;

  /// Message shown when search yields no results.
  final String emptySearchMessage;

  /// Label for the "Create New" button. If null, the button is hidden.
  final String? createNewLabel;
  final VoidCallback? onCreateNew;

  const ItemPickerSheet({
    super.key,
    required this.loadItems,
    required this.itemId,
    required this.itemTitle,
    this.itemSubtitle,
    required this.toResults,
    required this.headerIcon,
    required this.headerTitle,
    required this.itemIcon,
    this.searchHint = "Search...",
    required this.emptyIcon,
    required this.emptyMessage,
    this.emptySearchMessage = "No items match your search",
    this.createNewLabel,
    this.onCreateNew,
  });

  @override
  State<ItemPickerSheet<T, R>> createState() => _ItemPickerSheetState<T, R>();
}

class _ItemPickerSheetState<T, R> extends State<ItemPickerSheet<T, R>> {
  List<T> _allItems = [];
  Map<String, String> _lowercasedTitles = {};
  List<T> _filteredItems = [];
  final Set<String> _selectedIds = {};
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final items = await widget.loadItems();
    if (mounted) {
      setState(() {
        _allItems = items;
        _lowercasedTitles = {
          for (final item in items)
            widget.itemId(item): widget.itemTitle(item).toLowerCase(),
        };
        _filteredItems = items;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems
            .where((item) =>
                (_lowercasedTitles[widget.itemId(item)] ?? "")
                    .contains(_searchQuery))
            .toList();
      }
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _handleAdd() {
    final selected = _allItems
        .where((item) => _selectedIds.contains(widget.itemId(item)))
        .toList();
    Navigator.pop(context, widget.toResults(selected));
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetScaffold(
      headerIcon: widget.headerIcon,
      title: widget.headerTitle,
      onClose: () => Navigator.pop(context),
      bodyBuilder: (scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: PickerSearchBar(
              onChanged: _onSearchChanged,
              hintText: widget.searchHint,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? EmptyState(
                        icon: _searchQuery.isNotEmpty
                            ? Icons.search_off
                            : widget.emptyIcon,
                        message: _searchQuery.isNotEmpty
                            ? widget.emptySearchMessage
                            : widget.emptyMessage,
                        actionLabel: widget.createNewLabel,
                        onAction: widget.onCreateNew,
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final id = widget.itemId(item);
                          return PickerItemTile(
                            title: widget.itemTitle(item),
                            subtitle: widget.itemSubtitle?.call(item),
                            leadingIcon: widget.itemIcon,
                            isSelected: _selectedIds.contains(id),
                            onToggle: () => _toggleSelection(id),
                          );
                        },
                      ),
          ),
        ],
      ),
      actions: SheetActionBar(
        leading: widget.onCreateNew != null
            ? TextButton.icon(
                onPressed: widget.onCreateNew,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Create New"),
              )
            : null,
        trailing: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton.icon(
            onPressed: _selectedIds.isNotEmpty ? _handleAdd : null,
            icon: const Icon(Icons.check, size: 18),
            label: Text("Add (${_selectedIds.length})"),
          ),
        ],
      ),
    );
  }
}
