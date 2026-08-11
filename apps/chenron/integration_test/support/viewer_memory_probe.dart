import "dart:async";
import "dart:convert";
import "dart:developer" as developer;
import "dart:io";
import "dart:isolate";

import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:flutter/foundation.dart";
import "package:flutter/painting.dart";

class ViewerMemorySnapshot {
  const ViewerMemorySnapshot({
    required this.label,
    required this.currentRssBytes,
    required this.processWorkingSetBytes,
    required this.processPrivateBytes,
    required this.dartHeapUsedBytes,
    required this.dartHeapCapacityBytes,
    required this.externalMemoryBytes,
    required this.imageCacheBytes,
    required this.imageCacheEntries,
    required this.liveImages,
    required this.retainedViewerRows,
    required this.viewerSubscriptions,
    required this.cachedViewerPages,
    required this.activeViewerPageLoads,
    required this.queuedViewerPageLoads,
    required this.retainedViewerPageErrors,
    required this.droppedViewerPageRequests,
    required this.activeViewerSummaryLoads,
    required this.queuedViewerSummaryRequests,
    required this.retainedViewerSummaryRequests,
    required this.dirtyViewerSummaryRefresh,
    required this.registeredViewerInvalidationSources,
    required this.dirtyViewerInvalidationSources,
    required this.viewerBulkUpdateDepth,
    required this.viewerSettled,
    required this.metadataCacheSize,
    required this.metadataCacheCapacity,
    required this.metadataSignalCacheSize,
    required this.metadataSignalCacheCapacity,
    required this.metadataDomainThrottleSize,
    required this.metadataInFlightRequests,
    required this.metadataActiveFetches,
    required this.metadataQueuedFetches,
    required this.metadataMaxConcurrentFetches,
    required this.faviconCacheSize,
    required this.faviconCacheCapacity,
  });

  final String label;
  final int currentRssBytes;
  final int processWorkingSetBytes;
  final int? processPrivateBytes;
  final int? dartHeapUsedBytes;
  final int? dartHeapCapacityBytes;
  final int? externalMemoryBytes;
  final int imageCacheBytes;
  final int imageCacheEntries;
  final int liveImages;
  final int retainedViewerRows;
  final int viewerSubscriptions;
  final int cachedViewerPages;
  final int activeViewerPageLoads;
  final int queuedViewerPageLoads;
  final int retainedViewerPageErrors;
  final int droppedViewerPageRequests;
  final int activeViewerSummaryLoads;
  final int queuedViewerSummaryRequests;
  final int retainedViewerSummaryRequests;
  final bool dirtyViewerSummaryRefresh;
  final int registeredViewerInvalidationSources;
  final int dirtyViewerInvalidationSources;
  final int viewerBulkUpdateDepth;
  final bool viewerSettled;
  final int metadataCacheSize;
  final int metadataCacheCapacity;
  final int metadataSignalCacheSize;
  final int metadataSignalCacheCapacity;
  final int metadataDomainThrottleSize;
  final int metadataInFlightRequests;
  final int metadataActiveFetches;
  final int metadataQueuedFetches;
  final int metadataMaxConcurrentFetches;
  final int faviconCacheSize;
  final int faviconCacheCapacity;

  Map<String, Object?> toJson() => <String, Object?>{
        "label": label,
        "currentRssBytes": currentRssBytes,
        "processWorkingSetBytes": processWorkingSetBytes,
        "processPrivateBytes": processPrivateBytes,
        "dartHeapUsedBytes": dartHeapUsedBytes,
        "dartHeapCapacityBytes": dartHeapCapacityBytes,
        "externalMemoryBytes": externalMemoryBytes,
        "imageCacheBytes": imageCacheBytes,
        "imageCacheEntries": imageCacheEntries,
        "liveImages": liveImages,
        "retainedViewerRows": retainedViewerRows,
        "viewerSubscriptions": viewerSubscriptions,
        "cachedViewerPages": cachedViewerPages,
        "activeViewerPageLoads": activeViewerPageLoads,
        "queuedViewerPageLoads": queuedViewerPageLoads,
        "retainedViewerPageErrors": retainedViewerPageErrors,
        "droppedViewerPageRequests": droppedViewerPageRequests,
        "activeViewerSummaryLoads": activeViewerSummaryLoads,
        "queuedViewerSummaryRequests": queuedViewerSummaryRequests,
        "retainedViewerSummaryRequests": retainedViewerSummaryRequests,
        "dirtyViewerSummaryRefresh": dirtyViewerSummaryRefresh,
        "registeredViewerInvalidationSources":
            registeredViewerInvalidationSources,
        "dirtyViewerInvalidationSources": dirtyViewerInvalidationSources,
        "viewerBulkUpdateDepth": viewerBulkUpdateDepth,
        "viewerSettled": viewerSettled,
        "metadataCacheSize": metadataCacheSize,
        "metadataCacheCapacity": metadataCacheCapacity,
        "metadataSignalCacheSize": metadataSignalCacheSize,
        "metadataSignalCacheCapacity": metadataSignalCacheCapacity,
        "metadataDomainThrottleSize": metadataDomainThrottleSize,
        "metadataInFlightRequests": metadataInFlightRequests,
        "metadataActiveFetches": metadataActiveFetches,
        "metadataQueuedFetches": metadataQueuedFetches,
        "metadataMaxConcurrentFetches": metadataMaxConcurrentFetches,
        "faviconCacheSize": faviconCacheSize,
        "faviconCacheCapacity": faviconCacheCapacity,
      };
}

