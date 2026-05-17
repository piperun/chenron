import "package:flutter/material.dart";
import "package:chenron/components/metadata_factory.dart";

/// Mixin that wakes the host State when metadata for [metadataUrl] is
/// refreshed externally.
///
/// Routes through [MetadataFactory.refreshDispatcher] so each State
/// pays for exactly one subscription against its own URL — refreshing
/// one card no longer wakes every other card in the grid.
mixin MetadataLifecycleMixin<T extends StatefulWidget> on State<T> {
  void Function()? _disposeSubscription;

  /// The URL to track for metadata refreshes.
  String? get metadataUrl;

  /// Called when metadata for [metadataUrl] is refreshed externally.
  /// Subclasses should re-create their future and call setState.
  void onMetadataRefreshed();

  void initMetadataRefreshListener() {
    final url = metadataUrl;
    if (url == null || url.isEmpty) return;
    _disposeSubscription = MetadataFactory.refreshDispatcher.subscribe(
      url,
      onMetadataRefreshed,
    );
  }

  void disposeMetadataRefreshListener() {
    _disposeSubscription?.call();
    _disposeSubscription = null;
  }
}
