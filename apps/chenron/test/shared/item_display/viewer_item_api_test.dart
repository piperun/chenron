import "package:chenron/shared/item_display/widgets/viewer_item/viewer_item.dart";
import "package:database/models/item.dart";
import "package:flutter_test/flutter_test.dart";

/// Regression guard for the [ViewerItem] hoist refactor.
///
/// [ViewerItem] used to wrap its build in a `Watch` that read four config
/// signals (`showImages`, `showDescription`, `showTags`, `showCopyLink`) — on
/// a grid of 100 cards that meant 100 listeners on each signal. The fix
/// hoisted the `Watch` up to [ItemGridView] / [ItemListView] and made
/// [ViewerItem] accept the already-resolved primitives instead.
///
/// This test exists to fail loudly if anyone tries to re-introduce a
/// `ConfigController` / `displayMode` / `Watch` dependency at the cell level.
/// The constructor is now the API contract: resolved primitives only.
void main() {
  test("ViewerItem constructor accepts only resolved display primitives", () {
    const widget = ViewerItem(
      item: FolderItem.link(url: "https://example.com"),
      mode: PreviewMode.card,
      showImage: true,
      showCopyLink: false,
      maxTags: 3,
      titleLines: 2,
      descriptionLines: 2,
    );

    expect(widget.showImage, isTrue);
    expect(widget.showCopyLink, isFalse);
    expect(widget.maxTags, 3);
    expect(widget.titleLines, 2);
    expect(widget.descriptionLines, 2);
    expect(widget.mode, PreviewMode.card);
  });

  test("ViewerItem applies defaults for optional fields only", () {
    const widget = ViewerItem(
      item: FolderItem.link(url: "https://example.com"),
      showImage: false,
      showCopyLink: false,
      maxTags: 0,
      titleLines: 1,
      descriptionLines: 0,
    );

    // mode defaults to card; tag-name sets default to empty.
    expect(widget.mode, PreviewMode.card);
    expect(widget.includedTagNames, isEmpty);
    expect(widget.excludedTagNames, isEmpty);
    expect(widget.onTap, isNull);
    expect(widget.onTagFilterTap, isNull);
  });
}
