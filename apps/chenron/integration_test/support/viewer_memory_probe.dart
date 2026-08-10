import "dart:io";

import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:flutter/painting.dart";

class ViewerMemorySnapshot {
  const ViewerMemorySnapshot({
    required this.label,
    required this.currentRssBytes,
    required this.imageCacheBytes,
    required this.imageCacheEntries,
    required this.liveImages,
    required this.retainedViewerRows,
    required this.viewerSubscriptions,
  });

  final String label;
  final int currentRssBytes;
  final int imageCacheBytes;
  final int imageCacheEntries;
  final int liveImages;
  final int retainedViewerRows;
  final int viewerSubscriptions;

  Map<String, Object> toJson() => <String, Object>{
        "label": label,
        "currentRssBytes": currentRssBytes,
        "imageCacheBytes": imageCacheBytes,
        "imageCacheEntries": imageCacheEntries,
        "liveImages": liveImages,
        "retainedViewerRows": retainedViewerRows,
        "viewerSubscriptions": viewerSubscriptions,
      };
}

ViewerMemorySnapshot captureViewerMemory(
  String label,
  ViewerRetentionSnapshot retention,
) {
  final cache = PaintingBinding.instance.imageCache;
  return ViewerMemorySnapshot(
    label: label,
    currentRssBytes: ProcessInfo.currentRss,
    imageCacheBytes: cache.currentSizeBytes,
    imageCacheEntries: cache.currentSize,
    liveImages: cache.liveImageCount,
    retainedViewerRows: retention.retainedRows,
    viewerSubscriptions: retention.activeSubscriptions,
  );
}
