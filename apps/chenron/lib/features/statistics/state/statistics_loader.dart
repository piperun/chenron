import "package:database/database.dart";
import "package:database/features.dart";
import "package:signals/signals.dart";
import "package:chenron/features/statistics/widgets/time_range_selector.dart";

/// Loads and holds the statistics-page data set.
///
/// Splits the five statistics queries by whether they depend on the
/// selected [TimeRange]:
///
/// - **Range-independent** — `getCurrentCounts`, `getTagDistribution`,
///   and `getFolderComposition` take no date arguments, so their result
///   is identical for every range. They are fetched once by [loadAll]
///   and left untouched by [reloadForRange].
/// - **Range-dependent** — `getStatisticsHistory` and
///   `getDailyActivityCounts` are scoped to the range's date window, so
///   only these two are re-fetched when the user switches ranges.
///
/// Switching the range therefore runs two queries instead of five, and
/// the range-independent signals keep their object identity across the
/// switch (no spurious rebuild of the charts that consume them).
class StatisticsLoader {
  StatisticsLoader(this._db, {void Function(Object error)? onError})
      : _onError = onError;

  final AppDatabase _db;
  final void Function(Object error)? _onError;

  // Range-independent results — fetched once by [loadAll].
  final Signal<ItemCounts?> currentCounts = signal<ItemCounts?>(null);
  final Signal<List<TagCount>> tagCounts = signal<List<TagCount>>([]);
  final Signal<List<FolderItemCount>> folderCounts =
      signal<List<FolderItemCount>>([]);

  // Range-dependent results — refreshed by [loadAll] and [reloadForRange].
  final Signal<List<Statistic>> history = signal<List<Statistic>>([]);
  final Signal<List<DailyActivityCount>> dailyCounts =
      signal<List<DailyActivityCount>>([]);

  final Signal<bool> isLoading = signal<bool>(true);

  /// First load: fetches all five queries for [range], then clears the
  /// loading flag so the spinner is replaced by the populated charts.
  ///
  /// The loading flag is cleared regardless of success or failure so a
  /// failed load shows the empty page (with whatever error the [onError]
  /// callback surfaced) rather than an indefinite spinner.
  Future<void> loadAll(TimeRange range) async {
    try {
      final latestStats = await _db.getCurrentCounts();
      final tags = await _db.getTagDistribution();
      final folders = await _db.getFolderComposition();
      final (rangeHistory, rangeDaily) = await _fetchRange(range);

      currentCounts.value = latestStats;
      tagCounts.value = tags;
      folderCounts.value = folders;
      history.value = rangeHistory;
      dailyCounts.value = rangeDaily;
    } catch (e) {
      _onError?.call(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Range switch: re-fetches only the two range-dependent queries.
  ///
  /// Leaves [currentCounts], [tagCounts], and [folderCounts] untouched —
  /// they do not vary with the range, so refetching them would be
  /// redundant work and would needlessly rebuild their charts. Does not
  /// touch [isLoading]: the flag exists only for the first-paint spinner,
  /// and resetting it here would blank the whole page on every range tap.
  Future<void> reloadForRange(TimeRange range) async {
    try {
      final (rangeHistory, rangeDaily) = await _fetchRange(range);
      history.value = rangeHistory;
      dailyCounts.value = rangeDaily;
    } catch (e) {
      _onError?.call(e);
    }
  }

  Future<(List<Statistic>, List<DailyActivityCount>)> _fetchRange(
    TimeRange range,
  ) async {
    final startDate = range.startDate;
    final endDate = DateTime.now();
    final rangeHistory = await _db.getStatisticsHistory(
      startDate: startDate,
      endDate: endDate,
    );
    final rangeDaily = await _db.getDailyActivityCounts(
      startDate: startDate ?? DateTime(2000),
      endDate: endDate,
    );
    return (rangeHistory, rangeDaily);
  }

  void dispose() {
    currentCounts.dispose();
    tagCounts.dispose();
    folderCounts.dispose();
    history.dispose();
    dailyCounts.dispose();
    isLoading.dispose();
  }
}
