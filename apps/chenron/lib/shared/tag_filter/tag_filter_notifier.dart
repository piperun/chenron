import "package:chenron/shared/search/query_parser.dart";
import "package:signals/signals.dart";

class ResolvedTagFilters {
  ResolvedTagFilters({
    required Iterable<String> included,
    required Iterable<String> excluded,
  })  : included = Set<String>.unmodifiable(included),
        excluded = Set<String>.unmodifiable(excluded);

  final Set<String> included;
  final Set<String> excluded;
}

/// State management for tag filters using signals
///
/// This manages the included and excluded tag sets for filtering.
/// Owned by pages (viewer, folder_viewer) to ensure proper lifecycle.
///
/// Example:
/// ```dart
/// final tagState = TagFilterNotifier();
/// tagState.addIncluded('test');
/// tagState.addExcluded('cool');
/// // Later...
/// tagState.dispose();
/// ```
class TagFilterNotifier {
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
  void addIncluded(String tag) => includeMany(<String>[tag]);

  /// Add a tag to the excluded set (and remove from included)
  void addExcluded(String tag) => excludeMany(<String>[tag]);

  /// Add many tags to the included set (and remove them from excluded)
  void includeMany(Iterable<String> tags) {
    _publish(resolveMergedTags(included: tags));
  }

  /// Add many tags to the excluded set (and remove them from included)
  void excludeMany(Iterable<String> tags) {
    _publish(resolveMergedTags(excluded: tags));
  }

  /// Remove a tag from the included set
  void removeIncluded(String tag) => removeIncludedMany(<String>[tag]);

  /// Remove a tag from the excluded set
  void removeExcluded(String tag) => removeExcludedMany(<String>[tag]);

  /// Remove many tags from the included set
  void removeIncludedMany(Iterable<String> tags) {
    _includedTags.value = _withoutTags(_includedTags.value, tags);
  }

  /// Remove many tags from the excluded set
  void removeExcludedMany(Iterable<String> tags) {
    _excludedTags.value = _withoutTags(_excludedTags.value, tags);
  }

  /// Set the included tags (replaces current set)
  void setIncluded(Set<String> tags) {
    final updatedIncluded = _collapseTags(
      tags,
      preferredSpellings: <String>[
        ..._includedTags.value,
        ..._excludedTags.value,
      ],
    );
    final updatedExcluded = _withoutTags(
      _excludedTags.value,
      updatedIncluded,
    );
    batch(() {
      _includedTags.value = updatedIncluded;
      _excludedTags.value = updatedExcluded;
    });
  }

  /// Set the excluded tags (replaces current set)
  void setExcluded(Set<String> tags) {
    final updatedExcluded = _collapseTags(
      tags,
      preferredSpellings: <String>[
        ..._excludedTags.value,
        ..._includedTags.value,
      ],
    );
    final updatedIncluded = _withoutTags(
      _includedTags.value,
      updatedExcluded,
    );
    batch(() {
      _excludedTags.value = updatedExcluded;
      _includedTags.value = updatedIncluded;
    });
  }

  /// Update both tag sets, with included winning logical conflicts.
  void updateTags({
    required Set<String> included,
    required Set<String> excluded,
  }) {
    _publish(_resolveTagMoves(included: included, excluded: excluded));
  }

  /// Resolves additional filters without mutating the persistent tag state.
  ///
  /// Incoming exclusions move matching persistent inclusions, then incoming
  /// inclusions move matching exclusions. Inclusion therefore wins conflicts
  /// within one update, while an existing spelling is retained for a moved
  /// logical tag.
  ResolvedTagFilters resolveMergedTags({
    Iterable<String> included = const <String>[],
    Iterable<String> excluded = const <String>[],
  }) {
    return _resolveTagMoves(
      baseIncluded: _includedTags.value,
      baseExcluded: _excludedTags.value,
      included: included,
      excluded: excluded,
    );
  }

  /// Parse and add tags from a query string
  ///
  /// Extracts #tag (included) and -#tag (excluded) patterns,
  /// adds them to the state, and returns the clean query.
  String parseAndAddFromQuery(String query) {
    final parsed = QueryParser.parseTags(query);
    _publish(
      resolveMergedTags(
        included: parsed.includedTags,
        excluded: parsed.excludedTags,
      ),
    );
    return parsed.cleanQuery;
  }

  ResolvedTagFilters _resolveTagMoves({
    Iterable<String> baseIncluded = const <String>[],
    Iterable<String> baseExcluded = const <String>[],
    required Iterable<String> included,
    required Iterable<String> excluded,
  }) {
    var resolvedIncluded = _collapseTags(baseIncluded);
    var resolvedExcluded = _withoutTags(baseExcluded, resolvedIncluded);
    final includedMoves = _collapseTags(
      included,
      preferredSpellings: <String>[
        ...resolvedIncluded,
        ...resolvedExcluded,
      ],
    );
    final includedIdentities = includedMoves.map(_identity).toSet();
    final excludedMoves = _collapseTags(
      excluded.where(
        (tag) => !includedIdentities.contains(_identity(tag)),
      ),
      preferredSpellings: <String>[
        ...resolvedExcluded,
        ...resolvedIncluded,
      ],
    );

    resolvedIncluded = _withoutTags(resolvedIncluded, excludedMoves);
    resolvedExcluded = _withoutTags(resolvedExcluded, excludedMoves)
      ..addAll(excludedMoves);
    resolvedExcluded = _withoutTags(resolvedExcluded, includedMoves);
    resolvedIncluded = _withoutTags(resolvedIncluded, includedMoves)
      ..addAll(includedMoves);

    return ResolvedTagFilters(
      included: resolvedIncluded,
      excluded: resolvedExcluded,
    );
  }

  void _publish(ResolvedTagFilters resolved) {
    batch(() {
      _includedTags.value = resolved.included;
      _excludedTags.value = resolved.excluded;
    });
  }

  Set<String> _withoutTags(
    Iterable<String> source,
    Iterable<String> removed,
  ) {
    final removedIdentities = removed.map(_identity).toSet();
    return _collapseTags(source)
      ..removeWhere((tag) => removedIdentities.contains(_identity(tag)));
  }

  Set<String> _collapseTags(
    Iterable<String> tags, {
    Iterable<String> preferredSpellings = const <String>[],
  }) {
    final preferredByIdentity = <String, String>{};
    for (final tag in preferredSpellings) {
      preferredByIdentity.putIfAbsent(_identity(tag), () => tag);
    }
    final collapsed = <String>{};
    final seen = <String>{};
    for (final tag in tags) {
      final identity = _identity(tag);
      if (seen.add(identity)) {
        collapsed.add(preferredByIdentity[identity] ?? tag);
      }
    }
    return collapsed;
  }

  String _identity(String tag) => tag.toLowerCase();

  /// Clear all tag filters
  void clear() {
    batch(() {
      _includedTags.value = {};
      _excludedTags.value = {};
    });
  }

  /// Dispose of signals
  void dispose() {
    _includedTags.dispose();
    _excludedTags.dispose();
  }
}
