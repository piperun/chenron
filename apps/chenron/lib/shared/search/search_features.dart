import "package:chenron/shared/patterns/include_options.dart";

/// Available search features that can be enabled
enum SearchFeature {
  /// Debounce search input to reduce excessive filtering/queries
  debounce,

  /// Store and retrieve search history
  history,

  /// Show search suggestions from database
  suggestions,

  /// Enable navigation to search results
  navigation,
}

/// Convenience typedef for search feature options
///
/// Example usage:
/// ```dart
/// // Enable only debouncing
/// const SearchFeatures({SearchFeature.debounce})
///
/// // Enable multiple features
/// const SearchFeatures({
///   SearchFeature.debounce,
///   SearchFeature.history,
/// })
/// ```
typedef SearchFeatures = IncludeOptions<SearchFeature>;
