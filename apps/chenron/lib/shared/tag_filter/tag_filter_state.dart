import 'package:signals/signals.dart';
import 'package:chenron/shared/search/query_parser.dart';

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

  /// Add a tag to the included set
  void addIncluded(String tag) {
    final updated = Set<String>.from(_includedTags.value);
    updated.add(tag);
    // Remove from excluded if present
    final excludedUpdated = Set<String>.from(_excludedTags.value);
    excludedUpdated.remove(tag);
    
    _includedTags.value = updated;
    _excludedTags.value = excludedUpdated;
  }

  /// Add a tag to the excluded set
  void addExcluded(String tag) {
    final updated = Set<String>.from(_excludedTags.value);
    updated.add(tag);
    // Remove from included if present
    final includedUpdated = Set<String>.from(_includedTags.value);
    includedUpdated.remove(tag);
    
    _excludedTags.value = updated;
    _includedTags.value = includedUpdated;
  }

  /// Remove a tag from the included set
  void removeIncluded(String tag) {
    final updated = Set<String>.from(_includedTags.value);
    updated.remove(tag);
    _includedTags.value = updated;
  }

  /// Remove a tag from the excluded set
  void removeExcluded(String tag) {
    final updated = Set<String>.from(_excludedTags.value);
    updated.remove(tag);
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
    print('PARSE TAGS DEBUG: includedTags=${parsed.includedTags}, excludedTags=${parsed.excludedTags}');
    
    // Add parsed tags to state
    if (parsed.includedTags.isNotEmpty || parsed.excludedTags.isNotEmpty) {
      final newIncluded = Set<String>.from(_includedTags.value);
      final newExcluded = Set<String>.from(_excludedTags.value);
      
      newIncluded.addAll(parsed.includedTags);
      newExcluded.addAll(parsed.excludedTags);
      
      print('UPDATING SIGNALS: newIncluded=$newIncluded, newExcluded=$newExcluded');
      _includedTags.value = newIncluded;
      _excludedTags.value = newExcluded;
      print('SIGNALS UPDATED: included=${_includedTags.value}, excluded=${_excludedTags.value}');
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
