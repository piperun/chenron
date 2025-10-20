import "package:chenron/models/item.dart";
import "package:chenron/shared/patterns/include_options.dart";
import "package:chenron/shared/search/search_features.dart";
import "package:chenron/shared/search/search_controller.dart";
import "package:chenron/shared/search/search_feature_manager.dart";

/// Unified search filter that handles features and filtering logic
///
/// This class is the single source of truth for search functionality:
/// - Manages search features (debounce, history, etc.)
/// - Contains filtering logic (by query, tags, type)
/// - Manages search controller
///
/// Usage:
/// ```dart
/// final filter = SearchFilter(
///   features: const SearchFeatures({SearchFeature.debounce}),
/// );
/// filter.setup();
///
/// // In UI
/// LocalSearchBar(filter: filter)
///
/// // In filtering
/// final filtered = filter.filterItems(
///   items: items,
///   query: filter.query,
///   types: selectedTypes,
/// );
///
/// // Cleanup
/// filter.dispose();
/// ```
class SearchFilter {
  final SearchBarController _controller;
  final SearchFeatureManager _featureManager;

  SearchFilter({
    IncludeOptions<SearchFeature> features = const IncludeOptions.empty(),
    Duration debounceDuration = const Duration(milliseconds: 300),
    String? historyKey,
    int maxHistoryItems = 10,
  })  : _controller = SearchBarController(),
        _featureManager = SearchFeatureManager(
          features: features,
          debounceDuration: debounceDuration,
          historyKey: historyKey,
          maxHistoryItems: maxHistoryItems,
        );

  /// The controller for UI binding (TextField, etc.)
  SearchBarController get controller => _controller;

  /// Current query value (reactive signal)
  String get query => _controller.query.value;

  /// Check if a specific feature is enabled
  bool hasFeature(SearchFeature feature) => _featureManager.has(feature);

  /// Setup features (call in initState)
  void setup() {
    _featureManager.setup(_controller);
  }

  /// Cleanup (call in dispose)
  void dispose() {
    _featureManager.dispose(_controller);
    _controller.dispose();
  }

  /// Filter items by search query, type, and tags
  ///
  /// This is the core filtering logic extracted from FilterableItemDisplay.
  List<FolderItem> filterItems({
    required List<FolderItem> items,
    String? query,
    Set<FolderItemType>? types,
    Set<String>? includedTags,
    Set<String>? excludedTags,
  }) {
    var filtered = List<FolderItem>.from(items);

    // Type filter
    if (types != null && types.isNotEmpty) {
      filtered = filtered.where((item) => types.contains(item.type)).toList();
    }

    // Tag filters (inclusive - must have at least one of these tags)
    if (includedTags != null && includedTags.isNotEmpty) {
      filtered = filtered.where((item) {
        final names = item.tags.map((t) => t.name.toLowerCase()).toSet();
        final lowerTags = includedTags.map((t) => t.toLowerCase()).toSet();
        return names.any(lowerTags.contains);
      }).toList();
    }

    // Tag filters (exclusive - must not have any of these tags)
    if (excludedTags != null && excludedTags.isNotEmpty) {
      filtered = filtered.where((item) {
        final names = item.tags.map((t) => t.name.toLowerCase()).toSet();
        final lowerTags = excludedTags.map((t) => t.toLowerCase()).toSet();
        return !names.any(lowerTags.contains);
      }).toList();
    }

    // Search by query
    final searchQuery = query ?? this.query;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        // Search in path/content
        if (item.path is StringContent) {
          final pathStr = (item.path as StringContent).value.toLowerCase();
          if (pathStr.contains(q)) return true;
        }
        // Search in tags
        if (item.tags.any((t) => t.name.toLowerCase().contains(q))) {
          return true;
        }
        return false;
      }).toList();
    }

    return filtered;
  }

  /// Sort items (separated from filtering for clarity)
  ///
  /// Note: Sorting is kept separate because it's typically handled
  /// by the UI layer (ItemToolbar) rather than the filter itself.
  List<FolderItem> sortItems({
    required List<FolderItem> items,
    required SortMode sortMode,
  }) {
    final sorted = List<FolderItem>.from(items);

    sorted.sort((a, b) {
      switch (sortMode) {
        case SortMode.nameAsc:
          return _getItemName(a).compareTo(_getItemName(b));
        case SortMode.nameDesc:
          return _getItemName(b).compareTo(_getItemName(a));
        case SortMode.dateAsc:
          // TODO: Implement date sorting when createdAt is available
          return 0;
        case SortMode.dateDesc:
          // TODO: Implement date sorting when createdAt is available
          return 0;
      }
    });

    return sorted;
  }

  String _getItemName(FolderItem item) {
    if (item.path is StringContent) {
      return (item.path as StringContent).value;
    }
    return "";
  }

  /// Convenience method that filters AND sorts in one call
  List<FolderItem> filterAndSort({
    required List<FolderItem> items,
    String? query,
    Set<FolderItemType>? types,
    Set<String>? includedTags,
    Set<String>? excludedTags,
    required SortMode sortMode,
  }) {
    final filtered = filterItems(
      items: items,
      query: query,
      types: types,
      includedTags: includedTags,
      excludedTags: excludedTags,
    );

    return sortItems(items: filtered, sortMode: sortMode);
  }
}

/// Sort modes for items
enum SortMode {
  nameAsc,
  nameDesc,
  dateAsc,
  dateDesc,
}
