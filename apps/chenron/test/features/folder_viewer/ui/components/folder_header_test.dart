import "package:database/database.dart";
import "package:database/main.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get_it/get_it.dart";
import "package:signals/signals.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/folder_viewer/ui/components/folder_header.dart";
import "package:chenron_mockups/chenron_mockups.dart";

class _MockConfigDbHandler extends ConfigDatabaseFileHandler {
  final ConfigDatabase _db;
  _MockConfigDbHandler(this._db);

  @override
  ConfigDatabase get configDatabase => _db;
}

void main() {
  late ConfigDatabase configDb;

  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  setUp(() async {
    if (GetIt.I.isRegistered<Signal<ConfigDatabaseFileHandler>>()) {
      await GetIt.I.reset();
    }

    configDb = ConfigDatabase(
      databaseName: "test_config_db",
      setupOnInit: true,
      debugMode: true,
    );
    await configDb.setup();

    final handler = _MockConfigDbHandler(configDb);
    GetIt.I.registerSingleton<Signal<ConfigDatabaseFileHandler>>(
      signal(handler),
    );
    GetIt.I.registerLazySingleton<ConfigService>(ConfigService.new);
    GetIt.I.registerLazySingleton<DataSettingsService>(DataSettingsService.new);
    GetIt.I.registerLazySingleton<ConfigController>(ConfigController.new);
  });

  tearDown(() async {
    await configDb.close();
    if (GetIt.I.isRegistered<Signal<ConfigDatabaseFileHandler>>()) {
      await GetIt.I.reset();
    }
  });
  Folder makeFolder({
    String title = "Test Folder",
    String description = "",
    DateTime? createdAt,
  }) {
    return Folder(
      id: "folder-id",
      title: title,
      description: description,
      createdAt: createdAt ?? DateTime(2025, 1, 15, 10, 30),
      updatedAt: DateTime.now(),
    );
  }

  Tag makeTag(String name) {
    return Tag(id: "tag-$name", name: name, createdAt: DateTime.now());
  }

  Widget buildHeader({
    Folder? folder,
    List<Tag> tags = const [],
    int totalItems = 0,
    VoidCallback? onBack,
    VoidCallback? onHome,
    bool isExpanded = true,
    VoidCallback? onToggle,
    bool isLocked = false,
    VoidCallback? onToggleLock,
    ValueChanged<String>? onTagTap,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: FolderHeader(
            folder: folder ?? makeFolder(),
            tags: tags,
            totalItems: totalItems,
            onBack: onBack ?? () {},
            onHome: onHome ?? () {},
            isExpanded: isExpanded,
            onToggle: onToggle ?? () {},
            isLocked: isLocked,
            onToggleLock: onToggleLock ?? () {},
            onTagTap: onTagTap,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }

  group("FolderHeader rendering", () {
    testWidgets("displays folder title", (tester) async {
      await tester.pumpWidget(buildHeader(
        folder: makeFolder(title: "My Collection"),
      ));
      await tester.pumpAndSettle();

      expect(find.text("My Collection"), findsOneWidget);
    });

    testWidgets("displays item count", (tester) async {
      await tester.pumpWidget(buildHeader(totalItems: 42));
      await tester.pumpAndSettle();

      expect(find.text("42 items"), findsOneWidget);
    });

    testWidgets("displays description when non-empty", (tester) async {
      await tester.pumpWidget(buildHeader(
        folder: makeFolder(description: "A test folder for testing"),
      ));
      await tester.pumpAndSettle();

      expect(find.text("A test folder for testing"), findsOneWidget);
    });

    testWidgets("does not display description when empty", (tester) async {
      await tester.pumpWidget(buildHeader(
        folder: makeFolder(description: ""),
      ));
      await tester.pumpAndSettle();

      // Only folder title and metadata should be present
      expect(find.text("Test Folder"), findsOneWidget);
    });

    testWidgets("displays tags as chips", (tester) async {
      await tester.pumpWidget(buildHeader(
        tags: [makeTag("flutter"), makeTag("dart"), makeTag("test")],
      ));
      await tester.pumpAndSettle();

      expect(find.text("flutter"), findsOneWidget);
      expect(find.text("dart"), findsOneWidget);
      expect(find.text("test"), findsOneWidget);
    });

    testWidgets("does not render tags area when empty", (tester) async {
      await tester.pumpWidget(buildHeader(tags: []));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.tag), findsNothing);
    });

    testWidgets("shows edit button when onEdit provided", (tester) async {
      await tester.pumpWidget(buildHeader(onEdit: () {}));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets("hides edit button when onEdit is null", (tester) async {
      await tester.pumpWidget(buildHeader(onEdit: null));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets("shows delete button when onDelete provided", (tester) async {
      await tester.pumpWidget(buildHeader(onDelete: () {}));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets("hides delete button when onDelete is null", (tester) async {
      await tester.pumpWidget(buildHeader(onDelete: null));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets("shows lock icon when locked", (tester) async {
      await tester.pumpWidget(buildHeader(isLocked: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets("shows unlock icon when unlocked", (tester) async {
      await tester.pumpWidget(buildHeader(isLocked: false));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_open), findsOneWidget);
    });

    testWidgets("shows collapse icon when expanded", (tester) async {
      await tester.pumpWidget(buildHeader(isExpanded: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });

    testWidgets("shows expand icon when collapsed", (tester) async {
      await tester.pumpWidget(buildHeader(isExpanded: false));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets("displays created date", (tester) async {
      await tester.pumpWidget(buildHeader(
        folder: makeFolder(createdAt: DateTime(2025, 3, 15, 14, 30)),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining("Created:"), findsOneWidget);
    });
  });

  group("FolderHeader interaction", () {
    testWidgets("calls onBack when back button tapped", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildHeader(
        onBack: () => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(wasCalled, true);
    });

    testWidgets("calls onHome when home button tapped", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildHeader(
        onHome: () => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      expect(wasCalled, true);
    });

    testWidgets("calls onEdit when edit button tapped", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildHeader(
        onEdit: () => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(wasCalled, true);
    });

    testWidgets("calls onDelete when delete button tapped", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildHeader(
        onDelete: () => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(wasCalled, true);
    });

    testWidgets("calls onToggleLock when lock button tapped", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildHeader(
        onToggleLock: () => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.lock_open));
      await tester.pumpAndSettle();

      expect(wasCalled, true);
    });

    testWidgets("calls onToggle when expand button tapped", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildHeader(
        isExpanded: true,
        onToggle: () => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.expand_less));
      await tester.pumpAndSettle();

      expect(wasCalled, true);
    });

    testWidgets("expand button disabled when locked", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildHeader(
        isLocked: true,
        onToggle: () => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      // The expand/collapse button should be visually dimmed and not respond
      final expandIcon = find.byIcon(Icons.expand_less);
      await tester.tap(expandIcon);
      await tester.pumpAndSettle();

      expect(wasCalled, false);
    });

    testWidgets("calls onTagTap when tag tapped", (tester) async {
      String? tappedTag;
      await tester.pumpWidget(buildHeader(
        tags: [makeTag("flutter")],
        onTagTap: (tag) => tappedTag = tag,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text("flutter"));
      await tester.pumpAndSettle();

      expect(tappedTag, "flutter");
    });
  });
}
