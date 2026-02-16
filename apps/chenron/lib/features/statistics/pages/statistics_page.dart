import "dart:async";

import "package:app_logger/app_logger.dart";
import "package:flutter/material.dart";
import "package:database/database.dart";
import "package:database/main.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/locator.dart";
import "package:chenron/features/statistics/widgets/overview_cards.dart";
import "package:chenron/features/statistics/widgets/growth_trend_chart.dart";
import "package:chenron/features/statistics/widgets/activity_timeline_chart.dart";
import "package:chenron/features/statistics/widgets/tag_distribution_chart.dart";
import "package:chenron/features/statistics/widgets/folder_composition_chart.dart";
import "package:chenron/features/statistics/widgets/recent_activity_list.dart";
import "package:chenron/features/statistics/widgets/time_range_selector.dart";

class StatisticsPage extends StatefulWidget {
  final double padding;
  const StatisticsPage({super.key, required this.padding});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final AppDatabase _db =
      locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;

  final _timeRange = signal(TimeRange.month);
  final _currentCounts = signal<ItemCounts?>(null);
  final _history = signal<List<Statistic>>([]);
  final _dailyCounts = signal<List<DailyActivityCount>>([]);
  final _tagCounts = signal<List<TagCount>>([]);
  final _folderCounts = signal<List<FolderItemCount>>([]);
  final _recentActivity = signal<List<EnrichedActivityEvent>>([]);
  final _isLoading = signal(true);

  StreamSubscription<List<EnrichedActivityEvent>>? _activitySubscription;

  @override
  void initState() {
    super.initState();
    unawaited(_loadData());
    _activitySubscription = _db.watchRecentActivityWithNames().listen(
      (events) {
        if (mounted) {
          _recentActivity.value = events;
        }
      },
      onError: (Object error) {
        loggerGlobal.warning(
            "Statistics", "Activity stream error: $error");
      },
    );
  }

  @override
  void dispose() {
    unawaited(_activitySubscription?.cancel());
    _timeRange.dispose();
    _currentCounts.dispose();
    _history.dispose();
    _dailyCounts.dispose();
    _tagCounts.dispose();
    _folderCounts.dispose();
    _recentActivity.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final startDate = _timeRange.value.startDate;
    final endDate = DateTime.now();

    final latestStats = await _db.getCurrentCounts();
    final history = await _db.getStatisticsHistory(
      startDate: startDate,
      endDate: endDate,
    );
    final dailyCounts = await _db.getDailyActivityCounts(
      startDate: startDate ?? DateTime(2000),
      endDate: endDate,
    );
    final tagCounts = await _db.getTagDistribution();
    final folderCounts = await _db.getFolderComposition();

    if (mounted) {
      _currentCounts.value = latestStats;
      _history.value = history;
      _dailyCounts.value = dailyCounts;
      _tagCounts.value = tagCounts;
      _folderCounts.value = folderCounts;
      _isLoading.value = false;
    }
  }

  void _onTimeRangeChanged(TimeRange range) {
    _timeRange.value = range;
    _isLoading.value = true;
    unawaited(_loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      if (_isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(widget.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OverviewCards(
                totalLinks: _currentCounts.value?.links ?? 0,
                totalDocuments: _currentCounts.value?.documents ?? 0,
                totalFolders: _currentCounts.value?.folders ?? 0,
                totalTags: _currentCounts.value?.tags ?? 0,
              ),
              const SizedBox(height: 16),
              GrowthTrendChart(
                history: _history.value,
                timeRange: _timeRange.value,
                onTimeRangeChanged: _onTimeRangeChanged,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ActivityTimelineChart(
                      dailyCounts: _dailyCounts.value,
                      timeRange: _timeRange.value,
                      onTimeRangeChanged: _onTimeRangeChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TagDistributionChart(tagCounts: _tagCounts.value),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FolderCompositionChart(folderCounts: _folderCounts.value),
              const SizedBox(height: 16),
              RecentActivityList(events: _recentActivity.value),
            ],
          ),
        ),
      );
    });
  }
}
