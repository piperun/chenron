// ignore_for_file: avoid_print

import "dart:io";
import "package:flutter_test/flutter_test.dart";
import "package:database/database.dart";
import "package:database/extensions/link/read.dart";
import "package:database/extensions/link/create.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:logger/logger.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    // Initialize logger for VEPR operations with temp directory
    final tempDir = Directory.systemTemp.createTempSync("test_logs");
    loggerGlobal.setupLogging(logDir: tempDir, logToFileInDebug: false);
  });
  late AppDatabase database;
  late LinkTestData activeLink;
  late LinkTestData inactiveLink;
  late String activeLinkId;
  late String inactiveLinkId;

  setUp(() async {
    database = AppDatabase(
        databaseName: "test_db", setupOnInit: true, debugMode: true);

    activeLink = LinkTestDataFactory.create(
      url: "https://example.com",
      content: "https://example.com",
      tagValues: ["tech", "programming"],
    );

    inactiveLink = LinkTestDataFactory.create(
      url: "https://another-example.com",
      content: "https://another-example.com",
      tagValues: ["news", "media"],
    );

    final activeLinkResult = await database.createLink(
      link: activeLink.link.path,
      tags: activeLink.tags,
    );
    activeLinkId = activeLinkResult.linkId;

    final inactiveLinkResult = await database.createLink(
      link: inactiveLink.link.path,
      tags: inactiveLink.tags,
    );
    inactiveLinkId = inactiveLinkResult.linkId;
  });

  tearDown(() async {
    final items = database.items;
    await database.delete(items).go();
    final metadataRecords = database.metadataRecords;
    await database.delete(metadataRecords).go();
    final tags = database.tags;
    await database.delete(tags).go();
    await database.close();
  });

  group("getLink() Operations", () {
    test("returns null for non-existent link", () async {
      final LinkResult? result =
          await database.getLink(linkId: "non_existent_id");
      expect(result, isNull);
    });

    test("retrieves link without tags", () async {
      final result = await database.getLink(
        linkId: activeLinkId,
      );

      expect(result, isNotNull);
      expect(result!.data.id, equals(activeLinkId));
      expect(result.data.path, equals("https://example.com"));
      expect(result.data.path, equals("https://example.com"));
      expect(result.tags, isEmpty);
    });

    test("retrieves link with tags", () async {
      final result = await database.getLink(
        linkId: activeLinkId,
        includeOptions:
            const IncludeOptions<AppDataInclude>({AppDataInclude.tags}),
      );

      expect(result, isNotNull);
      expect(result!.data.id, equals(activeLinkId));
      expect(result.tags.length, equals(2));
      expect(
        result.tags.map((t) => t.name).toSet(),
        equals({"tech", "programming"}),
      );
    });

    test("retrieves link with all data", () async {
      final result = await database.getLink(
        linkId: activeLinkId,
        includeOptions:
            const IncludeOptions<AppDataInclude>({AppDataInclude.tags}),
      );

      expect(result, isNotNull);
      expect(result!.data.id, equals(activeLinkId));
      expect(result.data.path, equals("https://example.com"));
      expect(result.tags.length, equals(2));
    });
  });

  group("getAllLinks() Operations", () {
    test("retrieves all links without tags", () async {
      final results = await database.getAllLinks();

      expect(results.length, equals(2));
      expect(results.map((r) => r.data.path).toList(),
          contains("https://example.com"));
      expect(results.map((r) => r.data.path).toList(),
          contains("https://another-example.com"));
      expect(results.every((r) => r.tags.isEmpty), isTrue);
    });

    test("retrieves all links with tags", () async {
      final results = await database.getAllLinks(
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}));

      expect(results.length, equals(2));

      final activeResult = results.firstWhere((r) => r.data.id == activeLinkId);
      expect(activeResult.tags.length, equals(2));
      expect(
        activeResult.tags.map((t) => t.name).toSet(),
        equals({"tech", "programming"}),
      );

      final inactiveResult =
          results.firstWhere((r) => r.data.id == inactiveLinkId);
      expect(inactiveResult.tags.length, equals(2));
      expect(
        inactiveResult.tags.map((t) => t.name).toSet(),
        equals({"news", "media"}),
      );
    });
  });

  group("watchLink() Operations", () {
    test("emits error for non-existent link", () async {
      final stream = database.watchLink(linkId: "non_existent_id");
      expect(stream, emits(null));
    });

    test("watches link without tags", () async {
      final stream = database.watchLink(
        linkId: activeLinkId,
      );

      expect(
        stream,
        emitsThrough(predicate<LinkResult>((result) =>
            result.data.id == activeLinkId &&
            result.data.path == "https://example.com" &&
            result.tags.isEmpty)),
      );
    });

    test("watches link with tags", () async {
      final stream = database.watchLink(
        linkId: activeLinkId,
        includeOptions:
            const IncludeOptions<AppDataInclude>({AppDataInclude.tags}),
      );

      expect(
        stream,
        emitsThrough(predicate<LinkResult>((result) =>
            result.data.id == activeLinkId &&
            result.tags.length == 2 &&
            result.tags
                .map((t) => t.name)
                .toSet()
                .containsAll(["tech", "programming"]))),
      );
    });
  });

  group("watchAllLinks() Operations", () {
    test("watches all links without tags", () async {
      final stream = database.watchAllLinks();

      print("Starting watch all links test");

      expect(
        stream,
        emitsThrough(predicate<List<LinkResult>>((results) {
          print("Received results: ${results.length} links");
          print("Link contents: ${results.map((r) => r.data.path).toList()}");
          print("Tags per link: ${results.map((r) => r.tags.length).toList()}");

          return results.length == 2 &&
              results.every((r) => r.tags.isEmpty) &&
              results.map((r) => r.data.path).toSet().containsAll(
                  ["https://example.com", "https://another-example.com"]);
        })),
      );
    });

    test("watches all links with tags", () async {
      final stream = database.watchAllLinks(
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}));

      expect(
        stream,
        emitsThrough(predicate<List<LinkResult>>((results) =>
            results.length == 2 &&
            results.every((r) => r.tags.length == 2) &&
            results.any((r) => r.tags
                .map((t) => t.name)
                .toSet()
                .containsAll(["tech", "programming"])) &&
            results.any((r) => r.tags
                .map((t) => t.name)
                .toSet()
                .containsAll(["news", "media"])))),
      );
    });
  });
}
