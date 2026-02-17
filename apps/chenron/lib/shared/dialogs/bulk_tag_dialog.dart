import "dart:async";

import "package:chenron/locator.dart";
import "package:chenron/utils/validation/tag_validator.dart";
import "package:database/database.dart";
import "package:flutter/material.dart";
import "package:signals/signals.dart";

/// Shows a tag editor dialog for adding tags to items.
///
/// When [items] is non-empty, shows per-tag coverage counts ("2/4 already
/// have it") so the user knows which tags are fresh vs. redundant.
/// When [items] is empty, acts as a standalone tag picker/creator.
///
/// Returns a list of selected tag names, or null if cancelled.
Future<List<String>?> showBulkTagDialog({
  required BuildContext context,
  required List<FolderItem> items,
}) async {
  return showDialog<List<String>>(
    context: context,
    builder: (context) => _BulkTagDialog(items: items),
  );
}

class _BulkTagDialog extends StatefulWidget {
  final List<FolderItem> items;

  const _BulkTagDialog({required this.items});

  @override
  State<_BulkTagDialog> createState() => _BulkTagDialogState();
}

class _BulkTagDialogState extends State<_BulkTagDialog> {
  final _searchController = TextEditingController();
  final _selectedTags = <String>{};

  /// All tag names from the database.
  List<String> _allTagNames = [];
  bool _isLoading = true;
  String? _createError;

  /// Tag name → count of selected items that already have it.
  late final Map<String, int> _tagCoverage;

  @override
  void initState() {
    super.initState();
    _tagCoverage = _computeCoverage();
    unawaited(_loadTags());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, int> _computeCoverage() {
    final counts = <String, int>{};
    for (final item in widget.items) {
      for (final tag in item.tags) {
        final name = tag.name;
        counts[name] = (counts[name] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<void> _loadTags() async {
    try {
      final db =
          locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;
      final results = await db.getAllTags();
      if (!mounted) return;
      setState(() {
        _allTagNames = results.map((r) => r.name).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<String> get _filteredTagNames {
    final query = _searchController.text.trim().toLowerCase();
    final names = query.isEmpty
        ? List.of(_allTagNames)
        : _allTagNames
            .where((n) => n.toLowerCase().contains(query))
            .toList();

    // Sort: selected first, then alphabetical
    names.sort((a, b) {
      final aSelected = _selectedTags.contains(a);
      final bSelected = _selectedTags.contains(b);
      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    return names;
  }

  bool get _searchMatchesExisting {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    return _allTagNames.any((n) => n.toLowerCase() == query);
  }

  bool get _searchMatchesSelected {
    final query = _searchController.text.trim().toLowerCase();
    return _selectedTags.contains(query);
  }

  void _handleCreateTag() {
    final name = _searchController.text.trim().toLowerCase();
    final error = TagValidator.validateTag(name);
    if (error != null) {
      setState(() => _createError = error);
      return;
    }
    setState(() {
      _selectedTags.add(name);
      _createError = null;
      _searchController.clear();
    });
  }

  void _toggleTag(String tagName) {
    setState(() {
      if (_selectedTags.contains(tagName)) {
        _selectedTags.remove(tagName);
      } else {
        _selectedTags.add(tagName);
      }
    });
  }

  void _removeSelected(String tagName) {
    setState(() => _selectedTags.remove(tagName));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final itemCount = widget.items.length;
    final hasItems = itemCount > 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.label, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasItems
                          ? "Add tags to $itemCount ${itemCount == 1 ? 'item' : 'items'}"
                          : "Tag editor",
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: "Close",
                  ),
                ],
              ),
            ),

            // Search + create
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search or type new tag...",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  isDense: true,
                  errorText: _createError,
                ),
                onChanged: (_) {
                  if (_createError != null) {
                    setState(() => _createError = null);
                  } else {
                    setState(() {});
                  }
                },
                onSubmitted: (_) {
                  if (!_searchMatchesExisting && !_searchMatchesSelected) {
                    _handleCreateTag();
                  }
                },
              ),
            ),

            // Create new tag button
            ListenableBuilder(
              listenable: _searchController,
              builder: (context, _) {
                final query = _searchController.text.trim().toLowerCase();
                if (query.isEmpty ||
                    _searchMatchesExisting ||
                    _searchMatchesSelected) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: OutlinedButton.icon(
                    onPressed: _handleCreateTag,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('Create "$query"'),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                );
              },
            ),

            // Selected tags chips
            if (_selectedTags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _selectedTags.map((tag) {
                    final isNew = !_allTagNames.contains(tag);
                    return InputChip(
                      label: Text(isNew ? "#$tag (new)" : "#$tag"),
                      onDeleted: () => _removeSelected(tag),
                      deleteIconColor: colorScheme.error,
                      backgroundColor: colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color:
                              colorScheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 12),

            // Tag list
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTagList(theme, colorScheme, hasItems, itemCount),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _selectedTags.isNotEmpty
                        ? () => Navigator.of(context)
                            .pop(_selectedTags.toList())
                        : null,
                    child: Text(
                      _selectedTags.isEmpty
                          ? "Add Tags"
                          : "Add ${_selectedTags.length} ${_selectedTags.length == 1 ? 'Tag' : 'Tags'}",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagList(
    ThemeData theme,
    ColorScheme colorScheme,
    bool hasItems,
    int itemCount,
  ) {
    final tagNames = _filteredTagNames;

    if (tagNames.isEmpty) {
      final query = _searchController.text.trim();
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 48,
              color: theme.textTheme.bodyMedium?.color
                  ?.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              query.isEmpty ? "No tags yet" : 'No tags match "$query"',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color
                    ?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: tagNames.length,
      itemBuilder: (context, index) {
        final name = tagNames[index];
        final isSelected = _selectedTags.contains(name);
        final coverage = _tagCoverage[name] ?? 0;
        final allHaveIt = hasItems && coverage == itemCount;

        return _TagRow(
          tagName: name,
          isSelected: isSelected,
          coverage: hasItems ? coverage : null,
          itemCount: hasItems ? itemCount : null,
          allHaveIt: allHaveIt,
          onToggle: () => _toggleTag(name),
        );
      },
    );
  }
}

class _TagRow extends StatelessWidget {
  final String tagName;
  final bool isSelected;
  final int? coverage;
  final int? itemCount;
  final bool allHaveIt;
  final VoidCallback onToggle;

  const _TagRow({
    required this.tagName,
    required this.isSelected,
    required this.coverage,
    required this.itemCount,
    required this.allHaveIt,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final showCoverage = coverage != null && itemCount != null;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.5)
                : theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color: isSelected ? colorScheme.primary : colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tagName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: allHaveIt && !isSelected
                      ? theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.5)
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
            if (showCoverage)
              Text(
                allHaveIt
                    ? "all have it"
                    : "$coverage/$itemCount already",
                style: TextStyle(
                  fontSize: 12,
                  color: allHaveIt
                      ? colorScheme.outline
                      : colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
