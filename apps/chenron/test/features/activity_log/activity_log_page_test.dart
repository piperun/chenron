import "dart:io";
import "dart:typed_data";

import "package:chenron/features/activity_log/pages/activity_log_page.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/features.dart";
import "package:file_picker/file_picker.dart";
// ignore: implementation_imports — platform-interface seam for stubbing
// the save dialog; not exported from the package barrel.
import "package:file_picker/src/platform/file_picker_platform_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:plugin_platform_interface/plugin_platform_interface.dart";

/// Returns a fixed [savePath] from [saveFile] so export tests can drive
/// the write path without a real platform file dialog.
class _StubFilePicker extends Fake
    with MockPlatformInterfaceMixin
    implements FilePickerPlatform {
  final String? savePath;
  _StubFilePicker(this.savePath);

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async =>
      savePath;
}

void main() {
  late MockDatabaseHelper mockDb;

  setUpAll(installTestLogger);

  setUp(() async {
    mockDb = MockDatabaseHelper();
    await mockDb.setup();
  });

  tearDown(() async {
    await mockDb.dispose();
    FilePickerPlatform.instance = _StubFilePicker(null);
  });

  Widget buildPage({
    Future<void> Function(String path, String contents)? fileWriter,
    Set<String> initialStatusFilters = const {},
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ActivityLogPage(
          database: mockDb.database,
          fileWriter: fileWriter,
          initialStatusFilters: initialStatusFilters,
        ),
      ),
    );
  }

  Future<void> seedMixedJobs() async {
    await mockDb.database.enqueueArchiveJob(
      linkId: "link-1",
      url: "https://archived.com",
      service: BackgroundJobService.archiveOrg,
    );
    await mockDb.database.recordMetadataFetch(
      url: "https://fetched-ok.com",
      succeeded: true,
      linkId: "link-2",
    );
    await mockDb.database.recordMetadataFetch(
      url: "https://fetched-failed.com",
      succeeded: false,
      error: "HTTP 503",
    );
  }

  // "View Log" failure-toast actions open the page with the failed
  // filter active — the user must land on the failures, not the full
  // unfiltered history.
  testWidgets("initialStatusFilters pre-selects the failed filter",
      (tester) async {
    await seedMixedJobs();
    await tester.pumpWidget(buildPage(
      initialStatusFilters: {BackgroundJobStatus.failed},
    ));
    await tester.pumpAndSettle();

    expect(find.text("https://fetched-failed.com"), findsOneWidget);
    expect(find.text("https://archived.com"), findsNothing);
    expect(find.text("https://fetched-ok.com"), findsNothing);
  });

  testWidgets("renders both Archive and Metadata filter chips", (tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text("Archive"), findsOneWidget);
    expect(find.text("Metadata"), findsOneWidget);
  });

  testWidgets("Metadata chip filters list to metadata_fetch entries",
      (tester) async {
    await seedMixedJobs();
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    // Unfiltered: all three URLs visible.
    expect(find.text("https://archived.com"), findsOneWidget);
    expect(find.text("https://fetched-ok.com"), findsOneWidget);
    expect(find.text("https://fetched-failed.com"), findsOneWidget);

    await tester.tap(find.text("Metadata"));
    await tester.pumpAndSettle();

    // Archive job hidden; metadata entries visible.
    expect(find.text("https://archived.com"), findsNothing);
    expect(find.text("https://fetched-ok.com"), findsOneWidget);
    expect(find.text("https://fetched-failed.com"), findsOneWidget);
  });

  testWidgets("metadata fetch entries show 'metadata' service badge",
      (tester) async {
    await mockDb.database.recordMetadataFetch(
      url: "https://x.com",
      succeeded: true,
    );
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text("metadata"), findsOneWidget);
  });

  testWidgets("Retry button hidden for failed metadata fetch entries",
      (tester) async {
    await mockDb.database.recordMetadataFetch(
      url: "https://broken.com",
      succeeded: false,
      error: "Timeout",
    );
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text("https://broken.com"), findsOneWidget);
    expect(find.byIcon(Icons.replay), findsNothing);
  });

  testWidgets("Retry button shown for failed archive jobs", (tester) async {
    final id = await mockDb.database.enqueueArchiveJob(
      linkId: "link-1",
      url: "https://archive-failed.com",
      service: BackgroundJobService.archiveOrg,
    );
    await mockDb.database.updateBackgroundJobStatus(
      id: id,
      status: BackgroundJobStatus.failed,
      error: "boom",
    );

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.replay), findsOneWidget);
  });

  group("Export error handling", () {
    testWidgets("a failing writer surfaces an error, not a crash",
        (tester) async {
      // One entry so the Export button is enabled.
      await mockDb.database.recordMetadataFetch(
        url: "https://x.com",
        succeeded: true,
      );
      FilePickerPlatform.instance = _StubFilePicker("/some/export.json");

      await tester.pumpWidget(buildPage(
        fileWriter: (path, contents) async => throw const FileSystemException(
          "Permission denied",
          "/some/export.json",
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Export"));
      await tester.pumpAndSettle();

      // Error surfaced via snackbar; the success snackbar never ran.
      expect(find.textContaining("File operation failed"), findsOneWidget);
      expect(find.textContaining("Exported"), findsNothing);
    });

    testWidgets("a successful write shows the success snackbar",
        (tester) async {
      await mockDb.database.recordMetadataFetch(
        url: "https://x.com",
        succeeded: true,
      );
      FilePickerPlatform.instance = _StubFilePicker("/some/export.json");

      var captured = "";
      await tester.pumpWidget(buildPage(
        fileWriter: (path, contents) async => captured = contents,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Export"));
      await tester.pumpAndSettle();

      expect(find.textContaining("Exported"), findsOneWidget);
      expect(captured, contains("https://x.com"));
    });

    testWidgets("cancelling the save dialog writes nothing", (tester) async {
      await mockDb.database.recordMetadataFetch(
        url: "https://x.com",
        succeeded: true,
      );
      FilePickerPlatform.instance = _StubFilePicker(null); // user aborted

      var writerCalled = false;
      await tester.pumpWidget(buildPage(
        fileWriter: (path, contents) async => writerCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Export"));
      await tester.pumpAndSettle();

      expect(writerCalled, isFalse);
      expect(find.textContaining("Exported"), findsNothing);
    });
  });
}
