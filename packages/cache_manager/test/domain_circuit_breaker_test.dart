import "package:cache_manager/cache_manager.dart";
import "package:flutter_test/flutter_test.dart";

class MutableClock {
  DateTime now;

  MutableClock(this.now);

  DateTime call() => now;
}

void main() {
  const firstUrl = "https://example.com/post/1";
  const secondUrl = "https://example.com/post/2";
  final initialNow = DateTime.utc(2026, 8, 9, 10);
  late MutableClock clock;
  late DomainCircuitBreaker breaker;

  setUp(() {
    clock = MutableClock(initialNow);
    breaker = DomainCircuitBreaker(now: clock.call);
  });

  test("blocked, challenge, and rate-limited failures open immediately", () {
    for (final kind in const [
      MetadataFailureKind.blocked,
      MetadataFailureKind.challenge,
      MetadataFailureKind.rateLimited,
    ]) {
      final isolated = DomainCircuitBreaker(now: clock.call);

      isolated.recordFailure(firstUrl, kind: kind);

      expect(isolated.decisionFor(firstUrl), DomainRequestDecision.skip);
      expect(
        isolated.nextRetryAt(firstUrl),
        initialNow.add(const Duration(minutes: 2)),
      );
    }
  });

  test("explicit Retry-After opens immediately for a transient failure", () {
    breaker.recordFailure(
      firstUrl,
      kind: MetadataFailureKind.transport,
      retryAfter: const Duration(minutes: 30),
    );

    expect(breaker.decisionFor(firstUrl), DomainRequestDecision.skip);
    expect(
      breaker.nextRetryAt(firstUrl),
      initialNow.add(const Duration(minutes: 30)),
    );
  });

  test("opens only after three transient failures", () {
    breaker.recordFailure(firstUrl, kind: MetadataFailureKind.transport);
    expect(breaker.decisionFor(firstUrl), DomainRequestDecision.allow);

    breaker.recordFailure(firstUrl, kind: MetadataFailureKind.timeout);
    expect(breaker.decisionFor(firstUrl), DomainRequestDecision.allow);

    breaker.recordFailure(firstUrl, kind: MetadataFailureKind.httpStatus);
    expect(breaker.decisionFor(firstUrl), DomainRequestDecision.skip);
    expect(
      breaker.nextRetryAt(firstUrl),
      initialNow.add(const Duration(hours: 1)),
    );
  });

  test("an open circuit skips another URL on the same host", () {
    breaker.recordFailure(firstUrl, kind: MetadataFailureKind.blocked);

    expect(breaker.decisionFor(secondUrl), DomainRequestDecision.skip);
  });

  test("allows exactly one half-open probe after the deadline", () {
    breaker.recordFailure(firstUrl, kind: MetadataFailureKind.blocked);
    clock.now = initialNow.add(const Duration(minutes: 2));

    expect(
      breaker.decisionFor(firstUrl),
      DomainRequestDecision.allowHalfOpenProbe,
    );
    expect(breaker.decisionFor(secondUrl), DomainRequestDecision.skip);
  });

  test("non-domain half-open outcome releases the host", () {
    breaker.recordFailure(firstUrl, kind: MetadataFailureKind.blocked);
    clock.now = initialNow.add(const Duration(minutes: 2));
    expect(
      breaker.decisionFor(firstUrl),
      DomainRequestDecision.allowHalfOpenProbe,
    );

    breaker.recordFailure(
      firstUrl,
      kind: MetadataFailureKind.unsupportedContentType,
    );

    expect(breaker.decisionFor(secondUrl), DomainRequestDecision.allow);
    expect(breaker.nextRetryAt(firstUrl), isNull);
  });

  test("success closes the host circuit", () {
    breaker.recordFailure(firstUrl, kind: MetadataFailureKind.blocked);

    breaker.recordSuccess(secondUrl);

    expect(breaker.decisionFor(firstUrl), DomainRequestDecision.allow);
    expect(breaker.nextRetryAt(firstUrl), isNull);
  });

  test("different hosts remain independent", () {
    breaker.recordFailure(firstUrl, kind: MetadataFailureKind.blocked);

    expect(
      breaker.decisionFor("https://other.example/post"),
      DomainRequestDecision.allow,
    );
  });

  test("non-transient failures do not poison the host", () {
    breaker.recordFailure(
      firstUrl,
      kind: MetadataFailureKind.unsupportedContentType,
    );

    expect(breaker.decisionFor(firstUrl), DomainRequestDecision.allow);
    expect(breaker.nextRetryAt(firstUrl), isNull);
  });

  test("cleanup keeps an aged circuit while Retry-After is active", () {
    breaker.recordFailure(
      firstUrl,
      kind: MetadataFailureKind.rateLimited,
      retryAfter: const Duration(days: 60),
    );
    clock.now = DateTime.utc(2026, 9, 9, 10);

    breaker.cleanup();

    expect(breaker.decisionFor(firstUrl), DomainRequestDecision.skip);
    expect(
      breaker.nextRetryAt(firstUrl),
      DateTime.utc(2026, 10, 8, 10),
    );
  });

  test("cleanup removes inactive circuit state", () {
    breaker.recordFailure(firstUrl, kind: MetadataFailureKind.blocked);
    clock.now = initialNow.add(const Duration(days: 31));

    breaker.cleanup();

    expect(breaker.decisionFor(firstUrl), DomainRequestDecision.allow);
    expect(breaker.nextRetryAt(firstUrl), isNull);
  });
}
