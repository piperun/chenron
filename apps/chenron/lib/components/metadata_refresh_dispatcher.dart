/// Routes "metadata for URL X was just refreshed" events from a single
/// publisher ([MetadataFactory.forceFetch]) to per-URL subscribers
/// ([MetadataLifecycleMixin]).
///
/// Previously a single global `Signal<String?>` carried the most recently
/// refreshed URL. Every visible card registered an `effect()` on that
/// signal — so a 100-card grid with 3 metadata-aware sub-widgets per card
/// would wake ~300 effects on every refresh tick, each comparing the
/// signal's value against its own URL and no-op-ing for ~299.
///
/// This dispatcher keeps a `Map<String, Set<VoidCallback>>` keyed by URL.
/// [dispatch] resolves to O(1) lookup + O(K) where K = subscribers for
/// that one URL (typically 1-3), instead of O(total cards × components).
class MetadataRefreshDispatcher {
  final Map<String, Set<void Function()>> _listeners = {};

  /// Subscribe [onRefreshed] to refresh events for [url].
  ///
  /// Returns a dispose function — call it from `dispose()` of the
  /// owning State to detach.
  void Function() subscribe(String url, void Function() onRefreshed) {
    final set = _listeners.putIfAbsent(url, () => <void Function()>{});
    set.add(onRefreshed);
    return () {
      final current = _listeners[url];
      if (current == null) return;
      current.remove(onRefreshed);
      if (current.isEmpty) _listeners.remove(url);
    };
  }

  /// Notify every subscriber registered for [url].
  ///
  /// Safe to call when nobody is subscribed. The callback list is copied
  /// so subscribers can dispose during iteration without invalidating it.
  void dispatch(String url) {
    final set = _listeners[url];
    if (set == null) return;
    for (final cb in List<void Function()>.of(set)) {
      cb();
    }
  }

  /// Number of distinct URLs with at least one live subscriber.
  /// Exposed for tests and diagnostics; the dispatcher prunes empty
  /// entries on unsubscribe so this stays bounded by live UI.
  int get debugTrackedUrlCount => _listeners.length;
}
