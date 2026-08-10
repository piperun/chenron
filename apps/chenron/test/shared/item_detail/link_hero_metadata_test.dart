import "package:cache_manager/cache_manager.dart";
import "package:chenron/components/favicon_display/favicon.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/item_detail/components/link_hero.dart";
import "package:chenron/shared/item_detail/components/metadata_refresh_status.dart";
import "package:chenron/shared/item_detail/item_detail_data.dart";
import "package:chenron/shared/utils/time_formatter.dart";
import "package:database/models/item.dart" show FolderItemType;
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

const _url = "https://media.example/post/1";

void main() {
  late _MemoryPersistence persistence;
  late MetadataService service;
  final now = DateTime.utc(2026, 8, 10, 12);

  setUp(() {
    persistence = _MemoryPersistence();
    final metadata = Metadata(
      url: _url,
      title: "Saved publisher title",
      description: "Saved publisher description",
      fetchedAt: now,
    );
    persistence.metadata[_url] = metadata;
    service = MetadataService(
      cache: MetadataCache(persistence: persistence),
      failures: FailureTracker(persistence: persistence, now: () => now),
      domainCircuitBreaker: DomainCircuitBreaker(now: () => now),
      fetcher: (_, {previous}) async => const MetadataRejected(
        kind: MetadataFailureKind.blocked,
        reason: "request blocked",
        statusCode: 403,
        elapsed: Duration(milliseconds: 10),
      ),
      now: () => now,
      domainDelay: Duration.zero,
    );
    locator.registerSingleton<MetadataService>(service);
    Favicon.debugPutInCache(_url, Future<String?>.value());
  });

  tearDown(() async {
    service.dispose();
    Favicon.debugClearCache();
    await locator.reset();
  });

  testWidgets("details status renders update, failure, and retry rows", (
    tester,
  ) async {
    final fetchedAt = DateTime.utc(2026, 8, 1, 9, 30);
    final retryAt = DateTime.utc(2026, 8, 10, 12, 2);
    final state = MetadataState.available(
      data: Metadata(url: _url, fetchedAt: fetchedAt),
      freshness: MetadataFreshness.stale,
      refreshPhase: MetadataRefreshPhase.failed,
      lastFailure: MetadataRefreshFailure(
        kind: MetadataFailureKind.blocked,
        reason: "request blocked",
        attemptCount: 1,
        statusCode: 403,
        nextRetryAt: retryAt,
      ),
    );

    await tester.pumpWidget(_host(MetadataRefreshStatus(state: state)));

    expect(find.text("Metadata updated"), findsOneWidget);
    expect(find.text(TimeFormatter.formatFull(fetchedAt)), findsOneWidget);
    expect(find.text("Failed: blocked (HTTP 403)"), findsOneWidget);
    expect(find.text("Retry"), findsOneWidget);
    expect(find.text(TimeFormatter.formatFull(retryAt)), findsOneWidget);
  });

  testWidgets("details with no history omits update and retry rows", (
    tester,
  ) async {
    await tester.pumpWidget(_host(const MetadataRefreshStatus(
      state: MetadataState.unavailable(),
    )));

    expect(find.text("Metadata updated"), findsNothing);
    expect(find.text("Retry"), findsNothing);
    expect(find.text("Not fetched"), findsOneWidget);
    expect(find.text("Up to date"), findsNothing);
  });

  testWidgets("failed manual refresh preserves details and re-enables refresh",
      (
    tester,
  ) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(_host(const LinkHero(
        data: ItemDetailData(
      itemId: "link-1",
      itemType: FolderItemType.link,
      title: _url,
      url: _url,
      domain: "media.example",
    ))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.text("Saved publisher title"), findsOneWidget);
    expect(find.text("Saved publisher description"), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, "Refresh"));
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 10));
      if (find.text("Failed: blocked (HTTP 403)").evaluate().isNotEmpty) break;
    }

    expect(find.text("Saved publisher title"), findsOneWidget);
    expect(find.text("Saved publisher description"), findsOneWidget);
    expect(find.text("Failed: blocked (HTTP 403)"), findsOneWidget);
    final refresh = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, "Refresh"),
    );
    expect(refresh.onPressed, isNotNull);
  });
}

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

final class _MemoryPersistence
    implements MetadataPersistence, MetadataRefreshPersistence {
  final metadata = <String, Metadata>{};
  final refresh = <String, MetadataRefreshRecord>{};

  @override
  Future<void> clearAll() async => metadata.clear();

  @override
  Future<void> clearAllRefreshRecords() async => refresh.clear();

  @override
  Future<int> count() async => metadata.length;

  @override
  Future<Metadata?> get(String url) async => metadata[url];

  @override
  Future<List<Metadata>> getExpiredEntries() async => const [];

  @override
  Future<MetadataRefreshRecord?> getRefreshRecord(String url) async =>
      refresh[url];

  @override
  Future<void> remove(String url) async => metadata.remove(url);

  @override
  Future<void> removeRefreshRecord(String url) async => refresh.remove(url);

  @override
  Future<void> set(Metadata value) async => metadata[value.url] = value;

  @override
  Future<void> setRefreshRecord(MetadataRefreshRecord record) async =>
      refresh[record.url] = record;
}
