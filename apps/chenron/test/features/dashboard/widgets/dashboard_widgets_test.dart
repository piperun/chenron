import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:database/database.dart";
import "package:chenron/features/dashboard/widgets/overview_cards.dart";
import "package:chenron/features/dashboard/widgets/chart_card.dart";
import "package:chenron/features/dashboard/widgets/time_range_selector.dart";
import "package:chenron/features/dashboard/widgets/recent_activity_list.dart";

void main() {
  group("OverviewCards", () {
    Widget buildOverviewCards({
      int totalLinks = 10,
      int totalDocuments = 5,
      int totalFolders = 3,
      int totalTags = 7,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: OverviewCards(
            totalLinks: totalLinks,
            totalDocuments: totalDocuments,
            totalFolders: totalFolders,
            totalTags: totalTags,
          ),
        ),
      );
    }

    testWidgets("shows all four stat labels", (tester) async {
      await tester.pumpWidget(buildOverviewCards());
      await tester.pumpAndSettle();

      expect(find.text("Links"), findsOneWidget);
      expect(find.text("Documents"), findsOneWidget);
      expect(find.text("Folders"), findsOneWidget);
      expect(find.text("Tags"), findsOneWidget);
    });

    testWidgets("shows correct counts", (tester) async {
      await tester.pumpWidget(buildOverviewCards(
        totalLinks: 42,
        totalDocuments: 17,
        totalFolders: 8,
        totalTags: 25,
      ));
      await tester.pumpAndSettle();

      expect(find.text("42"), findsOneWidget);
      expect(find.text("17"), findsOneWidget);
      expect(find.text("8"), findsOneWidget);
      expect(find.text("25"), findsOneWidget);
    });

    testWidgets("shows zero counts", (tester) async {
      await tester.pumpWidget(buildOverviewCards(
        totalLinks: 0,
        totalDocuments: 0,
        totalFolders: 0,
        totalTags: 0,
      ));
      await tester.pumpAndSettle();

      expect(find.text("0"), findsNWidgets(4));
    });

    testWidgets("shows stat icons", (tester) async {
      await tester.pumpWidget(buildOverviewCards());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.link), findsOneWidget);
      expect(find.byIcon(Icons.description), findsOneWidget);
      expect(find.byIcon(Icons.folder), findsOneWidget);
      expect(find.byIcon(Icons.label), findsOneWidget);
    });
  });

  group("ChartCard", () {
    testWidgets("shows title", (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ChartCard(
            title: "Growth Trend",
            child: SizedBox(height: 100),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text("Growth Trend"), findsOneWidget);
    });

    testWidgets("shows child widget", (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ChartCard(
            title: "Test",
            child: Text("Chart content"),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text("Chart content"), findsOneWidget);
    });

    testWidgets("shows trailing widget when provided", (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ChartCard(
            title: "Test",
            trailing: Text("Trailing"),
            child: SizedBox(),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text("Trailing"), findsOneWidget);
    });

    testWidgets("hides trailing when null", (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ChartCard(
            title: "Test",
            child: SizedBox(),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });
  });

  group("TimeRangeSelector", () {
    testWidgets("shows all time range options", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TimeRangeSelector(
            selected: TimeRange.month,
            onChanged: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      for (final range in TimeRange.values) {
        expect(find.text(range.label), findsOneWidget);
      }
    });

    testWidgets("calls onChanged when option selected", (tester) async {
      TimeRange? selectedRange;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TimeRangeSelector(
            selected: TimeRange.month,
            onChanged: (range) => selectedRange = range,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(TimeRange.week.label));
      await tester.pumpAndSettle();

      expect(selectedRange, TimeRange.week);
    });
  });

  group("RecentActivityList", () {
    testWidgets("shows empty state when no events", (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RecentActivityList(events: []),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text("Recent Activity"), findsOneWidget);
      expect(find.text("No activity recorded yet."), findsOneWidget);
    });

    testWidgets("shows activity events", (tester) async {
      final events = [
        EnrichedActivityEvent(
          id: "1",
          occurredAt: DateTime.now(),
          eventType: "link_created",
          entityType: "link",
          entityId: "link-1",
          entityName: "https://example.com",
        ),
        EnrichedActivityEvent(
          id: "2",
          occurredAt: DateTime.now(),
          eventType: "folder_deleted",
          entityType: "folder",
          entityId: "folder-1",
          entityName: "My Folder",
        ),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RecentActivityList(events: events),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text("Recent Activity"), findsOneWidget);
      expect(find.text("Link created"), findsOneWidget);
      expect(find.text("Folder deleted"), findsOneWidget);
      expect(find.textContaining("https://example.com"), findsOneWidget);
      expect(find.textContaining("My Folder"), findsOneWidget);
    });

    testWidgets("shows copy ID button for events with entityId",
        (tester) async {
      final events = [
        EnrichedActivityEvent(
          id: "1",
          occurredAt: DateTime.now(),
          eventType: "link_created",
          entityType: "link",
          entityId: "link-1",
          entityName: "Test",
        ),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RecentActivityList(events: events),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.copy), findsOneWidget);
    });
  });

  group("TimeRange enum", () {
    test("week has 7 days", () {
      expect(TimeRange.week.days, 7);
    });

    test("month has 30 days", () {
      expect(TimeRange.month.days, 30);
    });

    test("quarter has 90 days", () {
      expect(TimeRange.quarter.days, 90);
    });

    test("all returns null startDate", () {
      expect(TimeRange.all.startDate, isNull);
    });

    test("week returns non-null startDate", () {
      expect(TimeRange.week.startDate, isNotNull);
    });
  });
}
