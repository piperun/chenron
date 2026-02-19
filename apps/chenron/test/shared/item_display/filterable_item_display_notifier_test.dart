import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:database/database.dart";
import "package:database/main.dart";
import "package:chenron/shared/item_display/filterable_item_display_notifier.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/item_toolbar.dart";
import "package:chenron/shared/tag_filter/tag_filter_state.dart";

final _epoch = DateTime(2024, 1, 1);

FolderItem _makeLink(String id, String url, {List<Tag>? tags}) {
  return FolderItem.link(
    id: id,
    url: url,
    tags: tags ?? [],
    createdAt: _epoch,
  );
}

FolderItem _makeDocument(String id, String title,
    {String filePath = "/test"}) {
  return FolderItem.document(
    id: id,
    title: title,
    filePath: filePath,
    tags: [],
    createdAt: _epoch,
  );
}

FolderItem _makeFolder(String id) {
  return FolderItem.folder(
    id: id,
    folderId: "folder-$id",
    title: "Folder $id",
    tags: [],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FilterableItemDisplayNotifier notifier;
  late SearchFilter searchFilter;
  late TagFilterState tagFilterState;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    searchFilter = SearchFilter();
    searchFilter.setup();
    tagFilterState = TagFilterState();

    notifier = FilterableItemDisplayNotifier(
      initialViewMode: ViewMode.grid,
      initialSortMode: SortMode.nameAsc,
      initialSelectedTypes: {
        FolderItemType.link,
        FolderItemType.document,
        FolderItemType.folder,
      },
      initialDisplayMode: DisplayMode.standard,
      searchFilter: searchFilter,
      ownsSearchFilter: false,
      tagFilterState: tagFilterState,
      ownsTagFilterState: false,
    );
  });

  tearDown(() {
    notifier.dispose();
    searchFilter.dispose();
    tagFilterState.dispose();
  });

  group("initial state", () {
    test("starts with correct view mode", () {
      expect(notifier.viewMode.value, ViewMode.grid);
    });

    test("starts with correct sort mode", () {
      expect(notifier.sortMode.value, SortMode.nameAsc);
    });

    test("starts with all types selected", () {
      expect(notifier.selectedTypes.value, {
        FolderItemType.link,
        FolderItemType.document,
        FolderItemType.folder,
      });
    });

    test("starts with delete mode off", () {
      expect(notifier.isDeleteMode.value, false);
    });

    test("starts with empty selected items", () {
      expect(notifier.selectedItems.value, isEmpty);
    });
  });

  group("setViewMode", () {
    test("changes view mode to list", () async {
      await notifier.setViewMode(ViewMode.list);
      expect(notifier.viewMode.value, ViewMode.list);
    });

    test("changes view mode to grid", () async {
      await notifier.setViewMode(ViewMode.list);
      await notifier.setViewMode(ViewMode.grid);
      expect(notifier.viewMode.value, ViewMode.grid);
    });
  });

  group("setSortMode", () {
    test("changes sort mode", () {
      notifier.setSortMode(SortMode.nameDesc);
      expect(notifier.sortMode.value, SortMode.nameDesc);
    });

    test("can set all sort modes", () {
      for (final mode in SortMode.values) {
        notifier.setSortMode(mode);
        expect(notifier.sortMode.value, mode);
      }
    });
  });

  group("setSelectedTypes", () {
    test("changes selected types", () {
      notifier.setSelectedTypes({FolderItemType.link});
      expect(notifier.selectedTypes.value, {FolderItemType.link});
    });

    test("can set empty types", () {
      notifier.setSelectedTypes({});
      expect(notifier.selectedTypes.value, isEmpty);
    });
  });

  group("toggleDeleteMode", () {
    test("enters delete mode", () {
      notifier.toggleDeleteMode();
      expect(notifier.isDeleteMode.value, true);
    });

    test("exits delete mode and clears selection", () {
      notifier.toggleDeleteMode(); // enter
      final item = _makeLink("1", "https://example.com");
      notifier.toggleItemSelection(item);
      expect(notifier.selectedItems.value, isNotEmpty);

      notifier.toggleDeleteMode(); // exit
      expect(notifier.isDeleteMode.value, false);
      expect(notifier.selectedItems.value, isEmpty);
    });
  });

  group("toggleItemSelection", () {
    test("selects item in delete mode", () {
      notifier.toggleDeleteMode();
      final item = _makeLink("1", "https://example.com");
      notifier.toggleItemSelection(item);

      expect(notifier.selectedItems.value.containsKey("1"), true);
    });

    test("deselects item in delete mode", () {
      notifier.toggleDeleteMode();
      final item = _makeLink("1", "https://example.com");
      notifier.toggleItemSelection(item);
      notifier.toggleItemSelection(item);

      expect(notifier.selectedItems.value.containsKey("1"), false);
    });

    test("ignores selection when not in delete mode", () {
      final item = _makeLink("1", "https://example.com");
      notifier.toggleItemSelection(item);

      expect(notifier.selectedItems.value, isEmpty);
    });

    test("ignores item with null id", () {
      notifier.toggleDeleteMode();
      final item = FolderItem.link(
        id: null,
        url: "https://example.com",
        createdAt: _epoch,
      );
      notifier.toggleItemSelection(item);

      expect(notifier.selectedItems.value, isEmpty);
    });
  });

  group("selectAll", () {
    test("selects all items with valid IDs in delete mode", () {
      notifier.toggleDeleteMode();
      final items = [
        _makeLink("1", "https://a.com"),
        _makeLink("2", "https://b.com"),
        _makeDocument("3", "Doc"),
      ];
      notifier.selectAll(items);

      expect(notifier.selectedItems.value.length, 3);
      expect(notifier.selectedItems.value.containsKey("1"), true);
      expect(notifier.selectedItems.value.containsKey("2"), true);
      expect(notifier.selectedItems.value.containsKey("3"), true);
    });

    test("skips items with null IDs", () {
      notifier.toggleDeleteMode();
      final items = [
        _makeLink("1", "https://a.com"),
        FolderItem.link(
            id: null, url: "https://no-id.com", createdAt: _epoch),
      ];
      notifier.selectAll(items);

      expect(notifier.selectedItems.value.length, 1);
      expect(notifier.selectedItems.value.containsKey("1"), true);
    });

    test("does nothing outside delete mode", () {
      final items = [
        _makeLink("1", "https://a.com"),
        _makeLink("2", "https://b.com"),
      ];
      notifier.selectAll(items);

      expect(notifier.selectedItems.value, isEmpty);
    });

    test("preserves existing selections when adding more", () {
      notifier.toggleDeleteMode();
      final first = _makeLink("1", "https://a.com");
      notifier.toggleItemSelection(first);

      final moreItems = [
        _makeLink("2", "https://b.com"),
        _makeDocument("3", "Doc"),
      ];
      notifier.selectAll(moreItems);

      expect(notifier.selectedItems.value.length, 3);
      expect(notifier.selectedItems.value.containsKey("1"), true);
    });
  });

  group("refreshSelectedItems", () {
    test("updates selected items with fresh data", () {
      notifier.toggleDeleteMode();
      final tag = Tag(id: "t1", name: "old", createdAt: _epoch);
      final item = FolderItem.link(
        id: "1",
        url: "https://a.com",
        tags: [tag],
        createdAt: _epoch,
      );
      notifier.toggleItemSelection(item);

      final freshTag = Tag(id: "t1", name: "new", createdAt: _epoch);
      final fresh = FolderItem.link(
        id: "1",
        url: "https://a.com",
        tags: [freshTag],
        createdAt: _epoch,
      );
      notifier.refreshSelectedItems([fresh]);

      expect(notifier.selectedItems.value["1"]!.tags.first.name, "new");
    });

    test("removes items no longer in fresh list", () {
      notifier.toggleDeleteMode();
      notifier.toggleItemSelection(_makeLink("1", "https://a.com"));
      notifier.toggleItemSelection(_makeLink("2", "https://b.com"));

      notifier.refreshSelectedItems([_makeLink("1", "https://a.com")]);
      expect(notifier.selectedItems.value.length, 1);
      expect(notifier.selectedItems.value.containsKey("1"), true);
    });

    test("no-op when selection is empty", () {
      notifier.refreshSelectedItems([_makeLink("1", "https://a.com")]);
      expect(notifier.selectedItems.value, isEmpty);
    });
  });

  group("handleSearchSubmitted", () {
    test("parses tags from query and updates controller", () {
      notifier.handleSearchSubmitted("hello #world -#spam");
      expect(tagFilterState.includedTagNames, contains("world"));
      expect(tagFilterState.excludedTagNames, contains("spam"));
      expect(searchFilter.controller.value, "hello");
    });

    test("handles query without tags", () {
      notifier.handleSearchSubmitted("plain query");
      expect(tagFilterState.includedTagNames, isEmpty);
      expect(tagFilterState.excludedTagNames, isEmpty);
      expect(searchFilter.controller.value, "plain query");
    });
  });

  group("loadViewMode", () {
    test("loads saved preference", () async {
      SharedPreferences.setMockInitialValues(
          {"view_mode_preference": "list"});
      await notifier.loadViewMode();
      expect(notifier.viewMode.value, ViewMode.list);
    });

    test("defaults to grid when no pref", () async {
      await notifier.loadViewMode();
      expect(notifier.viewMode.value, ViewMode.grid);
    });

    test("uses scoped key with context", () async {
      SharedPreferences.setMockInitialValues(
          {"view_mode_preference_viewer": "list"});
      await notifier.loadViewMode(context: "viewer");
      expect(notifier.viewMode.value, ViewMode.list);
    });
  });

  group("loadDisplayMode / setDisplayMode", () {
    test("loadDisplayMode reads saved preference", () async {
      SharedPreferences.setMockInitialValues(
          {"display_mode_preference": "compact"});
      await notifier.loadDisplayMode();
      expect(notifier.displayMode.value, DisplayMode.compact);
      expect(notifier.isLoadingDisplayMode.value, false);
    });

    test("loadDisplayMode defaults to standard", () async {
      await notifier.loadDisplayMode();
      expect(notifier.displayMode.value, DisplayMode.standard);
      expect(notifier.isLoadingDisplayMode.value, false);
    });

    test("setDisplayMode updates signal and persists", () async {
      await notifier.setDisplayMode(DisplayMode.extended);
      expect(notifier.displayMode.value, DisplayMode.extended);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString("display_mode_preference"), "extended");
    });
  });

  group("getFilteredAndSortedItems", () {
    final items = [
      _makeLink("1", "https://alpha.com"),
      _makeLink("2", "https://beta.com"),
      _makeDocument("3", "Gamma doc"),
      _makeFolder("4"),
    ];

    test("returns all items when no filters applied", () {
      final result = notifier.getFilteredAndSortedItems(
        items: items,
        query: "",
        enableTagFiltering: false,
      );
      expect(result.length, 4);
    });

    test("filters by type", () {
      notifier.setSelectedTypes({FolderItemType.link});
      final result = notifier.getFilteredAndSortedItems(
        items: items,
        query: "",
        enableTagFiltering: false,
      );
      expect(result.length, 2);
      expect(result.every((i) => i.type == FolderItemType.link), true);
    });

    test("filters by search query", () {
      final result = notifier.getFilteredAndSortedItems(
        items: items,
        query: "alpha",
        enableTagFiltering: false,
      );
      expect(result.length, 1);
    });

    test("sorts by name ascending", () {
      notifier.setSortMode(SortMode.nameAsc);
      final result = notifier.getFilteredAndSortedItems(
        items: items,
        query: "",
        enableTagFiltering: false,
      );
      // Case-sensitive: "Gamma doc" (G=71) < "folder-4" (f=102)
      // < "https://alpha.com" < "https://beta.com"
      expect(result.first.type, FolderItemType.document);
    });

    test("sorts by name descending", () {
      notifier.setSortMode(SortMode.nameDesc);
      final linkItems = [
        _makeLink("1", "https://alpha.com"),
        _makeLink("2", "https://zeta.com"),
      ];
      final result = notifier.getFilteredAndSortedItems(
        items: linkItems,
        query: "",
        enableTagFiltering: false,
      );
      expect(result.first.id, "2"); // zeta before alpha
    });
  });

  group("getItemCounts", () {
    test("counts items by type", () {
      final items = [
        _makeLink("1", "https://a.com"),
        _makeLink("2", "https://b.com"),
        _makeDocument("3", "Doc"),
        _makeFolder("4"),
      ];
      final counts = getItemCounts(items);
      expect(counts[FolderItemType.link], 2);
      expect(counts[FolderItemType.document], 1);
      expect(counts[FolderItemType.folder], 1);
    });

    test("returns zeros for empty list", () {
      final counts = getItemCounts([]);
      expect(counts[FolderItemType.link], 0);
      expect(counts[FolderItemType.document], 0);
      expect(counts[FolderItemType.folder], 0);
    });
  });

  group("collectAllTags", () {
    test("collects unique tags from items", () {
      final tag1 = Tag(id: "t1", name: "flutter", createdAt: _epoch);
      final tag2 = Tag(id: "t2", name: "dart", createdAt: _epoch);
      final items = [
        FolderItem.link(
          id: "1",
          url: "https://a.com",
          tags: [tag1, tag2],
          createdAt: _epoch,
        ),
        FolderItem.link(
          id: "2",
          url: "https://b.com",
          tags: [tag1], // duplicate tag
          createdAt: _epoch,
        ),
      ];

      final tags = collectAllTags(items);
      expect(tags.length, 2); // deduplicated
      expect(tags.map((t) => t.name), containsAll(["flutter", "dart"]));
    });

    test("returns empty for items with no tags", () {
      final items = [_makeLink("1", "https://a.com")];
      final tags = collectAllTags(items);
      expect(tags, isEmpty);
    });
  });

  group("dispose", () {
    test("disposes owned search filter", () {
      final ownedFilter = SearchFilter();
      ownedFilter.setup();
      final ownedTagState = TagFilterState();

      final n = FilterableItemDisplayNotifier(
        initialViewMode: ViewMode.grid,
        initialSortMode: SortMode.nameAsc,
        initialSelectedTypes: {FolderItemType.link},
        initialDisplayMode: DisplayMode.standard,
        searchFilter: ownedFilter,
        ownsSearchFilter: true,
        tagFilterState: ownedTagState,
        ownsTagFilterState: true,
      );

      // Should not throw
      n.dispose();
    });

    test("does not dispose external search filter", () {
      // The notifier created in setUp has ownsSearchFilter = false
      // After dispose, the external filter should still be usable
      notifier.dispose();

      // External filter still works
      expect(() => searchFilter.query, returnsNormally);

      // Recreate notifier for tearDown
      notifier = FilterableItemDisplayNotifier(
        initialViewMode: ViewMode.grid,
        initialSortMode: SortMode.nameAsc,
        initialSelectedTypes: {FolderItemType.link},
        initialDisplayMode: DisplayMode.standard,
        searchFilter: searchFilter,
        ownsSearchFilter: false,
        tagFilterState: tagFilterState,
        ownsTagFilterState: false,
      );
    });
  });
}
