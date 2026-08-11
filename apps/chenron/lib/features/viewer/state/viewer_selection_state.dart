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
    Set<ViewerItemKey> additionalKeys = const <ViewerItemKey>{},
    bool Function()? isCurrent,
  })  : additionalKeys = UnmodifiableSetView<ViewerItemKey>(
          Set<ViewerItemKey>.of(additionalKeys),
        ),
        _isCurrent = isCurrent;

  final ViewerSelection selection;
  final Set<ViewerItemKey> additionalKeys;
  final bool Function()? _isCurrent;

  bool get isCurrent => _isCurrent?.call() ?? true;

  int get selectedCount => switch (selection) {
        ExplicitViewerSelection(:final keys) =>
          <ViewerItemKey>{...keys, ...additionalKeys}.length,
        AllMatchingViewerSelection(:final totalCount, :final excluded) =>
          _boundedSelectedCount(totalCount, excluded.length) +
              additionalKeys.length,
      };
}

class ViewerSelectionState {
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

  void toggle(ViewerItemKey key) {
    selection.value = switch (selection.value) {
      ExplicitViewerSelection(:final keys) => ExplicitViewerSelection(
          _toggled(keys, key),
        ),
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

Set<ViewerItemKey> _toggled(Set<ViewerItemKey> source, ViewerItemKey key) {
  final next = Set<ViewerItemKey>.of(source);
  if (!next.add(key)) next.remove(key);
  return UnmodifiableSetView<ViewerItemKey>(next);
}

int _boundedSelectedCount(int totalCount, int excludedCount) {
  final count = totalCount - excludedCount;
  return count < 0 ? 0 : count;
}
