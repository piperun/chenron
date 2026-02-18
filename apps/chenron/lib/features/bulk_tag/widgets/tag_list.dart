import "package:chenron/features/bulk_tag/models/bulk_tag_result.dart";
import "package:chenron/features/bulk_tag/widgets/tag_row.dart";
import "package:flutter/material.dart";

class BulkTagList extends StatelessWidget {
  final List<String> tagNames;
  final String searchQuery;
  final bool hasItems;
  final int itemCount;
  final Map<String, int> tagCoverage;
  final Map<String, int?> tagColors;
  final TagAction Function(String) actionFor;
  final ValueChanged<String> onToggle;
  final void Function(String, int?) onColorChanged;

  const BulkTagList({
    super.key,
    required this.tagNames,
    required this.searchQuery,
    required this.hasItems,
    required this.itemCount,
    required this.tagCoverage,
    required this.tagColors,
    required this.actionFor,
    required this.onToggle,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (tagNames.isEmpty) {
      return _BulkTagEmptyState(searchQuery: searchQuery);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: tagNames.length,
      itemBuilder: (context, index) {
        final name = tagNames[index];
        final action = actionFor(name);
        final coverage = tagCoverage[name] ?? 0;
        final allHaveIt = hasItems && coverage == itemCount;

        return TagRow(
          tagName: name,
          action: action,
          tagColor: tagColors[name],
          coverage: hasItems ? coverage : null,
          itemCount: hasItems ? itemCount : null,
          allHaveIt: allHaveIt,
          onToggle: () => onToggle(name),
          onColorChanged: (color) => onColorChanged(name, color),
        );
      },
    );
  }
}

class _BulkTagEmptyState extends StatelessWidget {
  final String searchQuery;

  const _BulkTagEmptyState({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sell_outlined,
            size: 48,
            color: theme.textTheme.bodyMedium?.color
                ?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? "No tags yet"
                : 'No tags match "$searchQuery"',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color
                  ?.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
