import "dart:async";

import "package:flutter/material.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/locator.dart";
import "package:chenron/features/statistics/state/statistics_loader.dart";
import "package:chenron/features/statistics/widgets/overview_cards.dart";
import "package:chenron/features/statistics/widgets/growth_trend_chart.dart";
import "package:chenron/features/statistics/widgets/activity_timeline_chart.dart";
import "package:chenron/features/statistics/widgets/tag_distribution_chart.dart";
import "package:chenron/features/statistics/widgets/folder_composition_chart.dart";
import "package:chenron/features/statistics/widgets/recent_activity_list.dart";
import "package:chenron/features/statistics/widgets/time_range_selector.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";
import "package:chenron/utils/safe_async.dart";

class StatisticsPage extends StatefulWidget {
  final double padding;
  const StatisticsPage({super.key, required this.padding});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final AppDatabase _db =
      locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase;

  final _timeRange = signal(TimeRange.month);
  final _recentActivity = signal<List<EnrichedActivityEvent>>([]);

  late final StatisticsLoader _loader = StatisticsLoader(
    _db,
    onError: (error) {
      if (mounted) showErrorSnackBar(context, error);
    },
  );

  StreamSubscription<List<EnrichedActivityEvent>>? _activitySubscription;

  @override
  void initState() {
    super.initState();
    unawaited(_loader.loadAll(_timeRange.value));
    _activitySubscription = safeWatch<List<EnrichedActivityEvent>>(
      _db.watchRecentActivityWithNames(),
      tag: "StatisticsPage",
      onData: (events) {
        if (mounted) _recentActivity.value = events;
      },
    );
  }

  @override
  void dispose() {
    unawaited(_activitySubscription?.cancel());
    _timeRange.dispose();
    _recentActivity.dispose();
    _loader.dispose();
    super.dispose();
  }

  void _onTimeRangeChanged(TimeRange range) {
    _timeRange.value = range;
    // Deliberately do NOT flip the loading flag back to true here. The
    // flag's only purpose is the first-paint spinner; resetting it on
    // every range tap would blank the whole page for ~200ms and re-mount
    // every chart. reloadForRange repopulates the two range-dependent
    // signals atomically when the new query completes, so the user sees
    // a smooth in-place swap of chart data instead of a full-page
    // flicker. The three range-independent results (counts, tags,
    // folders) are left untouched — they do not vary with the range.
    unawaited(_loader.reloadForRange(range));
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(builder: (context) {
      if (_loader.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final counts = _loader.currentCounts.value;
      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(widget.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OverviewCards(
                totalLinks: counts?.links ?? 0,
                totalDocuments: counts?.documents ?? 0,
                totalFolders: counts?.folders ?? 0,
                totalTags: counts?.tags ?? 0,
              ),
              const SizedBox(height: 16),
              GrowthTrendChart(
                history: _loader.history.value,
                timeRange: _timeRange.value,
                onTimeRangeChanged: _onTimeRangeChanged,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ActivityTimelineChart(
                      dailyCounts: _loader.dailyCounts.value,
                      timeRange: _timeRange.value,
                      onTimeRangeChanged: _onTimeRangeChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TagDistributionChart(
                      tagCounts: _loader.tagCounts.value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FolderCompositionChart(folderCounts: _loader.folderCounts.value),
              const SizedBox(height: 16),
              RecentActivityList(events: _recentActivity.value),
            ],
          ),
        ),
      );
    });
  }
}
