import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";
import "package:chenron/features/activity_log/pages/activity_log_page.dart";
import "package:database/features.dart";

void main() {
  late MockDatabaseHelper mockDb;

  setUpAll(installTestLogger);

  setUp(() async {
    mockDb = MockDatabaseHelper();
    await mockDb.setup();
  });

  tearDown(() async {
    await mockDb.dispose();
  });

  Widget buildPage() {
    return MaterialApp(
      home: Scaffold(body: ActivityLogPage(database: mockDb.database)),
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

    // Failed metadata entry visible…
    expect(find.text("https://broken.com"), findsOneWidget);
    // …but no Retry icon (Icons.replay) — retry only applies to archive jobs.
    expect(find.byIcon(Icons.replay), findsNothing);
  });

  testWidgets("Retry button still shown for failed archive jobs",
      (tester) async {
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
}