class ViewerRuntimeCacheSnapshot {
  const ViewerRuntimeCacheSnapshot({
    required this.metadataCacheSize,
    required this.metadataCacheCapacity,
    required this.metadataSignalCacheSize,
    required this.metadataSignalCacheCapacity,
    required this.metadataDomainThrottleSize,
    required this.metadataInFlightRequests,
    required this.metadataActiveFetches,
    required this.metadataQueuedFetches,
    required this.metadataMaxConcurrentFetches,
    required this.faviconCacheSize,
    required this.faviconCacheCapacity,
  });

  final int metadataCacheSize;
  final int metadataCacheCapacity;
  final int metadataSignalCacheSize;
  final int metadataSignalCacheCapacity;
  final int metadataDomainThrottleSize;
  final int metadataInFlightRequests;
  final int metadataActiveFetches;
  final int metadataQueuedFetches;
  final int metadataMaxConcurrentFetches;
  final int faviconCacheSize;
  final int faviconCacheCapacity;
}

final class ViewerMemoryProbe {
  ViewerMemoryProbe._(this._socket, this._isolateId) {
    final socket = _socket;
    if (socket != null) {
      _subscription = socket.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );
    }
  }

  final WebSocket? _socket;
  final String? _isolateId;
  final Map<int, Completer<Map<String, Object?>>> _pending = {};
  StreamSubscription<dynamic>? _subscription;
  var _nextRequestId = 0;
  var _closed = false;

  static Future<ViewerMemoryProbe> connect() async {
    final serviceInfo = await developer.Service.getInfo();
    final serviceUri = serviceInfo.serverWebSocketUri;
    final isolateId = developer.Service.getIsolateId(Isolate.current);
    if (serviceUri == null || isolateId == null) {
      if (kProfileMode) {
        throw StateError(
          "The Dart VM service is required in Profile mode "
          "(uri: $serviceUri, isolate: $isolateId).",
        );
      }
      return ViewerMemoryProbe._(null, null);
    }
    final socket = await WebSocket.connect(serviceUri.toString());
    return ViewerMemoryProbe._(socket, isolateId);
  }

  Future<ViewerMemorySnapshot> capture(
    String label,
    ViewerRetentionSnapshot retention,
    ViewerRuntimeCacheSnapshot runtimeCaches,
  ) async {
    Map<String, Object?>? memory;
    final isolateId = _isolateId;
    if (isolateId != null) {
      await _call("getAllocationProfile", <String, Object?>{
        "isolateId": isolateId,
        "gc": true,
      });
      memory = await _call("getMemoryUsage", <String, Object?>{
        "isolateId": isolateId,
      });
    }
    final processMemory = await _captureProcessMemory();
    final cache = PaintingBinding.instance.imageCache;
    return ViewerMemorySnapshot(
      label: label,
      currentRssBytes: ProcessInfo.currentRss,
      processWorkingSetBytes: processMemory.workingSetBytes,
      processPrivateBytes: processMemory.privateBytes,
      dartHeapUsedBytes:
          memory == null ? null : _requiredInt(memory, "heapUsage"),
      dartHeapCapacityBytes:
          memory == null ? null : _requiredInt(memory, "heapCapacity"),
      externalMemoryBytes:
          memory == null ? null : _requiredInt(memory, "externalUsage"),
      imageCacheBytes: cache.currentSizeBytes,
      imageCacheEntries: cache.currentSize,
      liveImages: cache.liveImageCount,
      retainedViewerRows: retention.retainedRows,
      viewerSubscriptions: retention.activeSubscriptions,
      cachedViewerPages: retention.cachedPages,
      activeViewerPageLoads: retention.activePageLoads,
      queuedViewerPageLoads: retention.queuedPageLoads,
      retainedViewerPageErrors: retention.retainedPageErrors,
      droppedViewerPageRequests: retention.droppedPageRequests,
      activeViewerSummaryLoads: retention.activeSummaryLoads,
      queuedViewerSummaryRequests: retention.queuedSummaryRequests,
      retainedViewerSummaryRequests: retention.retainedSummaryRequests,
      dirtyViewerSummaryRefresh: retention.dirtySummaryRefresh,
      registeredViewerInvalidationSources:
          retention.registeredInvalidationSources,
      dirtyViewerInvalidationSources: retention.dirtyInvalidationSources,
      viewerBulkUpdateDepth: retention.bulkUpdateDepth,
      viewerSettled: retention.settled,
      metadataCacheSize: runtimeCaches.metadataCacheSize,
      metadataCacheCapacity: runtimeCaches.metadataCacheCapacity,
      metadataSignalCacheSize: runtimeCaches.metadataSignalCacheSize,
      metadataSignalCacheCapacity: runtimeCaches.metadataSignalCacheCapacity,
      metadataDomainThrottleSize: runtimeCaches.metadataDomainThrottleSize,
      metadataInFlightRequests: runtimeCaches.metadataInFlightRequests,
      metadataActiveFetches: runtimeCaches.metadataActiveFetches,
      metadataQueuedFetches: runtimeCaches.metadataQueuedFetches,
      metadataMaxConcurrentFetches: runtimeCaches.metadataMaxConcurrentFetches,
      faviconCacheSize: runtimeCaches.faviconCacheSize,
      faviconCacheCapacity: runtimeCaches.faviconCacheCapacity,
    );
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _socket?.close();
    await _subscription?.cancel();
    _failPending(StateError("Viewer memory probe closed."));
  }

  Future<Map<String, Object?>> _call(
    String method,
    Map<String, Object?> params,
  ) {
    if (_closed) {
      throw StateError("Viewer memory probe is closed.");
    }
    final id = ++_nextRequestId;
    final completer = Completer<Map<String, Object?>>();
    _pending[id] = completer;
    final socket = _socket;
    if (socket == null) {
      throw StateError("Dart VM service is unavailable.");
    }
    socket.add(jsonEncode(<String, Object?>{
      "jsonrpc": "2.0",
      "id": id,
      "method": method,
      "params": params,
    }));
    return completer.future;
  }

  void _handleMessage(dynamic message) {
    if (message is! String) return;
    final decoded = jsonDecode(message);
    if (decoded is! Map<String, dynamic>) return;
    final id = decoded["id"];
    if (id is! int) return;
    final completer = _pending.remove(id);
    if (completer == null) return;
    final error = decoded["error"];
    if (error != null) {
      completer.completeError(StateError("VM service error: $error"));
      return;
    }
    final result = decoded["result"];
    if (result is! Map<String, dynamic>) {
      completer.completeError(
        StateError("VM service returned no result for request $id."),
      );
      return;
    }
    completer.complete(Map<String, Object?>.from(result));
  }

  void _handleError(Object error, StackTrace stackTrace) {
    _failPending(error, stackTrace);
  }

  void _handleDone() {
    _failPending(StateError("Dart VM service connection closed."));
  }

  void _failPending(Object error, [StackTrace? stackTrace]) {
    final pending = _pending.values.toList(growable: false);
    _pending.clear();
    for (final completer in pending) {
      completer.completeError(error, stackTrace);
    }
  }
}

