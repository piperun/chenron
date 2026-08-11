import "package:cache_manager/cache_manager.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:chenron/features/viewer/state/viewer_selection_state.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/viewer/item_deletion_service.dart";
import "package:chenron/shared/viewer/item_handler.dart";
import "package:chenron/shared/viewer/item_tagging_service.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:signals/signals.dart";

typedef ViewerDeleteItem = Future<bool> Function(FolderItem item);
typedef ViewerTagItem = Future<bool> Function(
  FolderItem item,
  Set<String> tagsToAdd,
  Set<String> tagsToRemove,
);
typedef ViewerMetadataRefresh = Future<MetadataRefreshResult> Function(
  String url,
);
typedef ViewerTagColorUpdate = Future<void> Function(
  String tagName,
  int? color,
);

class ViewerBulkResult {
  const ViewerBulkResult({
    this.processed = 0,
    this.succeeded = 0,
    this.failed = 0,
  });

  final int processed;
  final int succeeded;
  final int failed;

  ViewerBulkResult operator +(ViewerBulkResult other) => ViewerBulkResult(
        processed: processed + other.processed,
        succeeded: succeeded + other.succeeded,
        failed: failed + other.failed,
      );
}

class ViewerSelectionChangedException implements Exception {
  const ViewerSelectionChangedException({
    required this.expectedCount,
    required this.actualCount,
  });

  final int expectedCount;
  final int actualCount;

  @override
  String toString() => "Selection changed. Select the items again.";
}

class ViewerBulkService {
  ViewerBulkService({
    required ViewerPageRepository repository,
    required ViewerBulkUpdateBoundary bulkUpdateBoundary,
    this.batchSize = 100,
    ViewerDeleteItem? deleteItem,
    ViewerTagItem? tagItem,
    ViewerMetadataRefresh? refreshMetadata,
    ViewerTagColorUpdate? updateTagColor,
  })  : _repository = repository,
        _bulkUpdateBoundary = bulkUpdateBoundary,
        _deleteItem = deleteItem ?? _defaultDeleteItem,
        _tagItem = tagItem ?? _defaultTagItem,
        _refreshMetadata = refreshMetadata ?? _defaultRefreshMetadata,
        _updateTagColor = updateTagColor ?? _defaultUpdateTagColor {
    if (batchSize <= 0 || batchSize > 100) {
      throw ArgumentError.value(
        batchSize,
        "batchSize",
        "must be between 1 and 100",
      );
    }
  }

  final ViewerPageRepository _repository;
  final ViewerBulkUpdateBoundary _bulkUpdateBoundary;
  final int batchSize;
  final ViewerDeleteItem _deleteItem;
  final ViewerTagItem _tagItem;
  final ViewerMetadataRefresh _refreshMetadata;
  final ViewerTagColorUpdate _updateTagColor;
  int _retainedBatchRowCount = 0;

  int get retainedBatchRowCount => _retainedBatchRowCount;

  Future<ViewerBulkResult> delete(
    ViewerSelection selection, {
    int? expectedCount,
  }) =>
      _bulkUpdateBoundary.runBulkUpdate(
        () => _run(
          selection,
          expectedCount: expectedCount,
          processBatch: (batch) => _processItems(
            batch,
            _deleteItem,
          ),
        ),
      );

  Future<ViewerBulkResult> tag(
    ViewerSelection selection, {
    Set<String> tagsToAdd = const <String>{},
    Set<String> tagsToRemove = const <String>{},
    Map<String, int?> colorChanges = const <String, int?>{},
    int? expectedCount,
  }) =>
      _bulkUpdateBoundary.runBulkUpdate(() async {
        var result = const ViewerBulkResult();
        if (tagsToAdd.isNotEmpty || tagsToRemove.isNotEmpty) {
          final additions = Set<String>.unmodifiable(tagsToAdd);
          final removals = Set<String>.unmodifiable(tagsToRemove);
          result = await _run(
            selection,
            expectedCount: expectedCount,
            processBatch: (batch) => _processItems(
              batch,
              (item) => _tagItem(item, additions, removals),
            ),
          );
        }
        for (final entry in colorChanges.entries) {
          await _updateTagColor(entry.key, entry.value);
        }
        return result;
      });

  Future<ViewerBulkResult> refreshMetadata(
    ViewerSelection selection, {
    int? expectedCount,
  }) =>
      _bulkUpdateBoundary.runBulkUpdate(
        () => _run(
          selection,
          expectedCount: expectedCount,
          processBatch: _refreshMetadataBatch,
        ),
      );

