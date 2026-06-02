import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:database/database.dart";
import "package:chenron/locator.dart";
import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/state/display_settings.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/unified_item.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/viewer_item.dart";

final _epoch = DateTime(2024, 1, 1);

/// [ConfigService] reaches into the locator in its field initializers, so
/// a [Fake] stands in — [DisplaySettingsNotifier] never calls it for the
/// default snapshot the time display reads.
class _FakeConfigService extends Fake implements ConfigService {}

/// The item meta row's clock reads
/// `SettingsCoordinator.display.current.value.timeDisplayFormat`, which is
/// the only member exercised here. The default `DisplaySettings()` has a
/// valid format index, so no DB / config wiring is needed.
class _FakeSettingsCoordinator extends Fake implements SettingsCoordinator {
  @override
  final DisplaySettingsNotifier display =
      DisplaySettingsNotifier(_FakeConfigService());
}

Tag _tag(String id, String name) => Tag(id: id, name: name, createdAt: _epoch);

FolderItem _folderWithTags(String id, List<Tag> tags) => FolderItem.folder(
      id: id,
      folderId: "folder-$id",
      title: "Folder $id",
      tags: tags,
    );

/// Matches the private expanded-tag overlay panel by its type name.
final _expandedPanel = find.byWidgetPredicate(
  (w) => w.runtimeType.toString() == "_ExpandedTagPanel",
);

void main() {
  setUp(() async {
    await locator.reset();
    locator.registerSingleton<SettingsCoordinator>(_FakeSettingsCoordinator());
  });

  tearDown(() async {
    await locator.reset();
  });

  // Folder items resolve to an empty URL, so [UnifiedItem] never touches
  // the metadata signal / locator — keeps this a pure widget test. They
  // still render the compressed tag-count chip that drives expansion.
  Widget host(FolderItem item) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 280,
            // A stable key forces Flutter to reuse the same State across
            // pumps with different items — exactly how a ListView recycles
            // a row's State for a new item.
            child: UnifiedItem(
              key: const ValueKey("recycled-row"),
              item: item,
              mode: PreviewMode.card,
              showImage: false,
            ),
          ),
        ),
      );

  testWidgets("tag expansion does not bleed onto a recycled row", (
    tester,
  ) async {
    final itemA = _folderWithTags("a", [_tag("t1", "alpha"), _tag("t2", "beta")]);
    final itemB = _folderWithTags("b", [_tag("t3", "gamma"), _tag("t4", "delta")]);

    await tester.pumpWidget(host(itemA));

    // Expand item A's tags by tapping the tag-count chip.
    await tester.tap(find.byIcon(Icons.sell_outlined));
    await tester.pump();
    expect(_expandedPanel, findsOneWidget,
        reason: "tapping the tag chip should expand A's tags");

    // Recycle the same State for a different item (same key/position).
    await tester.pumpWidget(host(itemB));
    await tester.pump();

    // The overlay must be collapsed for B — it should not inherit A's
    // expanded state.
    expect(_expandedPanel, findsNothing,
        reason: "recycled row B must start with tags collapsed");
  });
}
