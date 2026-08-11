import "dart:collection";

import "package:database/features.dart";
import "package:signals/signals.dart";

sealed class ViewerSelection {
  const ViewerSelection();
}

final class ExplicitViewerSelection extends ViewerSelection {
  const ExplicitViewerSelection(this.keys);

  final Set<ViewerItemKey> keys;
}

final class AllMatchingViewerSelection extends ViewerSelection {
  const AllMatchingViewerSelection({
    required this.query,
    required this.totalCount,
    this.excluded = const <ViewerItemKey>{},
  });

  final ViewerQuery query;
  final int totalCount;
  final Set<ViewerItemKey> excluded;
}

final class ViewerSelectionTarget {
  ViewerSelectionTarget({
    required this.selection,
    bool Function()? isCurrent,
  }) : _isCurrent = isCurrent;

  final ViewerSelection selection;
  final bool Function()? _isCurrent;

  bool get isCurrent => _isCurrent?.call() ?? true;

  int get selectedCount => switch (selection) {
        ExplicitViewerSelection(:final keys) => keys.length,
        AllMatchingViewerSelection(:final totalCount, :final excluded) =>
          _boundedSelectedCount(totalCount, excluded.length),
      };
}

class ViewerSelectionState {
  ViewerSelectionState({this.maxManualKeys = defaultMaxManualKeys}) {
    if (maxManualKeys <= 0) {
      throw ArgumentError.value(
        maxManualKeys,
        "maxManualKeys",
        "must be positive",
      );
    }
  }

  static const int defaultMaxManualKeys = 1000;

  final int maxManualKeys;
  final Signal<ViewerSelection> selection = signal<ViewerSelection>(
    const ExplicitViewerSelection(<ViewerItemKey>{}),
  );

  ViewerQuery? _activeQuery;

  ViewerSelection get value => selection.value;

  int get selectedCount => switch (selection.value) {
        ExplicitViewerSelection(:final keys) => keys.length,
        AllMatchingViewerSelection(:final totalCount, :final excluded) =>
          _boundedSelectedCount(totalCount, excluded.length),
      };

  void synchronizeQuery(ViewerQuery query) {
    final previous = _activeQuery;
    _activeQuery = query;
    if (previous != null && previous != query) clear();
  }

  ViewerSelectionToggleResult toggle(ViewerItemKey key) {
    final current = selection.value;
    final keys = switch (current) {
      ExplicitViewerSelection(:final keys) => keys,
      AllMatchingViewerSelection(:final excluded) => excluded,
    };
    if (!keys.contains(key) && keys.length >= maxManualKeys) {
      return ViewerSelectionToggleResult.limitReached;
    }
    selection.value = switch (current) {
      ExplicitViewerSelection(:final keys) =>
        ExplicitViewerSelection(_toggled(keys, key)),
      AllMatchingViewerSelection(
        :final query,
        :final totalCount,
        :final excluded,
      ) =>
        AllMatchingViewerSelection(
          query: query,
          totalCount: totalCount,
          excluded: _toggled(excluded, key),
        ),
    };
    return ViewerSelectionToggleResult.changed;
  }

  void clear() {
    selection.value = const ExplicitViewerSelection(<ViewerItemKey>{});
  }

  void selectAllMatching(ViewerQuery query, int totalCount) {
    if (totalCount < 0) {
      throw ArgumentError.value(
        totalCount,
        "totalCount",
        "must not be negative",
      );
    }
    _activeQuery = query;
    selection.value = AllMatchingViewerSelection(
      query: query,
      totalCount: totalCount,
    );
  }

  bool isSelected(ViewerItemKey key) => switch (selection.value) {
        ExplicitViewerSelection(:final keys) => keys.contains(key),
        AllMatchingViewerSelection(:final excluded) => !excluded.contains(key),
      };

  void dispose() {
    selection.dispose();
  }
}

enum ViewerSelectionToggleResult { changed, limitReached }

Set<ViewerItemKey> _toggled(Set<ViewerItemKey> source, ViewerItemKey key) {
  final next = Set<ViewerItemKey>.of(source);
  if (!next.add(key)) next.remove(key);
  return UnmodifiableSetView<ViewerItemKey>(next);
}

int _boundedSelectedCount(int totalCount, int excludedCount) {
  final count = totalCount - excludedCount;
  return count < 0 ? 0 : count;
}
