import "dart:async";

import "package:flutter/material.dart";
import "package:database/database.dart";
import "package:database/main.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/locator.dart";
import "package:chenron/features/dashboard/widgets/overview_cards.dart";
import "package:chenron/features/dashboard/widgets/growth_trend_chart.dart";
import "package:chenron/features/dashboard/widgets/activity_timeline_chart.dart";
import "package:chenron/features/dashboard/widgets/tag_distribution_chart.dart";
import "package:chenron/features/dashboard/widgets/folder_composition_chart.dart";
import "package:chenron/features/dashboard/widgets/recent_activity_list.dart";
import "package:chenron/features/dashboard/widgets/time_range_selector.dart";

class DashBoard extends StatefulWidget {
  final double padding;
  const DashBoard({super.key, required this.padding});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final AppDatabase _db =
      locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;

  TimeRange _timeRange = TimeRange.month;

  // Data
  Statistic? _latestStats;
  List<Statistic> _history = [];
  List<DailyActivityCount> _dailyCounts = [];
  List<TagCount> _tagCounts = [];
  List<FolderItemCount> _folderCounts = [];

  // Activity stream
  StreamSubscription<List<EnrichedActivityEvent>>? _activitySubscription;
  List<EnrichedActivityEvent> _recentActivity = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadData());
    _activitySubscription = _db.watchRecentActivityWithNames().listen((events) {
      if (mounted) {
        setState(() => _recentActivity = events);
      }
    });
  }

  @override
  void dispose() {
    unawaited(_activitySubscription?.cancel());
    super.dispose();
  }

  Future<void> _loadData() async {
    final startDate = _timeRange.startDate;
    final endDate = DateTime.now();

    final latestStats = await _db.getLatestStatistics();
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
      setState(() {
        _latestStats = latestStats;
        _history = history;
        _dailyCounts = dailyCounts;
        _tagCounts = tagCounts;
        _folderCounts = folderCounts;
        _isLoading = false;
      });
    }
  }

  void _onTimeRangeChanged(TimeRange range) {
    setState(() {
      _timeRange = range;
      _isLoading = true;
    });
    unawaited(_loadData());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(widget.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OverviewCards(
              totalLinks: _latestStats?.totalLinks ?? 0,
              totalDocuments: _latestStats?.totalDocuments ?? 0,
              totalFolders: _latestStats?.totalFolders ?? 0,
              totalTags: _latestStats?.totalTags ?? 0,
            ),
            const SizedBox(height: 16),
            GrowthTrendChart(
              history: _history,
              timeRange: _timeRange,
              onTimeRangeChanged: _onTimeRangeChanged,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ActivityTimelineChart(
                    dailyCounts: _dailyCounts,
                    timeRange: _timeRange,
                    onTimeRangeChanged: _onTimeRangeChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TagDistributionChart(tagCounts: _tagCounts),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FolderCompositionChart(folderCounts: _folderCounts),
            const SizedBox(height: 16),
            RecentActivityList(events: _recentActivity),
          ],
        ),
      ),
    );
  }
}
