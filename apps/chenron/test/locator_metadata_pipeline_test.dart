import "package:cache_manager/cache_manager.dart";
import "package:chenron/locator.dart";
import "package:chenron/services/metadata/metadata_fetch_client.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await locator.reset();
  });

  tearDown(() async {
    await locator.reset();
  });

  test("locator owns and disposes one metadata pipeline", () async {
    locatorSetup();

    final client = locator.get<MetadataFetchClient>();
    expect(locator.get<MetadataFetchClient>(), same(client));
    expect(locator.get<DomainCircuitBreaker>(), isA<DomainCircuitBreaker>());
    final service = locator.get<MetadataService>();

    await locator.reset();

    final disposedServiceResult = await service.forceFetch(
      "https://media.example/item/1",
    );
    expect(disposedServiceResult.outcome, MetadataRefreshOutcome.skipped);

    final closedClientResult = await client.fetch(
      "https://media.example/item/1",
    );
    expect(
      closedClientResult,
      isA<MetadataFetchFailed>().having(
        (result) => result.kind,
        "kind",
        MetadataFailureKind.transport,
      ),
    );
  });
}
