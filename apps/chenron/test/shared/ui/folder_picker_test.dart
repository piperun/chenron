import "package:database/main.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/shared/ui/folder_picker.dart";
import "package:database/database.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:signals/signals.dart";
import "package:get_it/get_it.dart";
import "dart:io";

class _MockAppDatabaseHandler implements AppDatabaseHandler {
  @override
  final AppDatabase appDatabase;

  _MockAppDatabaseHandler(this.appDatabase);

  @override
  DatabaseLocation? databaseLocation;

  @override
  Future<File?> backupDatabase() => throw UnimplementedError();

  @override
  Future<void> closeDatabase() async {}

  @override
  Future<void> createDatabase(
      {String? databaseName,
      File? databasePath,
      bool setupOnInit = false}) async {}

  @override
  Future<File?> exportDatabase(Directory exportPath) =>
      throw UnimplementedError();

  @override
  Future<File?> importDatabase(File dbFile,
          {required bool copyImport, bool setupOnInit = true}) =>
      throw UnimplementedError();

  @override
  Future<void> reloadDatabase() async {}
}

void main() {
  late MockDatabaseHelper mockDb;

  setUpAll(installTestLogger);

  setUp(() async {
    mockDb = MockDatabaseHelper();
    await mockDb.setup(setupOnInit: true);

    if (GetIt.I.isRegistered<Signal<AppDatabaseHandler>>()) {
      await GetIt.I.reset();
    }

    final mockHandler = _MockAppDatabaseHandler(mockDb.database);
    GetIt.I.registerSingleton<Signal<AppDatabaseHandler>>(
      signal<AppDatabaseHandler>(mockHandler),
    );
  });

  tearDown(() async {
    await mockDb.dispose();
    if (GetIt.I.isRegistered<Signal<AppDatabaseHandler>>()) {
      await GetIt.I.reset();
    }
  });

  Folder makeFolder(String id, String title) {
    return Folder(
      id: id,
      title: title,
      description: "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Widget buildPicker({
    List<Folder>? initialFolders,
    void Function(List<Folder>)? onFoldersSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: FolderPicker(
          initialFolders: initialFolders,
          onFoldersSelected: onFoldersSelected ?? (_) {},
        ),
      ),
    );
  }

  group("FolderPicker with initialFolders", () {
    testWidgets("displays initial folders as chips", (tester) async {
      await tester.pumpWidget(
          buildPicker(initialFolders: [makeFolder("id-1", "My Folder")]));
      await tester.pumpAndSettle();

      expect(find.text("My Folder"), findsOneWidget);
      expect(find.text("Add Folder"), findsOneWidget);
    });

    testWidgets("displays multiple initial folders", (tester) async {
      await tester.pumpWidget(buildPicker(initialFolders: [
        makeFolder("id-1", "Folder One"),
        makeFolder("id-2", "Folder Two"),
      ]));
      await tester.pumpAndSettle();

      expect(find.text("Folder One"), findsOneWidget);
      expect(find.text("Folder Two"), findsOneWidget);
    });

    testWidgets("does not call onFoldersSelected during init",
        (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildPicker(
        initialFolders: [makeFolder("id-1", "Test")],
        onFoldersSelected: (_) => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      expect(wasCalled, false);
    });

    testWidgets("shows delete icon only when multiple folders selected",
        (tester) async {
      await tester.pumpWidget(
          buildPicker(initialFolders: [makeFolder("id-1", "Solo")]));
      await tester.pumpAndSettle();

      final chip = tester.widget<Chip>(find.byType(Chip));
      expect(chip.onDeleted, isNull);
    });

    testWidgets("renders Selected Folders label", (tester) async {
      await tester.pumpWidget(
          buildPicker(initialFolders: [makeFolder("id-1", "Test")]));
      await tester.pumpAndSettle();

      expect(find.text("Selected Folders"), findsOneWidget);
    });
  });

  group("FolderPicker without initialFolders", () {
    testWidgets("loads default folder from database", (tester) async {
      await mockDb.createTestFolder(title: "default");

      await tester.pumpWidget(buildPicker());
      await tester.pumpAndSettle();

      expect(find.text("default"), findsOneWidget);
      expect(find.text("Add Folder"), findsOneWidget);
    });

    testWidgets("calls onFoldersSelected after loading from DB",
        (tester) async {
      List<Folder>? selectedFolders;
      await mockDb.createTestFolder(title: "default");

      await tester.pumpWidget(buildPicker(
        onFoldersSelected: (folders) => selectedFolders = folders,
      ));
      await tester.pumpAndSettle();

      expect(selectedFolders, isNotNull);
      expect(selectedFolders!.length, 1);
      expect(selectedFolders!.first.title, "default");
    });
  });

  group("FolderPicker chip interaction", () {
    testWidgets("removes folder chip when delete tapped (multi-select)",
        (tester) async {
      final folders = [
        makeFolder("id-1", "Folder A"),
        makeFolder("id-2", "Folder B"),
      ];

      List<Folder>? updatedFolders;
      await tester.pumpWidget(buildPicker(
        initialFolders: folders,
        onFoldersSelected: (f) => updatedFolders = f,
      ));
      await tester.pumpAndSettle();

      // Find the delete icon on "Folder A" chip
      final chipA = find.widgetWithText(Chip, "Folder A");
      final deleteIcon = find.descendant(
        of: chipA,
        matching: find.byIcon(Icons.cancel),
      );
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      expect(updatedFolders, isNotNull);
      expect(updatedFolders!.length, 1);
      expect(updatedFolders!.first.title, "Folder B");
    });
  });

  group("FolderSelectionDialog", () {
    testWidgets("opens selection dialog when Add Folder tapped",
        (tester) async {
      await mockDb.createTestFolder(title: "default");

      await tester.pumpWidget(buildPicker());
      await tester.pumpAndSettle();

      await tester.tap(find.text("Add Folder"));
      await tester.pumpAndSettle();

      expect(find.text("Select Folders"), findsOneWidget);
      expect(find.text("Search folders..."), findsOneWidget);
    });

    testWidgets("Cancel closes dialog without changes", (tester) async {
      await mockDb.createTestFolder(title: "default");

      int callCount = 0;
      await tester.pumpWidget(buildPicker(
        onFoldersSelected: (_) => callCount++,
      ));
      await tester.pumpAndSettle();

      final initialCount = callCount;

      await tester.tap(find.text("Add Folder"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();

      expect(callCount, initialCount);
    });

    testWidgets("prevents deselecting last folder", (tester) async {
      await mockDb.createTestFolder(title: "default");

      await tester.pumpWidget(buildPicker());
      await tester.pumpAndSettle();

      await tester.tap(find.text("Add Folder"));
      await tester.pumpAndSettle();

      // "default" is the only folder and should be checked
      final checkbox = find.byType(CheckboxListTile).first;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Should still be checked (minimum 1 required)
      final checkboxWidget =
          tester.widget<CheckboxListTile>(checkbox);
      expect(checkboxWidget.value, true);
    });
  });

  group("FolderPicker lifecycle", () {
    testWidgets("disposes without errors", (tester) async {
      await tester.pumpWidget(
          buildPicker(initialFolders: [makeFolder("id-1", "Test")]));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();
    });
  });
}
