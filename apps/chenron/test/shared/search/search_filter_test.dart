import "package:chenron/shared/search/search_filter.dart";
import "package:database/database.dart";
import "package:flutter_test/flutter_test.dart";

/// Helper to build a [Tag] for testing.
Tag _tag(String name) => Tag(
      id: "t-$name",
      name: name,
      createdAt: DateTime(2025),
    );

/// Helper to build a [LinkItem] with optional tags.
FolderItem _link(String url, [List<Tag> tags = const []]) => FolderItem.link(
      id: "id-$url",
      url: url,
      tags: tags,
      createdAt: DateTime(2025),
    );

/// Helper to build a [DocumentItem] with optional tags.
FolderItem _doc(String title, [List<Tag> tags = const []]) =>
    FolderItem.document(
      id: "id-$title",
      title: title,
      filePath: "/docs/$title.md",
      tags: tags,
      createdAt: DateTime(2025),
    );

/// Helper to build a [FolderItemNested] with optional tags.
FolderItem _folder(String folderId, [List<Tag> tags = const []]) =>
    FolderItem.folder(
      id: "id-$folderId",
      folderId: folderId,
      title: "Folder $folderId",
      tags: tags,
      createdAt: DateTime(2025),
    );

void main() {
  late SearchFilter filter;

  setUp(() {
    filter = SearchFilter();
  });

  group("SearchFilter.filterItems single-pass correctness", () {
    final flutter = _tag("flutter");
    final dart = _tag("dart");
    final rust = _tag("rust");

    final items = [
      _link("https://flutter.dev", [flutter, dart]),
      _link("https://rust-lang.org", [rust]),
      _doc("Dart Guide", [dart]),
      _doc("Rust Book", [rust]),
      _folder("misc-notes", [flutter]),
    ];

    test("empty filters return all items", () {
      final result = filter.filterItems(items: items);
      expect(result, hasLength(items.length));
    });

    test("type filter only returns matching types", () {
      final result = filter.filterItems(
        items: items,
        types: {FolderItemType.link},
      );
      expect(result, hasLength(2));
      expect(result.every((i) => i.type == FolderItemType.link), isTrue);
    });

    test("included tag filter only returns items with matching tag", () {
      final result = filter.filterItems(
        items: items,
        includedTags: {"dart"},
      );
      // flutter.dev (has dart) and Dart Guide (has dart)
      expect(result, hasLength(2));
    });

    test("excluded tag filter removes items with matching tag", () {
      final result = filter.filterItems(
        items: items,
        excludedTags: {"rust"},
      );
      // rust-lang.org and Rust Book excluded
      expect(result, hasLength(3));
      expect(result.every((i) => i.type != FolderItemType.link ||
          (i as LinkItem).url != "https://rust-lang.org"), isTrue);
    });

    test("query filter matches link URL", () {
      final result = filter.filterItems(
        items: items,
        query: "flutter.dev",
      );
      expect(result, hasLength(1));
      expect((result.first as LinkItem).url, "https://flutter.dev");
    });

    test("query filter matches document title", () {
      final result = filter.filterItems(
        items: items,
        query: "Dart Guide",
      );
      expect(result, hasLength(1));
      expect((result.first as DocumentItem).title, "Dart Guide");
    });

    test("query filter matches folder ID", () {
      final result = filter.filterItems(
        items: items,
        query: "misc",
      );
      expect(result, hasLength(1));
      expect((result.first as FolderItemNested).folderId, "misc-notes");
    });

    // Key regression risk: item passes type filter but fails tag filter
    test("item passing type filter but failing tag filter is excluded", () {
      final result = filter.filterItems(
        items: items,
        types: {FolderItemType.link},
        includedTags: {"dart"},
      );
      // Only flutter.dev has both type=link AND tag=dart
      expect(result, hasLength(1));
      expect((result.first as LinkItem).url, "https://flutter.dev");
    });

    // Key regression risk: item passes tag filter but fails query filter
    test("item passing tag filter but failing query filter is excluded", () {
      final result = filter.filterItems(
        items: items,
        includedTags: {"dart"},
        query: "Guide",
      );
      // flutter.dev has dart tag but URL doesn't contain "Guide"
      // Dart Guide has dart tag and title contains "Guide"
      expect(result, hasLength(1));
      expect((result.first as DocumentItem).title, "Dart Guide");
    });

    // Key regression risk: all filters active simultaneously
    test("all filters active simultaneously produce correct results", () {
      final result = filter.filterItems(
        items: items,
        types: {FolderItemType.link},
        includedTags: {"flutter"},
        excludedTags: {"rust"},
        query: "flutter",
      );
      // Only flutter.dev: type=link, has flutter tag, no rust tag, URL contains "flutter"
      expect(result, hasLength(1));
      expect((result.first as LinkItem).url, "https://flutter.dev");
    });

    // Key regression risk: tag case insensitivity
    test("tag filtering is case insensitive", () {
      final result = filter.filterItems(
        items: items,
        includedTags: {"FLUTTER"},
      );
      // "flutter" tag should match "FLUTTER" filter (case insensitive)
      expect(result, hasLength(2)); // flutter.dev and misc-notes
    });

    test("excluded tag with mixed case still excludes", () {
      final result = filter.filterItems(
        items: items,
        excludedTags: {"RUST"},
      );
      // "rust" tag should match "RUST" exclusion (case insensitive)
      expect(result, hasLength(3));
    });

    test("query is case insensitive", () {
      final result = filter.filterItems(
        items: items,
        query: "FLUTTER.DEV",
      );
      expect(result, hasLength(1));
      expect((result.first as LinkItem).url, "https://flutter.dev");
    });

    test("query matches tag name", () {
      final result = filter.filterItems(
        items: items,
        query: "rust",
      );
      // rust-lang.org (URL contains "rust"), Rust Book (title contains "rust"),
      // plus any item whose tag name contains "rust"
      // rust-lang.org has tag "rust", Rust Book has tag "rust"
      expect(result.length, greaterThanOrEqualTo(2));
    });

    test("empty type set returns all items (not zero)", () {
      final result = filter.filterItems(
        items: items,
        types: {},
      );
      // Empty set means no type filter applied
      expect(result, hasLength(items.length));
    });

    test("filtering with non-existent tag returns empty", () {
      final result = filter.filterItems(
        items: items,
        includedTags: {"nonexistent"},
      );
      expect(result, isEmpty);
    });

    test("inline tag syntax in query works", () {
      final result = filter.filterItems(
        items: items,
        query: "#dart",
      );
      // QueryParser extracts #dart as included tag
      expect(result, hasLength(2)); // flutter.dev and Dart Guide
    });

    test("inline excluded tag syntax in query works", () {
      final result = filter.filterItems(
        items: items,
        query: "-#rust",
      );
      // QueryParser extracts -#rust as excluded tag
      expect(result, hasLength(3));
    });
  });

  group("SearchFilter.sortItems ordering", () {
    // Distinct names to assert alphabetical order unambiguously.
    final banana = _link("https://banana.example");
    final apple = _doc("Apple");
    final cherry = _folder("cherry");

    // String.compareTo is case-sensitive: uppercase ASCII sorts before
    // lowercase, so "Apple" (A=65) < "cherry" (c=99) < "https" (h=104).
    test("nameAsc sorts by name ascending", () {
      final result = filter.sortItems(
        items: [banana, cherry, apple],
        sortMode: SortMode.nameAsc,
      );
      expect(_names(result), ["Apple", "cherry", "https://banana.example"]);
    });

    test("nameDesc sorts by name descending", () {
      final result = filter.sortItems(
        items: [apple, banana, cherry],
        sortMode: SortMode.nameDesc,
      );
      expect(_names(result), ["https://banana.example", "cherry", "Apple"]);
    });

    test("dateAsc sorts oldest first, null dates last", () {
      final older = FolderItem.link(
        id: "older",
        url: "older",
        createdAt: DateTime(2020),
      );
      final newer = FolderItem.link(
        id: "newer",
        url: "newer",
        createdAt: DateTime(2024),
      );
      // Folders have no createdAt -> treated as null.
      final noDate = _folder("z-no-date");

      final result = filter.sortItems(
        items: [newer, noDate, older],
        sortMode: SortMode.dateAsc,
      );
      expect(_names(result), ["older", "newer", "z-no-date"]);
    });

    test("dateDesc sorts newest first, null dates last", () {
      final older = FolderItem.link(
        id: "older",
        url: "older",
        createdAt: DateTime(2020),
      );
      final newer = FolderItem.link(
        id: "newer",
        url: "newer",
        createdAt: DateTime(2024),
      );
      final noDate = _folder("z-no-date");

      final result = filter.sortItems(
        items: [older, noDate, newer],
        sortMode: SortMode.dateDesc,
      );
      expect(_names(result), ["newer", "older", "z-no-date"]);
    });

    test("dateAsc keeps both-null pairs in input order", () {
      // Two folders, both null-dated -> comparator returns 0, stable order.
      final first = _folder("first");
      final second = _folder("second");
      final result = filter.sortItems(
        items: [first, second],
        sortMode: SortMode.dateAsc,
      );
      expect(_names(result), ["first", "second"]);
    });

    test("equal names preserve input order (stable)", () {
      final a = _link("https://same.example");
      final b = _link("https://same.example");
      final result = filter.sortItems(
        items: [a, b],
        sortMode: SortMode.nameAsc,
      );
      expect(result.length, 2);
      expect(identical(result[0], a), isTrue);
      expect(identical(result[1], b), isTrue);
    });

    test("does not mutate the input list", () {
      final input = [banana, apple, cherry];
      final snapshot = List<FolderItem>.from(input);
      filter.sortItems(items: input, sortMode: SortMode.nameAsc);
      expect(_names(input), _names(snapshot));
    });
  });
}

/// Extract the sortable name of each item (mirrors SearchFilter._getItemName).
List<String> _names(List<FolderItem> items) => items
    .map((i) => i.map(
          link: (l) => l.url,
          document: (d) => d.title,
          folder: (f) => f.folderId,
        ))
    .toList();