int _requiredInt(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is num) return value.toInt();
  throw StateError("VM service result is missing numeric $key.");
}

Future<_ProcessMemory> _captureProcessMemory() async {
  if (!Platform.isWindows) {
    return _ProcessMemory(
      workingSetBytes: ProcessInfo.currentRss,
      privateBytes: null,
    );
  }
  final script = r"$process = Get-Process -Id " +
      pid.toString() +
      r" -ErrorAction Stop; [Console]::Out.Write((@{" +
      r"workingSetBytes=[int64]$process.WorkingSet64;" +
      r"privateBytes=[int64]$process.PrivateMemorySize64" +
      r"}|ConvertTo-Json -Compress))";
  final result = await Process.run(
    "powershell.exe",
    <String>[
      "-NoLogo",
      "-NoProfile",
      "-NonInteractive",
      "-Command",
      script,
    ],
  );
  if (result.exitCode != 0) {
    throw StateError(
      "Unable to read Windows process memory counters: ${result.stderr}",
    );
  }
  final decoded = jsonDecode(result.stdout as String);
  if (decoded is! Map<String, dynamic>) {
    throw StateError("Windows process counters returned invalid JSON.");
  }
  return _ProcessMemory(
    workingSetBytes: _requiredInt(decoded, "workingSetBytes"),
    privateBytes: _requiredInt(decoded, "privateBytes"),
  );
}

final class _ProcessMemory {
  const _ProcessMemory({
    required this.workingSetBytes,
    required this.privateBytes,
  });

  final int workingSetBytes;
  final int? privateBytes;
}
