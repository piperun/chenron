import "package:core/patterns/include_options.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:drift/drift.dart" hide isNotNull, isNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(queryExecutor: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group("ViewerQuery", () {
    test("compares set-valued filters without depending on insertion order",
        () {
      const left = ViewerQuery(
        folderId: "folder-id",
        searchText: "needle",
        types: <FolderItemType>{
          FolderItemType.link,
          FolderItemType.folder,
        },
        includedTags: <String>{"tag-a", "tag-b"},
        excludedTags: <String>{"tag-c", "tag-d"},
        sort: ViewerSort.dateDesc,
      );
      const right = ViewerQuery(
        folderId: "folder-id",
        searchText: "needle",
        types: <FolderItemType>{
          FolderItemType.folder,
          FolderItemType.link,
        },
        includedTags: <String>{"tag-b", "tag-a"},
        excludedTags: <String>{"tag-d", "tag-c"},
        sort: ViewerSort.dateDesc,
      );

      expect(left, right);
      expect(left.hashCode, right.hashCode);
      expect(
        left.withoutTagFilters(),
        const ViewerQuery(
          folderId: "folder-id",
          searchText: "needle",
          types: <FolderItemType>{
            FolderItemType.link,
            FolderItemType.folder,
          },
          sort: ViewerSort.dateDesc,
        ),
      );
    });
  });

  group("viewer pages", () {
    test("top-level pages contain folders and links but not documents",
        () async {
      final folderId =
          await _insertFolder(database, 1, title: "Library Folder");
      final linkId = await _insertLink(database, 1,
          path: "https://library-1.example/path");
      final documentId =
          await _insertDocument(database, 1, title: "Library Document");

      final page = await database.getViewerPage(
        const ViewerQuery(),
        limit: 10,
        offset: 0,
      );

      expect(
          page.map((item) => item.id), containsAll(<String>[folderId, linkId]));
      expect(page.map((item) => item.id), isNot(contains(documentId)));
      expect(page.map((item) => item.type).toSet(), <FolderItemType>{
        FolderItemType.folder,
        FolderItemType.link,
      });
    });

    test("folder pages contain direct links, documents, and nested folders",
        () async {
      final parentId =
          await _insertFolder(database, 10, title: "Parent Folder");
      final nestedId =
          await _insertFolder(database, 11, title: "Nested Folder");
      final linkId = await _insertLink(database, 10,
          path: "https://nested-link.example/path");
      final documentId =
          await _insertDocument(database, 10, title: "Nested Document");
      final nestedRelation = await _insertItem(
        database,
        10,
        folderId: parentId,
        itemId: nestedId,
        type: FolderItemType.folder,
      );
      final linkRelation = await _insertItem(
        database,
        11,
        folderId: parentId,
        itemId: linkId,
        type: FolderItemType.link,
      );
      final documentRelation = await _insertItem(
        database,
        12,
        folderId: parentId,
        itemId: documentId,
        type: FolderItemType.document,
      );

      final page = await database.getViewerPage(
        ViewerQuery(folderId: parentId),
        limit: 10,
        offset: 0,
      );

      expect(
          page.map((item) => item.type).toSet(), FolderItemType.values.toSet());
      expect(
        <String?, String?>{
          for (final item in page) item.id: item.itemId,
        },
        <String?, String?>{
          nestedId: nestedRelation,
          linkId: linkRelation,
          documentId: documentRelation,
        },
      );
    });

    test(
        "folder parents are pinned, filtered, counted, and leased as unique keys",
        () async {
      final viewedId =
          await _insertFolder(database, 12, title: "Viewed Folder");
      final firstParentId =
          await _insertFolder(database, 13, title: "Zulu Parent");
      final secondParentId =
          await _insertFolder(database, 14, title: "Yankee Parent");
      final directLinkId = await _insertLink(
        database,
        12,
        path: "https://aaa-direct.example/path",
      );
      await _insertItem(
        database,
        120,
        folderId: firstParentId,
        itemId: viewedId,
        type: FolderItemType.folder,
      );
      await _insertItem(
        database,
        121,
        folderId: secondParentId,
        itemId: viewedId,
        type: FolderItemType.folder,
      );
      await _insertItem(
        database,
        122,
        folderId: viewedId,
        itemId: firstParentId,
        type: FolderItemType.folder,
      );
      await _insertItem(
        database,
        123,
        folderId: viewedId,
        itemId: directLinkId,
        type: FolderItemType.link,
      );
      final parentTag = await _insertTag(database, 12, name: "parent-tag");
      await _attachTag(
        database,
        120,
        itemId: secondParentId,
        tagId: parentTag,
      );
      final query = ViewerQuery(
        folderId: viewedId,
        includeFolderParents: true,
        sort: ViewerSort.nameAsc,
      );

      final page = await database.getViewerPage(query, limit: 10, offset: 0);

      expect(
        page.map((item) => item.id),
        <String?>[secondParentId, firstParentId, directLinkId],
      );
      expect(page.map((item) => (type: item.type, id: item.id)).toSet(),
          hasLength(3));
      expect(await database.getViewerItemCount(query), 3);

      final filteredQuery = ViewerQuery(
        folderId: viewedId,
        includeFolderParents: true,
        includedTags: const <String>{"PARENT-TAG"},
      );
      final filtered = await database.getViewerPage(
        filteredQuery,
        limit: 10,
        offset: 0,
      );
      expect(filtered.map((item) => item.id), <String?>[secondParentId]);
      expect(await database.getViewerItemCount(filteredQuery), 1);
      expect(
        (await database.getViewerTagFacets(query.withoutTagFilters()))
            .single
            .itemCount,
        1,
      );

      final lease = await database.createViewerSelectionLease(query: query);
      try {
        expect(await database.getViewerSelectionLeaseCount(lease), 3);
        final batch =
            await database.getViewerSelectionLeaseBatch(lease, limit: 10);
        expect(batch.map((item) => (type: item.type, id: item.id)).toSet(),
            hasLength(3));
      } finally {
        await database.releaseViewerSelectionLease(lease);
      }
    });

    test("search is a case-insensitive substring over names, paths, and tags",
        () async {
      final folderId =
          await _insertFolder(database, 20, title: "Mixed Case Folder");
      final linkId = await _insertLink(database, 20,
          path: "https://path-needle.example/item");
      final documentId =
          await _insertDocument(database, 20, title: "Tagged Document");
      final tagId = await _insertTag(database, 20, name: "topic");
      await _attachTag(database, 20, itemId: documentId, tagId: tagId);
      await _insertItem(
        database,
        20,
        folderId: folderId,
        itemId: documentId,
        type: FolderItemType.document,
      );

      final folderMatches = await database.getViewerPage(
        const ViewerQuery(searchText: "CASE FOL"),
        limit: 10,
        offset: 0,
      );
      final pathMatches = await database.getViewerPage(
        const ViewerQuery(searchText: "NEEDLE.EXAMPLE"),
        limit: 10,
        offset: 0,
      );
      final tagMatches = await database.getViewerPage(
        ViewerQuery(folderId: folderId, searchText: "OPI"),
        limit: 10,
        offset: 0,
      );

      expect(folderMatches.map((item) => item.id), <String>[folderId]);
      expect(pathMatches.map((item) => item.id), <String>[linkId]);
      expect(tagMatches.map((item) => item.id), <String>[documentId]);
    });

    test("document search matches the file path independently of its title",
        () async {
      final folderId =
          await _insertFolder(database, 21, title: "Document Parent");
      final documentId = await _insertDocument(
        database,
        21,
        title: "Unrelated title",
        filePath: "vault/reports/path-only-needle.pdf",
      );
      await _insertItem(
        database,
        21,
        folderId: folderId,
        itemId: documentId,
        type: FolderItemType.document,
      );

      final matches = await database.getViewerPage(
        ViewerQuery(folderId: folderId, searchText: "PATH-ONLY-NEEDLE"),
        limit: 10,
        offset: 0,
      );

      expect(matches.map((item) => item.id), <String>[documentId]);
    });

    test("card tag hydration is capped while the full item fetch is exact",
        () async {
      final linkId = await _insertLink(
        database,
        22,
        path: "https://many-tags.example/item",
      );
      for (var index = 0; index < 25; index++) {
        final tagId = await _insertTag(
          database,
          2200 + index,
          name: "card-tag-${index.toString().padLeft(2, '0')}",
        );
        await _attachTag(
          database,
          2200 + index,
          itemId: linkId,
          tagId: tagId,
        );
      }

      final card = (await database.getViewerPage(
        const ViewerQuery(types: <FolderItemType>{FolderItemType.link}),
        limit: 10,
        offset: 0,
      ))
          .single;
      final full = await database.getLink(
        linkId: linkId,
        includeOptions:
            const IncludeOptions<AppDataInclude>({AppDataInclude.tags}),
      );

      expect(card.tags, hasLength(20));
      expect(full!.tags, hasLength(25));
    });

    test("included tags use ANY semantics and excluded tags use NONE semantics",
        () async {
      final alphaTag = await _insertTag(database, 30, name: "alpha");
      final betaTag = await _insertTag(database, 31, name: "bravo");
      final first = await _insertLink(database, 30,
          path: "https://filter-1.example/path");
      final second = await _insertLink(database, 31,
          path: "https://filter-2.example/path");
      final third = await _insertLink(database, 32,
          path: "https://filter-3.example/path");
      await _attachTag(database, 30, itemId: first, tagId: alphaTag);
      await _attachTag(database, 31, itemId: second, tagId: betaTag);
      await _attachTag(database, 32, itemId: third, tagId: alphaTag);
      await _attachTag(database, 33, itemId: third, tagId: betaTag);

      final included = await database.getViewerPage(
        const ViewerQuery(includedTags: <String>{"ALPHA", "bravo"}),
        limit: 10,
        offset: 0,
      );
      final excluded = await database.getViewerPage(
        const ViewerQuery(
          includedTags: <String>{"alpha"},
          excludedTags: <String>{"BRAVO"},
        ),
        limit: 10,
        offset: 0,
      );

      expect(included.map((item) => item.id).toSet(),
          <String>{first, second, third});
      expect(excluded.map((item) => item.id), <String>[first]);
    });

    test("every sort direction uses stable type and id tie-breakers", () async {
      final shared = DateTime.utc(2025, 1, 1);
      final oldest = DateTime.utc(2024, 1, 1);
      final newest = DateTime.utc(2026, 1, 1);
      final tiedIds = <String>[_id("folder", 41), _id("folder", 40)]..sort();
      await _insertFolder(database, 40,
          id: tiedIds.last, title: "Same Name", createdAt: shared);
      await _insertFolder(database, 41,
          id: tiedIds.first, title: "Same Name", createdAt: shared);
      final oldestId = await _insertFolder(database, 42,
          title: "Zulu Folder", createdAt: oldest);
      final newestId = await _insertFolder(database, 43,
          title: "Alpha Folder", createdAt: newest);

      Future<List<String?>> idsFor(ViewerSort sort) async {
        final page = await database.getViewerPage(
          ViewerQuery(
              types: const <FolderItemType>{FolderItemType.folder}, sort: sort),
          limit: 10,
          offset: 0,
        );
        return page.map((item) => item.id).toList();
      }

      expect(
        await idsFor(ViewerSort.nameAsc),
        <String?>[newestId, tiedIds.first, tiedIds.last, oldestId],
      );
      expect(
        await idsFor(ViewerSort.nameDesc),
        <String?>[oldestId, tiedIds.first, tiedIds.last, newestId],
      );
      expect(
        await idsFor(ViewerSort.dateAsc),
        <String?>[oldestId, tiedIds.first, tiedIds.last, newestId],
      );
      expect(
        await idsFor(ViewerSort.dateDesc),
        <String?>[newestId, tiedIds.first, tiedIds.last, oldestId],
      );
    });

    test("cross-type name and date ties use type then id for every sort mode",
        () async {
      final tiedAt = DateTime.utc(2025, 3, 1);
      const displayName = "https://same.example/path";
      final folderId = await _insertFolder(
        database,
        44,
        title: displayName,
        createdAt: tiedAt,
      );
      final linkId = await _insertLink(
        database,
        44,
        path: displayName,
        createdAt: tiedAt,
      );

      for (final sort in ViewerSort.values) {
        final page = await database.getViewerPage(
          ViewerQuery(
            types: const <FolderItemType>{
              FolderItemType.link,
              FolderItemType.folder,
            },
            sort: sort,
          ),
          limit: 10,
          offset: 0,
        );

        expect(
          page.map((item) => item.id),
          <String?>[linkId, folderId],
          reason: "$sort must keep ascending type and id tie-breakers",
        );
      }
    });

    test("count is exact and page argument bounds reject invalid values",
        () async {
      await _insertFolder(database, 50, title: "Count Folder");
      await _insertLink(database, 50, path: "https://count-1.example/path");
      await _insertLink(database, 51, path: "https://count-2.example/path");
      await _insertDocument(database, 50, title: "Count Document");

      expect(await database.getViewerItemCount(const ViewerQuery()), 3);
      await expectLater(
        database.getViewerPage(const ViewerQuery(), limit: 0, offset: 0),
        throwsArgumentError,
      );
      await expectLater(
        database.getViewerPage(const ViewerQuery(), limit: 10, offset: -1),
        throwsArgumentError,
      );
    });

    test(
        "tag facets retain search and type filters but ignore active tag filters",
        () async {
      final alphaTag = await _insertTag(database, 60, name: "alpha");
      final betaTag = await _insertTag(database, 61, name: "bravo");
      final first =
          await _insertLink(database, 60, path: "https://facet-1.example/path");
      final second =
          await _insertLink(database, 61, path: "https://facet-2.example/path");
      await _insertFolder(database, 60, title: "Facet Folder");
      await _attachTag(database, 60, itemId: first, tagId: alphaTag);
      await _attachTag(database, 61, itemId: first, tagId: betaTag);
      await _attachTag(database, 62, itemId: second, tagId: betaTag);

      final facets = await database.getViewerTagFacets(
        const ViewerQuery(
          searchText: "facet-",
          types: <FolderItemType>{FolderItemType.link},
          includedTags: <String>{"alpha"},
          excludedTags: <String>{"bravo"},
        ),
      );

      expect(
        <String, int>{
          for (final facet in facets) facet.tag.name: facet.itemCount
        },
        <String, int>{"alpha": 1, "bravo": 2},
      );
    });

    test("tag facet responses never materialize more than one hundred tags",
        () async {
      final linkId = await _insertLink(
        database,
        63,
        path: "https://facet-bound.example/item",
      );
      for (var index = 0; index < 125; index++) {
        final tagId = await _insertTag(
          database,
          6300 + index,
          name: "f${index.toString().padLeft(3, '0')}",
        );
        await _attachTag(
          database,
          6300 + index,
          itemId: linkId,
          tagId: tagId,
        );
      }

      final facets = await database.getViewerTagFacets(
        const ViewerQuery(types: <FolderItemType>{FolderItemType.link}),
      );

      expect(facets, hasLength(100));
      final searched = await database.getViewerTagFacets(
        const ViewerQuery(types: <FolderItemType>{FolderItemType.link}),
        searchText: "F124",
      );
      expect(searched.map((facet) => facet.tag.name), <String>["f124"]);
    });

    test("invalidation emits after a watched entity table changes", () async {
      final invalidation = database.watchViewerInvalidations().first;

      await _insertLink(database, 70,
          path: "https://invalidation.example/path");

      await expectLater(
          invalidation.timeout(const Duration(seconds: 2)), completes);
    });

    test(
        "invalidation emits when folder membership is inserted moved or deleted",
        () async {
      final firstFolder =
          await _insertFolder(database, 71, title: "First Membership Folder");
      final secondFolder =
          await _insertFolder(database, 72, title: "Second Membership Folder");
      final linkId = await _insertLink(
        database,
        71,
        path: "https://membership.example/path",
      );
      final relationId = _id("relation", 71);

      await _expectViewerInvalidation(
        database,
        () async {
          await _insertItem(
            database,
            71,
            folderId: firstFolder,
            itemId: linkId,
            type: FolderItemType.link,
          );
        },
      );
      await _expectViewerInvalidation(
        database,
        () async {
          await (database.update(database.items)
                ..where((item) => item.id.equals(relationId)))
              .write(ItemsCompanion(folderId: Value(secondFolder)));
        },
      );
      await _expectViewerInvalidation(
        database,
        () async {
          await (database.delete(database.items)
                ..where((item) => item.id.equals(relationId)))
              .go();
        },
      );
    });
  });

  group("viewer selection leases", () {
    test("lease count follows stable membership and consumption", () async {
      final first = await _insertLink(
        database,
        77,
        path: "https://lease-count-1.example/path",
      );
      await _insertLink(
        database,
        78,
        path: "https://lease-count-2.example/path",
      );
      final lease =
          await database.createViewerSelectionLease(query: const ViewerQuery());

      expect(await database.getViewerSelectionLeaseCount(lease), 2);

      await database.consumeViewerSelectionLeaseBatch(
        lease,
        <ViewerItemKey>[(type: FolderItemType.link, id: first)],
      );
      expect(await database.getViewerSelectionLeaseCount(lease), 1);

      await database.releaseViewerSelectionLease(lease);
      expect(await database.getViewerSelectionLeaseCount(lease), 0);
    });

    test("lease count ignores explicit keys that cannot materialize", () async {
      final lease = await database.createViewerSelectionLease(
        query: const ViewerQuery(),
        onlyKeys: const <ViewerItemKey>{
          (type: FolderItemType.link, id: "missing-link"),
        },
      );

      try {
        expect(await database.getViewerSelectionLeaseCount(lease), 0);
        expect(
          await database.getViewerSelectionLeaseBatch(lease, limit: 100),
          isEmpty,
        );
      } finally {
        await database.releaseViewerSelectionLease(lease);
      }
    });

    test("membership is stable and only consumed keys are deleted", () async {
      final first =
          await _insertLink(database, 80, path: "https://lease-1.example/path");
      final second =
          await _insertLink(database, 81, path: "https://lease-2.example/path");
      final lease =
          await database.createViewerSelectionLease(query: const ViewerQuery());
      final later = await _insertLink(database, 82,
          path: "https://lease-later.example/path");

      final firstBatch =
          await database.getViewerSelectionLeaseBatch(lease, limit: 100);
      expect(
          firstBatch.map((item) => item.id).toSet(), <String>{first, second});
      expect(firstBatch.map((item) => item.id), isNot(contains(later)));
      expect(firstBatch.every((item) => item.itemId == null), isTrue);
      expect(firstBatch.every((item) => item.addedAt == null), isTrue);

      await database.consumeViewerSelectionLeaseBatch(
        lease,
        <ViewerItemKey>[(type: FolderItemType.link, id: first)],
      );
      final secondBatch =
          await database.getViewerSelectionLeaseBatch(lease, limit: 100);
      expect(secondBatch.map((item) => item.id), <String>[second]);

      await database.releaseViewerSelectionLease(lease);
      expect(await database.getViewerSelectionLeaseBatch(lease, limit: 100),
          isEmpty);
    });

    test(
        "explicit and excluded keys are applied without exceeding the batch limit",
        () async {
      final ids = <String>[];
      for (var index = 0; index < 5; index++) {
        ids.add(await _insertLink(
          database,
          90 + index,
          path: "https://explicit-$index.example/path",
        ));
      }
      final lease = await database.createViewerSelectionLease(
        query: const ViewerQuery(searchText: "does-not-match"),
        onlyKeys: ids
            .map<ViewerItemKey>((id) => (type: FolderItemType.link, id: id))
            .toSet(),
        excludedKeys: <ViewerItemKey>{
          (type: FolderItemType.link, id: ids.last),
        },
      );

      final batch =
          await database.getViewerSelectionLeaseBatch(lease, limit: 2);

      expect(batch, hasLength(2));
      expect(batch.map((item) => item.id), isNot(contains(ids.last)));
      expect(batch.every((item) => item.itemId == null), isTrue);
      expect(batch.every((item) => item.addedAt == null), isTrue);
      await expectLater(
        database.getViewerSelectionLeaseBatch(lease, limit: 0),
        throwsArgumentError,
      );
      await database.releaseViewerSelectionLease(lease);
    });

    test("folder selection batches preserve relation identity and added time",
        () async {
      final folderId =
          await _insertFolder(database, 100, title: "Lease Context Folder");
      final linkId = await _insertLink(
        database,
        100,
        path: "https://lease-context.example/path",
      );
      await _insertItem(
        database,
        100,
        folderId: folderId,
        itemId: linkId,
        type: FolderItemType.link,
      );
      final query = ViewerQuery(folderId: folderId);
      final selected = (await database.getViewerPage(
        query,
        limit: 10,
        offset: 0,
      ))
          .single;
      final lease = await database.createViewerSelectionLease(query: query);

      try {
        final leased = (await database.getViewerSelectionLeaseBatch(
          lease,
          limit: 10,
        ))
            .single;

        expect(leased.id, selected.id);
        expect(leased.itemId, selected.itemId);
        expect(leased.addedAt, selected.addedAt);
      } finally {
        await database.releaseViewerSelectionLease(lease);
      }
    });
  });

  test(
    "100000 rows keep deep pages and selection batches bounded",
    () async {
      await database.transaction(() async {
        for (var start = 0; start < 100000; start += 1000) {
          await database.customStatement(
            """
WITH RECURSIVE sequence(value) AS (
  SELECT ?
  UNION ALL
  SELECT value + 1 FROM sequence WHERE value < ?
)
INSERT INTO links (id, created_at, path)
SELECT printf('item-%025d', value),
       '2025-01-01T00:00:00.000Z',
       printf('https://item-%06d.example/path', value)
FROM sequence
""",
            <Object?>[start, start + 999],
          );
        }
      });

      Future<Duration> timePage(ViewerSort sort, int offset) async {
        final stopwatch = Stopwatch()..start();
        final page = await database.getViewerPage(
          ViewerQuery(sort: sort),
          limit: 100,
          offset: offset,
        );
        stopwatch.stop();
        expect(page, hasLength(100));
        return stopwatch.elapsed;
      }

      final namePage0 = await timePage(ViewerSort.nameAsc, 0);
      final namePage999 = await timePage(ViewerSort.nameAsc, 99900);
      final datePage0 = await timePage(ViewerSort.dateAsc, 0);
      final datePage999 = await timePage(ViewerSort.dateAsc, 99900);

      final namePlan = await database.debugExplainViewerPageQueryPlan(
        const ViewerQuery(sort: ViewerSort.nameAsc),
        limit: 100,
        offset: 99900,
      );
      final datePlan = await database.debugExplainViewerPageQueryPlan(
        const ViewerQuery(sort: ViewerSort.dateAsc),
        limit: 100,
        offset: 99900,
      );
      expect(namePlan, isNotEmpty);
      expect(datePlan, isNotEmpty);
      expect(
        namePlan
            .any((detail) => detail.contains("metadata_records_relation_idx")),
        isTrue,
      );
      expect(
        datePlan
            .any((detail) => detail.contains("metadata_records_relation_idx")),
        isTrue,
      );
      // These records are intentionally generic and are copied to the private
      // task report after the run.
      // ignore: avoid_print
      print("viewer name plan: ${namePlan.join(" | ")}");
      // ignore: avoid_print
      print("viewer date plan: ${datePlan.join(" | ")}");
      // ignore: avoid_print
      print(
        "viewer timings: name page 0=${namePage0.inMilliseconds}ms, "
        "name page 999=${namePage999.inMilliseconds}ms, "
        "date page 0=${datePage0.inMilliseconds}ms, "
        "date page 999=${datePage999.inMilliseconds}ms",
      );

      expect(namePage0, lessThan(const Duration(seconds: 2)));
      expect(namePage999, lessThan(const Duration(seconds: 2)));
      expect(datePage0, lessThan(const Duration(seconds: 2)));
      expect(datePage999, lessThan(const Duration(seconds: 2)));

      final lease =
          await database.createViewerSelectionLease(query: const ViewerQuery());
      final batch =
          await database.getViewerSelectionLeaseBatch(lease, limit: 100);
      expect(batch, hasLength(100));
      await database.releaseViewerSelectionLease(lease);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

Future<String> _insertFolder(
  AppDatabase database,
  int index, {
  String? id,
  required String title,
  DateTime? createdAt,
}) async {
  final folderId = id ?? _id("folder", index);
  await database.into(database.folders).insert(
        FoldersCompanion.insert(
          id: folderId,
          title: title,
          description: "Generic folder $index",
          createdAt: Value(createdAt ?? DateTime.utc(2025, 1, 1, 0, 0, index)),
        ),
      );
  return folderId;
}

Future<String> _insertLink(
  AppDatabase database,
  int index, {
  required String path,
  DateTime? createdAt,
}) async {
  final id = _id("link", index);
  await database.into(database.links).insert(
        LinksCompanion.insert(
          id: id,
          path: path,
          createdAt: Value(createdAt ?? DateTime.utc(2025, 1, 1, 0, 0, index)),
        ),
      );
  return id;
}

Future<String> _insertDocument(
  AppDatabase database,
  int index, {
  required String title,
  String? filePath,
}) async {
  final id = _id("document", index);
  await database.into(database.documents).insert(
        DocumentsCompanion.insert(
          id: id,
          title: title,
          filePath: filePath ?? "documents/generic-$index.md",
          fileType: DocumentFileType.markdown,
          createdAt: Value(DateTime.utc(2025, 1, 1, 0, 0, index)),
          updatedAt: Value(DateTime.utc(2025, 1, 1, 0, 0, index)),
        ),
      );
  return id;
}

Future<String> _insertTag(
  AppDatabase database,
  int index, {
  required String name,
}) async {
  final id = _id("tag", index);
  await database.into(database.tags).insert(
        TagsCompanion.insert(id: id, name: name),
      );
  return id;
}

Future<String> _insertItem(
  AppDatabase database,
  int index, {
  required String folderId,
  required String itemId,
  required FolderItemType type,
}) async {
  final id = _id("relation", index);
  await database.into(database.items).insert(
        ItemsCompanion.insert(
          id: id,
          folderId: folderId,
          itemId: itemId,
          typeId: type,
          createdAt: Value(DateTime.utc(2025, 2, 1, 0, 0, index)),
        ),
      );
  return id;
}

Future<void> _attachTag(
  AppDatabase database,
  int index, {
  required String itemId,
  required String tagId,
}) async {
  await database.into(database.metadataRecords).insert(
        MetadataRecordsCompanion.insert(
          id: _id("metadata", index),
          typeId: MetadataTypeEnum.tag,
          itemId: itemId,
          metadataId: tagId,
        ),
      );
}

Future<void> _expectViewerInvalidation(
  AppDatabase database,
  Future<void> Function() mutation,
) async {
  final invalidation = database
      .watchViewerInvalidations()
      .first
      .timeout(const Duration(seconds: 2));
  await mutation();
  await invalidation;
}

String _id(String prefix, int index) {
  final suffix = index.toString().padLeft(29 - prefix.length, "0");
  return "$prefix-$suffix";
}
