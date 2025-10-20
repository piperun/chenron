import "package:signals/signals.dart";
import "package:chenron/shared/search/query_parser.dart";

/// State management for tag filters using signals
///
/// This manages the included and excluded tag sets for filtering.
/// Owned by pages (viewer, folder_viewer) to ensure proper lifecycle.
///
/// Example:
/// ```dart
/// final tagState = TagFilterState();
/// tagState.addIncluded('test');
/// tagState.addExcluded('cool');
/// // Later...
/// tagState.dispose();
/// ```
class TagFilterState {
  final Signal<Set<String>> _includedTags = signal({});
  final Signal<Set<String>> _excludedTags = signal({});

  /// Reactive signal for included tags
  Signal<Set<String>> get includedTags => _includedTags;

  /// Reactive signal for excluded tags
  Signal<Set<String>> get excludedTags => _excludedTags;

  /// Current included tag names
  Set<String> get includedTagNames => _includedTags.value;

  /// Current excluded tag names
  Set<String> get excludedTagNames => _excludedTags.value;

  /// Add a tag to the included set (and remove from excluded)
  void addIncluded(String tag) {
    final updatedIncluded = Set<String>.from(_includedTags.value)..add(tag);
    final updatedExcluded = Set<String>.from(_excludedTags.value)..remove(tag);
    _includedTags.value = updatedIncluded;
    _excludedTags.value = updatedExcluded;
  }

  /// Add a tag to the excluded set (and remove from included)
  void addExcluded(String tag) {
    final updatedExcluded = Set<String>.from(_excludedTags.value)..add(tag);
    final updatedIncluded = Set<String>.from(_includedTags.value)..remove(tag);
    _excludedTags.value = updatedExcluded;
    _includedTags.value = updatedIncluded;
  }

  /// Add many tags to the included set (and remove them from excluded)
  void includeMany(Iterable<String> tags) {
    final updatedIncluded = Set<String>.from(_includedTags.value)..addAll(tags);
    final updatedExcluded = Set<String>.from(_excludedTags.value)..removeAll(tags);
    _includedTags.value = updatedIncluded;
    _excludedTags.value = updatedExcluded;
  }

  /// Add many tags to the excluded set (and remove them from included)
  void excludeMany(Iterable<String> tags) {
    final updatedExcluded = Set<String>.from(_excludedTags.value)..addAll(tags);
    final updatedIncluded = Set<String>.from(_includedTags.value)..removeAll(tags);
    _excludedTags.value = updatedExcluded;
    _includedTags.value = updatedIncluded;
  }

  /// Remove a tag from the included set
  void removeIncluded(String tag) {
    final updated = Set<String>.from(_includedTags.value)..remove(tag);
    _includedTags.value = updated;
  }

  /// Remove a tag from the excluded set
  void removeExcluded(String tag) {
    final updated = Set<String>.from(_excludedTags.value)..remove(tag);
    _excludedTags.value = updated;
  }

  /// Remove many tags from the included set
  void removeIncludedMany(Iterable<String> tags) {
    final updated = Set<String>.from(_includedTags.value)..removeAll(tags);
    _includedTags.value = updated;
  }

  /// Remove many tags from the excluded set
  void removeExcludedMany(Iterable<String> tags) {
    final updated = Set<String>.from(_excludedTags.value)..removeAll(tags);
    _excludedTags.value = updated;
  }

  /// Set the included tags (replaces current set)
  void setIncluded(Set<String> tags) {
    _includedTags.value = Set.from(tags);
  }

  /// Set the excluded tags (replaces current set)
  void setExcluded(Set<String> tags) {
    _excludedTags.value = Set.from(tags);
  }

  /// Update both included and excluded tags at once
  void updateTags({
    required Set<String> included,
    required Set<String> excluded,
  }) {
    _includedTags.value = Set.from(included);
    _excludedTags.value = Set.from(excluded);
  }

  /// Parse and add tags from a query string
  ///
  /// Extracts #tag (included) and -#tag (excluded) patterns,
  /// adds them to the state, and returns the clean query.
  String parseAndAddFromQuery(String query) {
    final parsed = QueryParser.parseTags(query);
    // Add parsed tags to state; ensure conflicts are resolved
    if (parsed.includedTags.isNotEmpty) {
      includeMany(parsed.includedTags);
    }
    if (parsed.excludedTags.isNotEmpty) {
      excludeMany(parsed.excludedTags);
    }
    return parsed.cleanQuery;
  }

  /// Clear all tag filters
  void clear() {
    _includedTags.value = {};
    _excludedTags.value = {};
  }

  /// Dispose of signals
  void dispose() {
    _includedTags.dispose();
    _excludedTags.dispose();
  }
}
