import "package:flutter/material.dart";

/// Shared renderer for displaying tags in tables
///
/// Used by both link and document tables to display tags consistently.
class TagsRenderer {
  static Widget build(List<String> tags, ThemeData theme) {
    if (tags.isEmpty) {
      return const Text("-", style: TextStyle(color: Colors.grey));
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

