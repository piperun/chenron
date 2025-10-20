import "package:flutter/material.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/shared/search/search_features.dart";

/// A simple searchbar for local filtering (e.g., filtering items in a list)
///
/// Now uses SearchFilter which manages features and filtering logic.
///
/// Example:
/// ```dart
/// final filter = SearchFilter(
///   features: const SearchFeatures({SearchFeature.debounce}),
/// );
///
/// LocalSearchBar(filter: filter)
/// ```
class LocalSearchBar extends StatelessWidget {
  final SearchFilter filter;
  final String hintText;

  const LocalSearchBar({
    super.key,
    required this.filter,
    this.hintText = "Search by name, URL, tags...",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHistory = filter.hasFeature(SearchFeature.history);

    return Flexible(
      flex: 2,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 250,
          maxWidth: 400,
        ),
        child: TextField(
          controller: filter.controller.textController,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: hasHistory
                ? IconButton(
                    icon: const Icon(Icons.history, size: 20),
                    onPressed: _showHistory,
                    tooltip: "Search history",
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  void _showHistory() {
    // TODO: Implement history UI (modal/dropdown)
    // For now, just a placeholder
  }
}
