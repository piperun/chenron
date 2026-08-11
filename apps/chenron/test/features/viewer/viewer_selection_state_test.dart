import "package:chenron/features/viewer/state/viewer_selection_state.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter_test/flutter_test.dart";

ViewerItemKey _key(FolderItemType type, String id) => (type: type, id: id);

void main() {
  late ViewerSelectionState state;

  setUp(() {
    state = ViewerSelectionState();
  });

  tearDown(() {
    state.dispose();
  });

  test("select-all retains only the query and count for 100,000 rows", () {
    const query = ViewerQuery(
      searchText: "generic",
      types: <FolderItemType>{FolderItemType.link},
    );

    state.synchronizeQuery(query);
    state.selectAllMatching(query, 100000);

    final selection = state.value as AllMatchingViewerSelection;
    expect(selection.query, same(query));
    expect(selection.totalCount, 100000);
    expect(selection.excluded, isEmpty);
    expect(state.selectedCount, 100000);
    expect(selection, isNot(isA<FolderItem>()));
  });

  test("three select-all exclusions retain exactly three typed keys", () {
    const query = ViewerQuery();
    final keys = <ViewerItemKey>[
      _key(FolderItemType.link, "same-id"),
      _key(FolderItemType.folder, "same-id"),
      _key(FolderItemType.document, "document-1"),
    ];

    state.synchronizeQuery(query);
    state.selectAllMatching(query, 100000);
    for (final key in keys) {
      state.toggle(key);
    }

    final selection = state.value as AllMatchingViewerSelection;
    expect(selection.excluded, equals(keys.toSet()));
    expect(selection.excluded, hasLength(3));
    expect(state.selectedCount, 99997);
    expect(state.isSelected(keys[0]), isFalse);
    expect(state.isSelected(keys[1]), isFalse);
  });

  test("an effective query change clears all selection", () {
    const first = ViewerQuery(searchText: "first");
    const second = ViewerQuery(searchText: "second");
    state.synchronizeQuery(first);
    state.selectAllMatching(first, 100000);

    state.synchronizeQuery(second);

    expect(state.value, isA<ExplicitViewerSelection>());
    expect((state.value as ExplicitViewerSelection).keys, isEmpty);
    expect(state.selectedCount, 0);
  });

  test("explicit selection retains immutable typed keys and exact count", () {
    const query = ViewerQuery();
    final linkKey = _key(FolderItemType.link, "same-id");
    final folderKey = _key(FolderItemType.folder, "same-id");
    state.synchronizeQuery(query);

    state.toggle(linkKey);
    state.toggle(folderKey);

    final selection = state.value as ExplicitViewerSelection;
    expect(selection.keys, equals(<ViewerItemKey>{linkKey, folderKey}));
    expect(selection.keys, hasLength(2));
    expect(state.selectedCount, 2);
    expect(state.isSelected(linkKey), isTrue);
    expect(state.isSelected(folderKey), isTrue);
    expect(
      () => selection.keys.add(_key(FolderItemType.link, "late")),
      throwsUnsupportedError,
    );

    state.toggle(linkKey);

    expect(state.selectedCount, 1);
    expect(state.isSelected(linkKey), isFalse);
    expect(state.isSelected(folderKey), isTrue);
  });

  test("select-all rejects a negative total count", () {
    const query = ViewerQuery();
    state.synchronizeQuery(query);

    expect(
      () => state.selectAllMatching(query, -1),
      throwsArgumentError,
    );
  });
}
