import "package:chenron/locator.dart";
import "package:chenron/shared/dialogs/bulk_tag_dialog.dart";
import "package:database/database.dart";
import "package:database/main.dart";
import "package:drift/native.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:signals/signals.dart";

import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(
      queryExecutor: NativeDatabase.memory(),
      setupOnInit: true,
    );
    await database.setup();

    await locator.reset();
    locator.registerSingleton<Signal<AppDatabaseHandler>>(
      signal(_TestAppDatabaseHandler(database)),
    );
  });

  tearDown(() async {
    await locator.reset();
    await database.delete(database.links).go();
    await database.delete(database.metadataRecords).go();
    await database.delete(database.tags).go();
    await database.close();
  });

  Widget buildApp({required Widget child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  /// Helper to open the dialog and wait for it to load tags from DB.
  ///
  /// Uses multiple [pump] calls instead of [pumpAndSettle] because the
  /// autofocused [TextField] cursor blink animation never settles.
  /// The in-memory [NativeDatabase] completes queries synchronously via
  /// FFI, so two pumps are enough: one to show the dialog and start
  /// `_loadTags()`, and one to flush the resulting [setState].
  Future<void> openDialog(
    WidgetTester tester, {
    required List<FolderItem> items,
  }) async {
    await tester.pumpWidget(buildApp(
      child: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showBulkTagDialog(context: context, items: items),
          child: const Text("Open"),
        ),
      ),
    ));

    await tester.tap(find.text("Open"));
    await tester.pump(); // show dialog, trigger initState + _loadTags()
    await tester.pump(); // flush setState from _loadTags() completion
  }

  group("BulkTagDialog rendering", () {
    testWidgets("shows title with item count", (tester) async {
      await openDialog(tester, items: [
        const FolderItem.link(url: "https://example.com"),
        const FolderItem.link(url: "https://example.com/2"),
      ]);

      expect(find.text("Manage tags for 2 items"), findsOneWidget);
    });

    testWidgets("shows 'Tag editor' when no items", (tester) async {
      await openDialog(tester, items: []);

      expect(find.text("Tag editor"), findsOneWidget);
    });

    testWidgets("shows search field", (tester) async {
      await openDialog(tester, items: []);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text("Search or type new tag..."), findsOneWidget);
    });

    testWidgets("shows 'No tags yet' when database has no tags",
        (tester) async {
      await openDialog(tester, items: []);

      expect(find.text("No tags yet"), findsOneWidget);
    });

    testWidgets("shows existing tags from database", (tester) async {
      // Seed tags in database
      await database.addTag("flutter");
      await database.addTag("dart");

      await openDialog(tester, items: []);

      expect(find.text("flutter"), findsOneWidget);
      expect(find.text("dart"), findsOneWidget);
    });

    testWidgets("shows coverage counts when items have tags",
        (tester) async {
      // Create links with tags
      await database.createLink(
        link: "https://example.com/1",
        tags: [Metadata(value: "flutter", type: MetadataTypeEnum.tag)],
      );
      await database.createLink(link: "https://example.com/2");

      // Build items matching what was created
      final allLinks = await database.select(database.links).get();
      final items = allLinks
          .map((l) => FolderItem.link(
                id: l.id,
                url: l.path,
                tags: [
                  if (l.path == "https://example.com/1")
                    Tag(
                        id: "t",
                        createdAt: DateTime.now(),
                        name: "flutter"),
                ],
              ))
          .toList();

      await openDialog(tester, items: items);

      expect(find.text("1/2 already"), findsOneWidget);
    });

    testWidgets("shows 'all have it' when all items have a tag",
        (tester) async {
      await database.addTag("common");

      final items = [
        FolderItem.link(
          url: "https://example.com",
          tags: [
            Tag(id: "t", createdAt: DateTime.now(), name: "common"),
          ],
        ),
      ];

      await openDialog(tester, items: items);

      expect(find.text("all have it"), findsOneWidget);
    });
  });

  group("BulkTagDialog interaction", () {
    testWidgets("Apply button disabled when nothing selected",
        (tester) async {
      await openDialog(tester, items: []);

      final applyButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, "Apply"),
      );
      expect(applyButton.onPressed, isNull);
    });

    testWidgets("selecting a tag enables Apply button", (tester) async {
      await database.addTag("flutter");

      await openDialog(tester, items: []);

      // Tap the tag row
      await tester.tap(find.text("flutter"));
      await tester.pump();

      // Button should show "Apply (+1)" and be enabled
      final applyButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, "Apply (+1)"),
      );
      expect(applyButton.onPressed, isNotNull);
    });

    testWidgets("selecting multiple tags updates button text",
        (tester) async {
      await database.addTag("flutter");
      await database.addTag("dart");

      await openDialog(tester, items: []);

      await tester.tap(find.text("flutter"));
      await tester.pump();
      await tester.tap(find.text("dart"));
      await tester.pump();

      expect(find.text("Apply (+2)"), findsOneWidget);
    });

    testWidgets("toggling tag off deselects it", (tester) async {
      await database.addTag("flutter");

      await openDialog(tester, items: []);

      // Select
      await tester.tap(find.text("flutter"));
      await tester.pump();
      expect(find.text("Apply (+1)"), findsOneWidget);

      // Deselect (add → neutral since no items have it)
      await tester.tap(find.text("flutter"));
      await tester.pump();
      expect(find.text("Apply"), findsOneWidget);
    });

    testWidgets("search filters tags", (tester) async {
      await database.addTag("flutter");
      await database.addTag("dart");
      await database.addTag("mobile");

      await openDialog(tester, items: []);

      // Type in search
      await tester.enterText(find.byType(TextField), "flu");
      await tester.pump();

      expect(find.text("flutter"), findsOneWidget);
      expect(find.text("dart"), findsNothing);
      expect(find.text("mobile"), findsNothing);
    });

    testWidgets("shows 'Create' button for new tag", (tester) async {
      await openDialog(tester, items: []);

      await tester.enterText(find.byType(TextField), "newtag");
      await tester.pump();

      expect(find.textContaining('Create "newtag"'), findsOneWidget);
    });

    testWidgets("does not show Create button when tag exists",
        (tester) async {
      await database.addTag("flutter");

      await openDialog(tester, items: []);

      await tester.enterText(find.byType(TextField), "flutter");
      await tester.pump();

      expect(find.textContaining("Create"), findsNothing);
    });

    testWidgets("creating new tag adds chip", (tester) async {
      await openDialog(tester, items: []);

      await tester.enterText(find.byType(TextField), "newtag");
      await tester.pump();

      await tester.tap(find.textContaining('Create "newtag"'));
      await tester.pump();

      expect(find.text("+newtag (new)"), findsOneWidget);
      expect(find.text("Apply (+1)"), findsOneWidget);
    });

    testWidgets("chip can be removed", (tester) async {
      await database.addTag("flutter");

      await openDialog(tester, items: []);

      // Select a tag
      await tester.tap(find.text("flutter"));
      await tester.pump();

      expect(find.text("+flutter"), findsOneWidget);

      // Remove the chip by tapping its delete icon.
      final chipFinder = find.ancestor(
        of: find.text("+flutter"),
        matching: find.byType(InputChip),
      );
      final deleteIcon = find.descendant(
        of: chipFinder,
        matching: find.byType(Icon),
      );
      await tester.tap(deleteIcon.last);
      await tester.pump();

      // Chip should be gone, button disabled
      expect(find.text("+flutter"), findsNothing);
      expect(find.text("Apply"), findsOneWidget);
    });

    testWidgets("cancel returns null", (tester) async {
      BulkTagResult? result;
      bool wasCalled = false;
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showBulkTagDialog(
                context: context,
                items: const [],
              );
              wasCalled = true;
            },
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text("Cancel"));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(wasCalled, isTrue);
      expect(result, isNull);
    });

    testWidgets("confirm returns BulkTagResult with selected tags",
        (tester) async {
      await database.addTag("flutter");
      await database.addTag("dart");

      BulkTagResult? result;
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showBulkTagDialog(
                context: context,
                items: const [],
              );
            },
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text("flutter"));
      await tester.pump();
      await tester.tap(find.text("dart"));
      await tester.pump();

      await tester.tap(find.text("Apply (+2)"));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(result, isNotNull);
      expect(result!.tagsToAdd, containsAll(["flutter", "dart"]));
      expect(result!.tagsToRemove, isEmpty);
    });

    testWidgets("validates new tag creation", (tester) async {
      await openDialog(tester, items: []);

      // Type invalid tag (too short)
      await tester.enterText(find.byType(TextField), "ab");
      await tester.pump();

      // Try to create it
      await tester.tap(find.textContaining('Create "ab"'));
      await tester.pump();

      // Should show validation error
      expect(find.textContaining("3-12"), findsOneWidget);
    });
  });

  group("BulkTagDialog tri-state toggle", () {
    testWidgets("tag with no coverage: neutral → add → neutral",
        (tester) async {
      await database.addTag("flutter");

      // No items have "flutter"
      await openDialog(tester, items: [
        const FolderItem.link(url: "https://example.com"),
      ]);

      // Tap to add
      await tester.tap(find.text("flutter"));
      await tester.pump();
      expect(find.text("+flutter"), findsOneWidget);
      expect(find.text("Apply (+1)"), findsOneWidget);

      // Tap again → back to neutral (no items have it, so skip remove)
      await tester.tap(find.text("flutter"));
      await tester.pump();
      expect(find.text("+flutter"), findsNothing);
      expect(find.text("Apply"), findsOneWidget);
    });

    testWidgets("tag with partial coverage: neutral → add → remove → neutral",
        (tester) async {
      await database.addTag("flutter");

      final items = [
        FolderItem.link(
          url: "https://example.com/1",
          tags: [
            Tag(id: "t1", createdAt: DateTime.now(), name: "flutter"),
          ],
        ),
        const FolderItem.link(url: "https://example.com/2"),
      ];

      await openDialog(tester, items: items);

      // Tap 1: neutral → add
      await tester.tap(find.text("flutter"));
      await tester.pump();
      expect(find.text("+flutter"), findsOneWidget);

      // Tap 2: add → remove (some items have it)
      await tester.tap(find.text("flutter"));
      await tester.pump();
      expect(find.text("-flutter"), findsOneWidget);
      expect(find.text("Apply (-1)"), findsOneWidget);

      // Tap 3: remove → neutral
      await tester.tap(find.text("flutter"));
      await tester.pump();
      expect(find.text("-flutter"), findsNothing);
      expect(find.text("Apply"), findsOneWidget);
    });

    testWidgets("tag with full coverage: neutral → remove → neutral",
        (tester) async {
      await database.addTag("common");

      final items = [
        FolderItem.link(
          url: "https://example.com",
          tags: [
            Tag(id: "t1", createdAt: DateTime.now(), name: "common"),
          ],
        ),
      ];

      await openDialog(tester, items: items);

      // Tap 1: neutral → remove (all have it)
      await tester.tap(find.text("common"));
      await tester.pump();
      expect(find.text("-common"), findsOneWidget);
      expect(find.text("Apply (-1)"), findsOneWidget);

      // Tap 2: remove → neutral
      await tester.tap(find.text("common"));
      await tester.pump();
      expect(find.text("-common"), findsNothing);
      expect(find.text("Apply"), findsOneWidget);
    });

    testWidgets("mixed add and remove shows combined label",
        (tester) async {
      await database.addTag("keep");
      await database.addTag("remove_me");

      final items = [
        FolderItem.link(
          url: "https://example.com",
          tags: [
            Tag(id: "t1", createdAt: DateTime.now(), name: "remove_me"),
          ],
        ),
      ];

      await openDialog(tester, items: items);

      // Add "keep"
      await tester.tap(find.text("keep"));
      await tester.pump();

      // Remove "remove_me" (all have it → goes to remove)
      await tester.tap(find.text("remove_me"));
      await tester.pump();

      expect(find.text("Apply (+1, -1)"), findsOneWidget);
    });

    testWidgets("confirm returns both adds and removes", (tester) async {
      await database.addTag("new_tag");
      await database.addTag("old_tag");

      BulkTagResult? result;
      final items = [
        FolderItem.link(
          url: "https://example.com",
          tags: [
            Tag(id: "t1", createdAt: DateTime.now(), name: "old_tag"),
          ],
        ),
      ];

      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showBulkTagDialog(
                context: context,
                items: items,
              );
            },
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pump();
      await tester.pump();

      // Add new_tag
      await tester.tap(find.text("new_tag"));
      await tester.pump();

      // Remove old_tag (all have it → remove)
      await tester.tap(find.text("old_tag"));
      await tester.pump();

      // Confirm
      await tester.tap(find.text("Apply (+1, -1)"));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(result, isNotNull);
      expect(result!.tagsToAdd, ["new_tag"]);
      expect(result!.tagsToRemove, ["old_tag"]);
    });
  });

  group("BulkTagDialog lifecycle", () {
    testWidgets("close button dismisses dialog", (tester) async {
      await openDialog(tester, items: []);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text("Tag editor"), findsNothing);
    });
  });
}

class _TestAppDatabaseHandler extends AppDatabaseHandler {
  final AppDatabase _testDb;

  _TestAppDatabaseHandler(this._testDb);

  @override
  AppDatabase get appDatabase => _testDb;
}
