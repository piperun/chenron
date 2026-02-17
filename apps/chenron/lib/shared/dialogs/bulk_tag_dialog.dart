import "dart:async";

import "package:chenron/locator.dart";
import "package:chenron/shared/dialogs/tag_color_picker.dart";
import "package:chenron/utils/validation/tag_validator.dart";
import "package:database/database.dart";
import "package:flutter/material.dart";
import "package:signals/signals.dart";

/// The action the user chose for a given tag.
enum TagAction { none, add, remove }

/// Captures the user's intent from the bulk tag dialog.
class BulkTagResult {
  /// Tag names to add to all target items.
  final List<String> tagsToAdd;

  /// Tag names to remove from all target items.
  final List<String> tagsToRemove;

  const BulkTagResult({
    required this.tagsToAdd,
    required this.tagsToRemove,
  });

  bool get isEmpty => tagsToAdd.isEmpty && tagsToRemove.isEmpty;
}

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

  void _toggleTag(String tagName) {
    final coverage = _tagCoverage[tagName] ?? 0;
    final itemCount = widget.items.length;
    final allHaveIt = itemCount > 0 && coverage == itemCount;

    setState(() {
      if (_tagsToAdd.contains(tagName)) {
        // Add → Neutral (undo the add)
        _tagsToAdd.remove(tagName);
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

  void _removeChip(String tagName) {
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

  String _buildApplyLabel() {
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
                          ? "Manage tags for $itemCount ${itemCount == 1 ? 'item' : 'items'}"
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
                  // Clear any validation error and rebuild the filtered
                  // tag list immediately. The list is capped at 100 entries
                  // so there's no need to debounce the rebuild.
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
                  : _buildTagList(theme, colorScheme, hasItems, itemCount),
            ),

            // Action chips + buttons
            Container(
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
                  if (_hasChanges) ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 80),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                        ..._tagsToAdd.map((tag) {
                          final isNew = !_allTagNames.contains(tag);
                          return InputChip(
                            label: Text(isNew ? "+$tag (new)" : "+$tag"),
                            onDeleted: () => _removeChip(tag),
                            deleteIconColor:
                                colorScheme.onPrimaryContainer,
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
                        ..._tagsToRemove.map((tag) => InputChip(
                              label: Text("-$tag"),
                              onDeleted: () => _removeChip(tag),
                              deleteIconColor:
                                  colorScheme.onErrorContainer,
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
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _hasChanges
                            ? () =>
                                Navigator.of(context).pop(BulkTagResult(
                                  tagsToAdd: _tagsToAdd.toList(),
                                  tagsToRemove: _tagsToRemove.toList(),
                                ))
                            : null,
                        child: Text(_buildApplyLabel()),
                      ),
                    ],
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
        final action = _actionFor(name);
        final coverage = _tagCoverage[name] ?? 0;
        final allHaveIt = hasItems && coverage == itemCount;

        return _TagRow(
          tagName: name,
          action: action,
          tagColor: _tagColors[name],
          coverage: hasItems ? coverage : null,
          itemCount: hasItems ? itemCount : null,
          allHaveIt: allHaveIt,
          onToggle: () => _toggleTag(name),
          onColorChanged: (color) => _handleColorChange(name, color),
        );
      },
    );
  }
}

class _TagRow extends StatelessWidget {
  final String tagName;
  final TagAction action;
  final int? tagColor;
  final int? coverage;
  final int? itemCount;
  final bool allHaveIt;
  final VoidCallback onToggle;
  final ValueChanged<int?> onColorChanged;

  const _TagRow({
    required this.tagName,
    required this.action,
    required this.tagColor,
    required this.coverage,
    required this.itemCount,
    required this.allHaveIt,
    required this.onToggle,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final showCoverage = coverage != null && itemCount != null;

    final (IconData icon, Color iconColor, Color bgColor, Color borderColor) =
        switch (action) {
      TagAction.add => (
          Icons.add_circle,
          colorScheme.primary,
          colorScheme.primaryContainer.withValues(alpha: 0.4),
          colorScheme.primary.withValues(alpha: 0.5),
        ),
      TagAction.remove => (
          Icons.remove_circle,
          colorScheme.error,
          colorScheme.errorContainer.withValues(alpha: 0.4),
          colorScheme.error.withValues(alpha: 0.5),
        ),
      TagAction.none => (
          Icons.check_box_outline_blank,
          colorScheme.outline,
          Colors.transparent,
          theme.dividerColor,
        ),
    };

    final isActive = action != TagAction.none;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            // Color dot — tap to pick a color
            _TagColorDot(
              tagColor: tagColor,
              onColorChanged: onColorChanged,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tagName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: action == TagAction.remove
                      ? colorScheme.error
                      : theme.textTheme.bodyMedium?.color,
                  decoration: action == TagAction.remove
                      ? TextDecoration.lineThrough
                      : null,
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

class _TagColorDot extends StatelessWidget {
  final int? tagColor;
  final ValueChanged<int?> onColorChanged;

  const _TagColorDot({
    required this.tagColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapUp: (details) async {
        final overlay =
            Overlay.of(context).context.findRenderObject()! as RenderBox;
        final anchor = RelativeRect.fromRect(
          details.globalPosition & const Size(1, 1),
          Offset.zero & overlay.size,
        );
        final result = await showTagColorPicker(
          context: context,
          anchor: anchor,
          currentColor: tagColor,
        );
        if (result != null) {
          onColorChanged(result.color);
        }
      },
      child: Icon(
        Icons.sell,
        size: 18,
        color: tagColor != null
            ? Color(tagColor!)
            : theme.colorScheme.outlineVariant,
      ),
    );
  }
}
