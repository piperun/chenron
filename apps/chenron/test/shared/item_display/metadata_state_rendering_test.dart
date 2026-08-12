import "dart:convert";
import "dart:io";

import "package:cache_manager/cache_manager.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/components/item_description.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/components/item_images.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/components/item_title.dart";
import "package:database/models/item.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart";
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:plugin_platform_interface/plugin_platform_interface.dart";
import "package:signals/signals.dart";

const _mediaUrl =
    "https://media.example/index.php?page=post&s=list&tags=sampletag";
const _item = FolderItem.link(url: _mediaUrl);

Metadata _metadata({
  String? title = "Saved title",
  String? description = "Saved description",
  String? imageUrl = "https://images.example/preview.jpg",
}) =>
    Metadata(
      url: _mediaUrl,
      title: title,
      description: description,
      imageUrl: imageUrl,
      fetchedAt: DateTime(2026, 8, 1, 10),
    );

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider(this.path);

  final String path;

  @override
  Future<String?> getApplicationSupportPath() async => path;

  @override
  Future<String?> getTemporaryPath() async => path;
}

void _disposeAfterTest(
  WidgetTester tester,
  Signal<MetadataState> state,
) {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}

void main() {
  tearDown(() async {
    await locator.reset();
  });

  testWidgets("available title stays visible across refresh phases", (
    tester,
  ) async {
    final state = signal<MetadataState>(MetadataState.available(
      data: _metadata(),
      freshness: MetadataFreshness.stale,
      refreshPhase: MetadataRefreshPhase.refreshing,
    ));
    _disposeAfterTest(tester, state);

    await tester.pumpWidget(_host(ItemTitle(
      item: _item,
      url: _mediaUrl,
      metadata: state,
    )));
    expect(find.text("Saved title"), findsOneWidget);

    state.value = MetadataState.available(
      data: _metadata(),
      freshness: MetadataFreshness.stale,
      refreshPhase: MetadataRefreshPhase.failed,
      lastFailure: const MetadataRefreshFailure(
        kind: MetadataFailureKind.blocked,
        reason: "HTTP status 403",
        attemptCount: 1,
        statusCode: 403,
      ),
    );
    await tester.pump();

    expect(find.text("Saved title"), findsOneWidget);
  });

  testWidgets("available description stays visible while refreshing", (
    tester,
  ) async {
    final state = signal<MetadataState>(MetadataState.available(
      data: _metadata(),
      freshness: MetadataFreshness.stale,
      refreshPhase: MetadataRefreshPhase.refreshing,
    ));
    _disposeAfterTest(tester, state);

    await tester.pumpWidget(_host(ItemDescription(
      item: _item,
      url: _mediaUrl,
      metadata: state,
    )));

    expect(find.text("Saved description"), findsOneWidget);
  });

  testWidgets(
    "available image stays selected while refreshing",
    (tester) async {
      const imageUrl = "https://images.example/preview.png";
      final tempDir = (await tester.runAsync(
        () => Directory.systemTemp.createTemp("chenron-image-test-"),
      ))!;
      final previousPathProvider = PathProviderPlatform.instance;
      PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
      final imageCache = ImageCacheManager();
      final cacheManager = (await tester.runAsync(() async {
        await imageCache.initialize(customPath: tempDir.path, cacheKey: "test");
        final manager = await imageCache.instance;
        await manager.putFile(
          imageUrl,
          base64Decode(
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0l"
            "EQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
          ),
          fileExtension: "png",
        );
        return manager;
      }))!;
      locator.registerSingleton<ImageCacheManager>(imageCache);
      final state = signal<MetadataState>(MetadataState.available(
        data: _metadata(imageUrl: imageUrl),
        freshness: MetadataFreshness.stale,
        refreshPhase: MetadataRefreshPhase.refreshing,
      ));
      addTearDown(() async {
        await tester
            .pumpWidget(const SizedBox.shrink())
            .timeout(const Duration(seconds: 2));
        await CachedNetworkImageProvider(
          imageUrl,
          cacheManager: cacheManager,
        ).evict();
        PaintingBinding.instance.imageCache
          ..clear()
          ..clearLiveImages();
        await tester.pump();
        state.dispose();
        PathProviderPlatform.instance = previousPathProvider;
        await tester.runAsync(() async {
          await cacheManager.dispose();
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        });
      });

      await tester
          .pumpWidget(_host(ItemImageHeader(
            url: _mediaUrl,
            metadata: state,
          )))
          .timeout(const Duration(seconds: 2));
      await tester.pump().timeout(const Duration(seconds: 2));

      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(image.imageUrl, imageUrl);
    },
    // CachedNetworkImage retains one framework image-stream handle until the
    // test isolate exits even after unmount, eviction, and cache disposal.
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {"ImageStreamCompleterHandle": 1},
    ),
  );

  testWidgets("unavailable Media metadata renders its inferred tag title", (
    tester,
  ) async {
    final state = signal<MetadataState>(const MetadataState.unavailable());
    _disposeAfterTest(tester, state);

    await tester.pumpWidget(_host(ItemTitle(
      item: _item,
      url: _mediaUrl,
      metadata: state,
    )));

    expect(find.text("sampletag - Media"), findsOneWidget);
    expect(find.text(_mediaUrl), findsNothing);
  });

  testWidgets("legacy Media placeholder renders its inferred tag title", (
    tester,
  ) async {
    final state = signal<MetadataState>(MetadataState.available(
      data: _metadata(title: "Media"),
      freshness: MetadataFreshness.fresh,
    ));
    _disposeAfterTest(tester, state);

    await tester.pumpWidget(_host(ItemTitle(
      item: _item,
      url: _mediaUrl,
      metadata: state,
    )));

    expect(find.text("sampletag - Media"), findsOneWidget);
    expect(find.text("Media"), findsNothing);
  });
}
