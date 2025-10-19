import "package:flutter/material.dart";
import "package:chenron/shared/search/search_controller.dart";
import "package:chenron/shared/search/search_features.dart";
import "package:chenron/shared/search/search_feature_manager.dart";
import "package:chenron/shared/patterns/include_options.dart";

/// A simple searchbar for local filtering (e.g., filtering items in a list)
///
/// Supports optional features like debouncing and history through [features] parameter.
/// Features are configured using the IncludeOptions pattern, similar to database queries.
///
/// Example:
/// ```dart
/// LocalSearchBar(
///   controller: myController,
///   features: const SearchFeatures({SearchFeature.debounce}),
///   debounceDuration: Duration(milliseconds: 500),
/// )
/// ```
class LocalSearchBar extends StatefulWidget {
  final SearchBarController controller;
  final IncludeOptions<SearchFeature> features;
  final String hintText;

  // Feature-specific configuration (only used if feature is enabled)
  final Duration debounceDuration;
  final String? historyKey;
  final int maxHistoryItems;

  const LocalSearchBar({
    super.key,
    required this.controller,
    this.features = const IncludeOptions.empty(),
    this.hintText = "Search by name, URL, tags...",
    this.debounceDuration = const Duration(milliseconds: 300),
    this.historyKey,
    this.maxHistoryItems = 10,
  });

  @override
  State<LocalSearchBar> createState() => _LocalSearchBarState();
}

class _LocalSearchBarState extends State<LocalSearchBar> {
  late final SearchFeatureManager _featureManager;

  @override
  void initState() {
    super.initState();
    _featureManager = SearchFeatureManager(
      features: widget.features,
      debounceDuration: widget.debounceDuration,
      historyKey: widget.historyKey,
      maxHistoryItems: widget.maxHistoryItems,
    );
    _featureManager.setup(widget.controller);
  }

  @override
  void dispose() {
    _featureManager.dispose(widget.controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHistory = _featureManager.has(SearchFeature.history);

    return Flexible(
      flex: 2,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 250,
          maxWidth: 400,
        ),
        child: TextField(
          controller: widget.controller.textController,
          decoration: InputDecoration(
            hintText: widget.hintText,
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

  void _showHistory() async {
    final history = await _featureManager.loadHistory();
    if (!mounted || history.isEmpty) return;

    // TODO: Implement history UI (modal/dropdown)
    // For now, just a placeholder
  }
}
