import "dart:async";

import "package:chenron/features/bulk_tag/models/bulk_tag_result.dart";
import "package:chenron/features/bulk_tag/widgets/tag_list.dart";
import "package:chenron/locator.dart";
import "package:chenron/utils/validation/tag_validator.dart";
import "package:database/database.dart";
import "package:flutter/material.dart";
import "package:signals/signals.dart";

// Re-export so callers only need one import
export "package:chenron/features/bulk_tag/models/bulk_tag_result.dart";

/// Shows a tag editor dialog for managing tags on items.
///
/// When [items] is non-empty, shows per-tag coverage counts ("2/4 already
/// have it") and supports both adding and removing tags.
/// When [items] is empty, acts as a standalone tag picker/creator.
///
/// Returns a [BulkTagResult] with tags to add and remove, or null if
/// cancelled.
Future<BulkTagResult?> showBulkTagDialog({
  required BuildContext context,
  required List<FolderItem> items,
}) async {
  return showDialog<BulkTagResult>(
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
  final _tagsToAdd = <String>{};
  final _tagsToRemove = <String>{};

  /// All tag names from the database.
  List<String> _allTagNames = [];

  /// Tag name → assigned color (ARGB int), or null if unset.
  final Map<String, int?> _tagColors = {};
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
        _allTagNames = results.map((r) => r.data.name).toList();
        _tagColors.addAll({for (final r in results) r.data.name: r.data.color});
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

    // Sort: tags with actions first, then alphabetical
    names.sort((a, b) {
      final aHasAction =
          _tagsToAdd.contains(a) || _tagsToRemove.contains(a);
      final bHasAction =
          _tagsToAdd.contains(b) || _tagsToRemove.contains(b);
      if (aHasAction && !bHasAction) return -1;
      if (!aHasAction && bHasAction) return 1;
      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    // Cap for performance on large tag sets
    if (names.length > 100) return names.sublist(0, 100);
    return names;
  }

  bool get _searchMatchesExisting {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    return _allTagNames.any((n) => n.toLowerCase() == query);
  }

  bool get _searchMatchesSelected {
    final query = _searchController.text.trim().toLowerCase();
    return _tagsToAdd.contains(query);
  }

  TagAction _actionFor(String tagName) {
    if (_tagsToAdd.contains(tagName)) return TagAction.add;
    if (_tagsToRemove.contains(tagName)) return TagAction.remove;
    return TagAction.none;
  }

  void _handleCreateTag() {
    final name = _searchController.text.trim().toLowerCase();
    final error = TagValidator.validateTag(name);
    if (error != null) {
      setState(() => _createError = error);
      return;
    }
    setState(() {
      _tagsToAdd.add(name);
      _createError = null;
      _searchController.clear();
    });
  }

  void _handleToggleTag(String tagName) {
    final coverage = _tagCoverage[tagName] ?? 0;
    final itemCount = widget.items.length;
    final allHaveIt = itemCount > 0 && coverage == itemCount;

    setState(() {
      if (_tagsToAdd.contains(tagName)) {
        _tagsToAdd.remove(tagName);
        // Add → Remove (if some items have it) or Add → Neutral (if none do)
        if (coverage > 0) {
          _tagsToRemove.add(tagName);
        }
      } else if (_tagsToRemove.contains(tagName)) {
        // Remove → Neutral
        _tagsToRemove.remove(tagName);
      } else {
        // Neutral → Remove (if all have it) or Neutral → Add
        if (allHaveIt) {
          _tagsToRemove.add(tagName);
        } else {
          _tagsToAdd.add(tagName);
        }
      }
    });
  }

  void _handleRemoveChip(String tagName) {
    setState(() {
      _tagsToAdd.remove(tagName);
      _tagsToRemove.remove(tagName);
    });
  }

  Future<void> _handleColorChange(String tagName, int? color) async {
    setState(() => _tagColors[tagName] = color);
    final db = locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;
    await db.updateTagColor(tagName: tagName, color: color);
  }

  bool get _hasChanges => _tagsToAdd.isNotEmpty || _tagsToRemove.isNotEmpty;

  String _applyLabel() {
    final adds = _tagsToAdd.length;
    final removes = _tagsToRemove.length;
    if (adds == 0 && removes == 0) return "Apply";
    final parts = <String>[];
    if (adds > 0) parts.add("+$adds");
    if (removes > 0) parts.add("-$removes");
    return "Apply (${parts.join(", ")})";
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
            _DialogHeader(
              hasItems: hasItems,
              itemCount: itemCount,
              onClose: () => Navigator.of(context).pop(),
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
                  setState(() => _createError = null);
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

            const SizedBox(height: 12),

            // Tag list
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : BulkTagList(
                      tagNames: _filteredTagNames,
                      searchQuery: _searchController.text.trim(),
                      hasItems: hasItems,
                      itemCount: itemCount,
                      tagCoverage: _tagCoverage,
                      tagColors: _tagColors,
                      actionFor: _actionFor,
                      onToggle: _handleToggleTag,
                      onColorChanged: _handleColorChange,
                    ),
            ),

            // Action chips + buttons
            _DialogFooter(
              hasChanges: _hasChanges,
              tagsToAdd: _tagsToAdd,
              tagsToRemove: _tagsToRemove,
              allTagNames: _allTagNames,
              applyLabel: _applyLabel(),
              onRemoveChip: _handleRemoveChip,
              onCancel: () => Navigator.of(context).pop(),
              onApply: () => Navigator.of(context).pop(BulkTagResult(
                tagsToAdd: _tagsToAdd.toList(),
                tagsToRemove: _tagsToRemove.toList(),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final bool hasItems;
  final int itemCount;
  final VoidCallback onClose;

  const _DialogHeader({
    required this.hasItems,
    required this.itemCount,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.sell, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasItems
                  ? "Manage tags for $itemCount ${itemCount == 1 ? 'item' : 'items'}"
                  : "Tag editor",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
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

class _DialogFooter extends StatelessWidget {
  final bool hasChanges;
  final Set<String> tagsToAdd;
  final Set<String> tagsToRemove;
  final List<String> allTagNames;
  final String applyLabel;
  final ValueChanged<String> onRemoveChip;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  const _DialogFooter({
    required this.hasChanges,
    required this.tagsToAdd,
    required this.tagsToRemove,
    required this.allTagNames,
    required this.applyLabel,
    required this.onRemoveChip,
    required this.onCancel,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasChanges) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 80),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...tagsToAdd.map((tag) {
                      final isNew = !allTagNames.contains(tag);
                      return InputChip(
                        label: Text(isNew ? "+$tag (new)" : "+$tag"),
                        onDeleted: () => onRemoveChip(tag),
                        deleteIconColor: colorScheme.onPrimaryContainer,
                        backgroundColor: colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: colorScheme.primary
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    }),
                    ...tagsToRemove.map((tag) => InputChip(
                          label: Text("-$tag"),
                          onDeleted: () => onRemoveChip(tag),
                          deleteIconColor: colorScheme.onErrorContainer,
                          backgroundColor: colorScheme.errorContainer,
                          labelStyle: TextStyle(
                            color: colorScheme.onErrorContainer,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: colorScheme.error
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel,
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: hasChanges ? onApply : null,
                child: Text(applyLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
