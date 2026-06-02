import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:database/features.dart";
import "package:chenron/features/statistics/widgets/activity_timeline_chart.dart";
import "package:chenron/features/statistics/widgets/folder_composition_chart.dart";
import "package:chenron/features/statistics/widgets/aggregation_counter.dart";
import "package:chenron/features/statistics/widgets/time_range_selector.dart";

/// These tests assert the per-input memoization of each chart's
/// aggregation: the work runs once in `initState` and again only when the
/// input list identity changes (`didUpdateWidget`), never on a bare
/// repaint. The aggregation counters live in the State and are bumped in
/// the grouping methods, which run independently of whether fl_chart's
/// `BarChart` is mounted — so empty input lists are used deliberately to
/// keep fl_chart out of the widget tree (its `BarChart` leaves undisposed
/// gesture recognizers that the leak tracker would otherwise flag).

/// Host that rebuilds [builder]'s widget on demand so a test can force
/// repaints without changing the data the child was given.
class _Rebuildable extends StatefulWidget {
  const _Rebuildable({super.key, required this.builder});
  final Widget Function() builder;

  @override
  State<_Rebuildable> createState() => _RebuildableState();
}

class _RebuildableState extends State<_Rebuildable> {
  void rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(body: widget.builder()),
      );
}

void main() {
  group("FolderCompositionChart aggregation memoization", () {
    testWidgets("aggregates once across repaints with the same input",
        (tester) async {
      final hostKey = GlobalKey<_RebuildableState>();
      final folders = <FolderItemCount>[];
      await tester.pumpWidget(_Rebuildable(
        key: hostKey,
        builder: () => FolderCompositionChart(folderCounts: folders),
      ));
      await tester.pumpAndSettle();

      final state = tester.state<State<FolderCompositionChart>>(
        find.byType(FolderCompositionChart),
      ) as AggregationCounter;
      expect(state.aggregationCount, 1);

      // Forced repaints with the identical list must not recompute.
      for (var i = 0; i < 3; i++) {
        hostKey.currentState!.rebuild();
        await tester.pump();
      }
      expect(state.aggregationCount, 1);
    });

    testWidgets("re-aggregates when the input list changes", (tester) async {
      final hostKey = GlobalKey<_RebuildableState>();
      var current = <FolderItemCount>[];
      await tester.pumpWidget(_Rebuildable(
        key: hostKey,
        builder: () => FolderCompositionChart(folderCounts: current),
      ));
      await tester.pumpAndSettle();

      final state = tester.state<State<FolderCompositionChart>>(
        find.byType(FolderCompositionChart),
      ) as AggregationCounter;
      expect(state.aggregationCount, 1);

      // New list instance -> exactly one recompute.
      current = <FolderItemCount>[];
      hostKey.currentState!.rebuild();
      await tester.pump();
      expect(state.aggregationCount, 2);

      // Same (new) instance again -> still no further recompute.
      hostKey.currentState!.rebuild();
      await tester.pump();
      expect(state.aggregationCount, 2);
    });
  });

  group("ActivityTimelineChart grouping memoization", () {
    testWidgets("groups once across repaints with the same input",
        (tester) async {
      final hostKey = GlobalKey<_RebuildableState>();
      final daily = <DailyActivityCount>[];
      await tester.pumpWidget(_Rebuildable(
        key: hostKey,
        builder: () => ActivityTimelineChart(
          dailyCounts: daily,
          timeRange: TimeRange.month,
          onTimeRangeChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      final state = tester.state<State<ActivityTimelineChart>>(
        find.byType(ActivityTimelineChart),
      ) as AggregationCounter;
      expect(state.aggregationCount, 1);

      for (var i = 0; i < 3; i++) {
        hostKey.currentState!.rebuild();
        await tester.pump();
      }
      expect(state.aggregationCount, 1);
    });

    testWidgets("re-groups when the input list changes", (tester) async {
      final hostKey = GlobalKey<_RebuildableState>();
      var current = <DailyActivityCount>[];
      await tester.pumpWidget(_Rebuildable(
        key: hostKey,
        builder: () => ActivityTimelineChart(
          dailyCounts: current,
          timeRange: TimeRange.month,
          onTimeRangeChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      final state = tester.state<State<ActivityTimelineChart>>(
        find.byType(ActivityTimelineChart),
      ) as AggregationCounter;
      expect(state.aggregationCount, 1);

      current = <DailyActivityCount>[];
      hostKey.currentState!.rebuild();
      await tester.pump();
      expect(state.aggregationCount, 2);

      hostKey.currentState!.rebuild();
      await tester.pump();
      expect(state.aggregationCount, 2);
    });
  });
}
