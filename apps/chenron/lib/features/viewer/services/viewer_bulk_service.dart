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

class ViewerBulkService {
  ViewerBulkService({
    required ViewerPageRepository repository,
    this.batchSize = 100,
    ViewerDeleteItem? deleteItem,
    ViewerTagItem? tagItem,
    ViewerMetadataRefresh? refreshMetadata,
    ViewerTagColorUpdate? updateTagColor,
  })  : _repository = repository,
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
  final int batchSize;
  final ViewerDeleteItem _deleteItem;
  final ViewerTagItem _tagItem;
  final ViewerMetadataRefresh _refreshMetadata;
  final ViewerTagColorUpdate _updateTagColor;
  int _retainedBatchRowCount = 0;

  int get retainedBatchRowCount => _retainedBatchRowCount;

  Future<ViewerBulkResult> delete(
    ViewerSelection selection, {
    Set<ViewerItemKey> additionalKeys = const <ViewerItemKey>{},
  }) =>
      _run(
        selection,
        additionalKeys: additionalKeys,
        processBatch: (batch) => _processItems(
          batch,
          _deleteItem,
        ),
      );

  Future<ViewerBulkResult> tag(
    ViewerSelection selection, {
    Set<String> tagsToAdd = const <String>{},
    Set<String> tagsToRemove = const <String>{},
    Map<String, int?> colorChanges = const <String, int?>{},
    Set<ViewerItemKey> additionalKeys = const <ViewerItemKey>{},
  }) async {
    var result = const ViewerBulkResult();
    if (tagsToAdd.isNotEmpty || tagsToRemove.isNotEmpty) {
      final additions = Set<String>.unmodifiable(tagsToAdd);
      final removals = Set<String>.unmodifiable(tagsToRemove);
      result = await _run(
        selection,
        additionalKeys: additionalKeys,
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
  }

  Future<ViewerBulkResult> refreshMetadata(
    ViewerSelection selection, {
    Set<ViewerItemKey> additionalKeys = const <ViewerItemKey>{},
  }) =>
      _run(
        selection,
        additionalKeys: additionalKeys,
        processBatch: _refreshMetadataBatch,
      );

  Future<ViewerBulkResult> _run(
    ViewerSelection selection, {
    required Set<ViewerItemKey> additionalKeys,
    required Future<ViewerBulkResult> Function(List<FolderItem> batch)
        processBatch,
  }) async {
    var result = await _runSelection(selection, processBatch);
    final supplementalKeys = switch (selection) {
      ExplicitViewerSelection(:final keys) => additionalKeys.difference(keys),
      AllMatchingViewerSelection() => additionalKeys,
    };
    if (supplementalKeys.isNotEmpty) {
      result += await _runSelection(
        ExplicitViewerSelection(
          Set<ViewerItemKey>.unmodifiable(supplementalKeys),
        ),
        processBatch,
      );
    }
    return result;
  }

  Future<ViewerBulkResult> _runSelection(
    ViewerSelection selection,
    Future<ViewerBulkResult> Function(List<FolderItem> batch) processBatch,
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
    if (onlyKeys?.isEmpty ?? false) return const ViewerBulkResult();

    final lease = await _repository.createSelectionLease(
      query: query,
      onlyKeys: onlyKeys,
      excludedKeys: excludedKeys,
    );
    var result = const ViewerBulkResult();
    try {
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
    } finally {
      _retainedBatchRowCount = 0;
      await _repository.releaseSelectionLease(lease);
    }
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
      succeeded: summary.total - summary.failed,
      failed: summary.failed,
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