  Future<ViewerBulkResult> _run(
    ViewerSelection selection, {
    required int? expectedCount,
    required Future<ViewerBulkResult> Function(List<FolderItem> batch)
        processBatch,
  }) async {
    final leases = <ViewerSelectionLease>[];
    try {
      await _appendLease(leases, selection);

      if (expectedCount != null) {
        final counts = await Future.wait<int>(
          leases.map(_repository.countSelectionLease),
        );
        final actualCount = counts.fold<int>(0, (sum, count) => sum + count);
        if (actualCount != expectedCount) {
          throw ViewerSelectionChangedException(
            expectedCount: expectedCount,
            actualCount: actualCount,
          );
        }
      }

      var result = const ViewerBulkResult();
      for (final lease in leases) {
        result += await _runLease(lease, processBatch);
      }
      return result;
    } finally {
      _retainedBatchRowCount = 0;
      await Future.wait<void>(
        leases.map(_repository.releaseSelectionLease),
      );
    }
  }

  Future<void> _appendLease(
    List<ViewerSelectionLease> leases,
    ViewerSelection selection,
  ) async {
    final (query, onlyKeys, excludedKeys) = switch (selection) {
      ExplicitViewerSelection(:final keys) => (
          const ViewerQuery(),
          keys,
          const <ViewerItemKey>{},
        ),
      AllMatchingViewerSelection(:final query, :final excluded) => (
          query,
          null,
          excluded,
        ),
    };
    if (onlyKeys?.isEmpty ?? false) return;
    leases.add(await _repository.createSelectionLease(
      query: query,
      onlyKeys: onlyKeys,
      excludedKeys: excludedKeys,
    ));
  }

  Future<ViewerBulkResult> _runLease(
    ViewerSelectionLease lease,
    Future<ViewerBulkResult> Function(List<FolderItem> batch) processBatch,
  ) async {
    var result = const ViewerBulkResult();
    while (true) {
      var batch = await _repository.loadSelectionLeaseBatch(
        lease,
        limit: batchSize,
      );
      if (batch.isEmpty) break;
      _retainedBatchRowCount = batch.length;
      try {
        result += await processBatch(batch);
        await _repository.consumeSelectionLeaseBatch(
          lease,
          batch.map((item) => (type: item.type, id: item.id!)),
        );
      } finally {
        batch = const <FolderItem>[];
        _retainedBatchRowCount = 0;
      }
    }
    return result;
  }

  Future<ViewerBulkResult> _processItems(
    List<FolderItem> batch,
    ViewerDeleteItem processItem,
  ) async {
    var succeeded = 0;
    var failed = 0;
    for (final item in batch) {
      try {
        if (await processItem(item)) {
          succeeded++;
        } else {
          failed++;
        }
      } catch (_) {
        failed++;
      }
    }
    return ViewerBulkResult(
      processed: batch.length,
      succeeded: succeeded,
      failed: failed,
    );
  }

  Future<ViewerBulkResult> _refreshMetadataBatch(
    List<FolderItem> batch,
  ) async {
    final urls = batch
        .whereType<LinkItem>()
        .map((item) => item.url)
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
    final summary = await refreshMetadataUrls(
      urls,
      refreshOne: _refreshMetadata,
      maxConcurrent: 3,
    );
    return ViewerBulkResult(
      processed: summary.total,
      succeeded: summary.updated + summary.unchanged,
      failed: summary.rejected + summary.failed + summary.skipped,
    );
  }

  static Future<bool> _defaultDeleteItem(FolderItem item) async =>
      await ItemDeletionService().deleteItems(<FolderItem>[item]) == 1;

  static Future<bool> _defaultTagItem(
    FolderItem item,
    Set<String> tagsToAdd,
    Set<String> tagsToRemove,
  ) async {
    final service = ItemTaggingService();
    if (tagsToAdd.isNotEmpty) {
      final result = await service.addTagToItems(
        <FolderItem>[item],
        tagsToAdd.toList(growable: false),
      );
      if (result.itemCount != 1) return false;
    }
    if (tagsToRemove.isNotEmpty) {
      final result = await service.removeTagFromItems(
        <FolderItem>[item],
        tagsToRemove.toList(growable: false),
      );
      if (result.itemCount != 1) return false;
    }
    return true;
  }

  static Future<MetadataRefreshResult> _defaultRefreshMetadata(
    String url,
  ) =>
      locator.get<MetadataService>().forceFetch(url);

  static Future<void> _defaultUpdateTagColor(
    String tagName,
    int? color,
  ) =>
      locator
          .get<Signal<AppDatabaseLifecycle>>()
          .value
          .appDatabase
          .updateTagColor(tagName: tagName, color: color);
}
