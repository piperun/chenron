import "package:cache_manager/src/failure_tracker.dart";
import "package:cache_manager/src/metadata_fetch_result.dart";

/// Whether a request may proceed for the URL's host.
enum DomainRequestDecision { allow, allowHalfOpenProbe, skip }

/// Suppresses repeated requests to a host that is failing or blocking access.
class DomainCircuitBreaker {
  final DateTime Function() _now;
  final int _transientThreshold;
  final Map<String, _DomainCircuitState> _circuits = {};

  DomainCircuitBreaker({
    DateTime Function()? now,
    int transientThreshold = 3,
  })  : _now = now ?? DateTime.now,
        _transientThreshold = transientThreshold;

  /// Decide whether this request may proceed.
  ///
  /// Once an open deadline elapses, the first caller claims the sole half-open
  /// probe. All later callers for the host remain skipped until that probe
  /// records success or failure.
  DomainRequestDecision decisionFor(String url) {
    final state = _circuits[_hostFor(url)];
    final deadline = state?.nextRetryAt;
    if (state == null || deadline == null) {
      return DomainRequestDecision.allow;
    }
    if (_now().isBefore(deadline) || state.halfOpenProbeClaimed) {
      return DomainRequestDecision.skip;
    }

    state.halfOpenProbeClaimed = true;
    return DomainRequestDecision.allowHalfOpenProbe;
  }

  /// Record a host-level failure and open the circuit when warranted.
  void recordFailure(
    String url, {
    required MetadataFailureKind kind,
    Duration? retryAfter,
  }) {
    final host = _hostFor(url);
    final attemptedAt = _now();
    final previous = _circuits[host];
    final count = (previous?.consecutiveFailures ?? 0) + 1;
    final opensImmediately = kind == MetadataFailureKind.blocked ||
        kind == MetadataFailureKind.challenge ||
        kind == MetadataFailureKind.rateLimited ||
        retryAfter != null;
    final transient = kind == MetadataFailureKind.transport ||
        kind == MetadataFailureKind.timeout ||
        kind == MetadataFailureKind.httpStatus;

    if (!opensImmediately && !transient) {
      if (previous?.halfOpenProbeClaimed ?? false) {
        _circuits.remove(host);
      }
      return;
    }

    DateTime? deadline;
    if (opensImmediately || count >= _transientThreshold) {
      final scheduleIndex = (count - 1).clamp(
        0,
        kFailureBackoffMinutes.length - 1,
      );
      final scheduledDelay = Duration(
        minutes: kFailureBackoffMinutes[scheduleIndex],
      );
      final delay = retryAfter != null && retryAfter > scheduledDelay
          ? retryAfter
          : scheduledDelay;
      deadline = attemptedAt.add(delay);
    }

    _circuits[host] = _DomainCircuitState(
      consecutiveFailures: count,
      lastFailureAt: attemptedAt,
      nextRetryAt: deadline,
    );
  }

  /// Close the circuit for the URL's host after a successful probe/request.
  void recordSuccess(String url) {
    _circuits.remove(_hostFor(url));
  }

  /// Return the host circuit's open deadline, if any.
  DateTime? nextRetryAt(String url) => _circuits[_hostFor(url)]?.nextRetryAt;

  /// Remove host state that has not seen a failure for 30 days.
  void cleanup() {
    final now = _now();
    final cutoff = now.subtract(kFailureStaleAge);
    _circuits.removeWhere(
      (_, state) =>
          state.lastFailureAt.isBefore(cutoff) &&
          (state.nextRetryAt == null || !state.nextRetryAt!.isAfter(now)),
    );
  }

  String _hostFor(String url) => Uri.parse(url).host.toLowerCase();
}

class _DomainCircuitState {
  final int consecutiveFailures;
  final DateTime lastFailureAt;
  final DateTime? nextRetryAt;
  bool halfOpenProbeClaimed = false;

  _DomainCircuitState({
    required this.consecutiveFailures,
    required this.lastFailureAt,
    required this.nextRetryAt,
  });
}
