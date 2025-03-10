import "package:chenron/database/actions/handlers/read_handler.dart"
    show Result;
import "package:flutter_test/flutter_test.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/link/read.dart";
import "package:chenron/database/extensions/link/create.dart";
import "package:chenron/utils/test_lib/link_factory.dart";

void main() {
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

    activeLinkId = await database.createLink(
      link: activeLink.link.content,
      tags: activeLink.tags,
    );

    inactiveLinkId = await database.createLink(
      link: inactiveLink.link.content,
      tags: inactiveLink.tags,
    );
  });

  tearDown(() async {
    await database.delete(database.items).go();
    await database.delete(database.metadataRecords).go();
    await database.delete(database.tags).go();
    await database.close();
  });

  group("getLink() Operations", () {
    test("returns null for non-existent link", () async {
      final result = await database.getLink(linkId: "non_existent_id");
      expect(result, isNull);
    });

    test("retrieves link without tags", () async {
      final result = await database.getLink(
        linkId: activeLinkId,
      );

      expect(result, isNotNull);
      expect(result!.data.id, equals(activeLinkId));
      expect(result.data.content, equals("https://example.com"));
      expect(result.data.content, equals("https://example.com"));
      expect(result.tags, isEmpty);
    });

    test("retrieves link with tags", () async {
      final result = await database.getLink(
        linkId: activeLinkId,
        modes: {IncludeOptions.tags},
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
        modes: {IncludeOptions.tags},
      );

      expect(result, isNotNull);
      expect(result!.data.id, equals(activeLinkId));
      expect(result.data.content, equals("https://example.com"));
      expect(result.tags.length, equals(2));
    });
  });

  group("getAllLinks() Operations", () {
    test("retrieves all links without tags", () async {
      final results = await database.getAllLinks();

      expect(results.length, equals(2));
      expect(results.map((r) => r.data.content).toList(),
          contains("https://example.com"));
      expect(results.map((r) => r.data.content).toList(),
          contains("https://another-example.com"));
      expect(results.every((r) => r.tags.isEmpty), isTrue);
    });

    test("retrieves all links with tags", () async {
      final results = await database.getAllLinks(modes: {IncludeOptions.tags});

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
        emitsThrough(predicate<Result<Link>>((result) =>
            result.data.id == activeLinkId &&
            result.data.content == "https://example.com" &&
            result.tags.isEmpty)),
      );
    });

    test("watches link with tags", () async {
      final stream = database.watchLink(
        linkId: activeLinkId,
        modes: {IncludeOptions.tags},
      );

      expect(
        stream,
        emitsThrough(predicate<Result<Link>>((result) =>
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
        emitsThrough(predicate<List<Result<Link>>>((results) {
          print("Received results: ${results.length} links");
          print(
              "Link contents: ${results.map((r) => r.data.content).toList()}");
          print("Tags per link: ${results.map((r) => r.tags.length).toList()}");

          return results.length == 2 &&
              results.every((r) => r.tags.isEmpty) &&
              results.map((r) => r.data.content).toSet().containsAll(
                  ["https://example.com", "https://another-example.com"]);
        })),
      );
    });

    test("watches all links with tags", () async {
      final stream = database.watchAllLinks(modes: {IncludeOptions.tags});

      expect(
        stream,
        emitsThrough(predicate<List<Result<Link>>>((results) =>
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
