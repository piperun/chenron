import "package:flutter/material.dart";

/// Shared table cell that displays a list of tags.
///
/// Used by both link and document tables to render tags consistently.
class TableTagsCell extends StatelessWidget {
  final List<String> tags;
  final ThemeData theme;

  const TableTagsCell({
    super.key,
    required this.tags,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return Text("-",
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant));
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "#$tag",
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        );
      }).toList(),
    );
  }
}
