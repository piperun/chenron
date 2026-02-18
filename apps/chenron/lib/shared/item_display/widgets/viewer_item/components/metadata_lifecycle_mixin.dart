import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/components/metadata_factory.dart";

/// Mixin that manages a signal-based metadata refresh listener.
///
/// Watches [MetadataFactory.lastRefreshedUrl] and calls
/// [onMetadataRefreshed] when the tracked URL is refreshed.
mixin MetadataLifecycleMixin<T extends StatefulWidget> on State<T> {
  void Function()? _metadataDisposeEffect;

  /// The URL to track for metadata refreshes.
  String? get metadataUrl;

  /// Called when metadata for [metadataUrl] is refreshed externally.
  /// Subclasses should re-create their future and call setState.
  void onMetadataRefreshed();

  void initMetadataRefreshListener() {
    final url = metadataUrl;
    if (url == null || url.isEmpty) return;
    _metadataDisposeEffect = effect(() {
      final refreshed = MetadataFactory.lastRefreshedUrl.value;
      if (refreshed == url) {
        onMetadataRefreshed();
      }
    });
  }

  void disposeMetadataRefreshListener() {
    _metadataDisposeEffect?.call();
  }
}
