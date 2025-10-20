import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chenron/shared/search/search_controller.dart';
import 'package:chenron/shared/search/search_filter.dart';
import 'package:chenron/models/item.dart';
import 'package:signals/signals_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SearchBar Integration Tests', () {
    testWidgets('typing multiple characters updates filter',
        (WidgetTester tester) async {
      // Create test data
      final testItems = [
        FolderItem(
          content: StringContent(value: 'default item'),
          type: FolderItemType.link,
        ),
        FolderItem(
          content: StringContent(value: 'another item'),
          type: FolderItemType.link,
        ),
        FolderItem(
          content: StringContent(value: 'test'),
          type: FolderItemType.link,
        ),
      ];

      // Create shared search filter
      final searchFilter = SearchFilter();
      searchFilter.setup();
      final controller = searchFilter.controller;

      // Build test widget with plain SearchBar and reactive filtered list
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: SearchBar(
                hintText: 'Search...',
                onChanged: (value) {
                  controller.updateSignal(value);
                },
              ),
            ),
            body: Watch(
              (context) {
                final query = controller.query.value;
                final filtered = searchFilter.filterItems(
                  items: testItems,
                  query: query,
                );
                
                return Column(
                  children: [
                    Text('Query: $query'),
                    Text('Count: ${filtered.length}'),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ListTile(
                            title: Text((item.path as StringContent).value),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial state - all items shown
      expect(find.text('Count: 3'), findsOneWidget);
      expect(find.text('default item'), findsOneWidget);
      expect(find.text('another item'), findsOneWidget);
      expect(find.text('test'), findsOneWidget);

      // Find the SearchBar and enter text character by character
      final searchBar = find.byType(SearchBar);
      expect(searchBar, findsOneWidget);

      // Type 'd'
      await tester.enterText(searchBar, 'd');
      await tester.pumpAndSettle();
      
      print('After typing "d", query: ${searchFilter.controller.query.value}');
      expect(searchFilter.controller.query.value, equals('d'));
      expect(find.text('Query: d'), findsOneWidget);
      expect(find.text('Count: 1'), findsOneWidget);
      expect(find.text('default item'), findsOneWidget);

      // Type 'de'
      await tester.enterText(searchBar, 'de');
      await tester.pumpAndSettle();
      
      print('After typing "de", query: ${searchFilter.controller.query.value}');
      expect(searchFilter.controller.query.value, equals('de'));
      expect(find.text('Query: de'), findsOneWidget);
      expect(find.text('Count: 1'), findsOneWidget);

      // Type 'def'
      await tester.enterText(searchBar, 'def');
      await tester.pumpAndSettle();
      
      print('After typing "def", query: ${searchFilter.controller.query.value}');
      expect(searchFilter.controller.query.value, equals('def'));
      expect(find.text('Query: def'), findsOneWidget);
      expect(find.text('Count: 1'), findsOneWidget);

      // Type 'default'
      await tester.enterText(searchBar, 'default');
      await tester.pumpAndSettle();
      
      print('After typing "default", query: ${searchFilter.controller.query.value}');
      expect(searchFilter.controller.query.value, equals('default'));
      expect(find.text('Query: default'), findsOneWidget);
      expect(find.text('Count: 1'), findsOneWidget);
      expect(find.text('default item'), findsOneWidget);
      expect(find.text('another item'), findsNothing);

      searchFilter.dispose();
    });

    testWidgets('clearing search resets to show all items',
        (WidgetTester tester) async {
      final testItems = [
        FolderItem(
          content: StringContent(value: 'item 1'),
          type: FolderItemType.link,
        ),
        FolderItem(
          content: StringContent(value: 'item 2'),
          type: FolderItemType.link,
        ),
      ];

      final searchFilter = SearchFilter();
      searchFilter.setup();
      final controller = searchFilter.controller;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: SearchBar(
                hintText: 'Search...',
                onChanged: (value) {
                  controller.updateSignal(value);
                },
              ),
            ),
            body: Watch(
              (context) {
                final query = controller.query.value;
                final filtered = searchFilter.filterItems(
                  items: testItems,
                  query: query,
                );
                
                return Column(
                  children: [
                    Text('Count: ${filtered.length}'),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ListTile(
                            title: Text((item.path as StringContent).value),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state
      expect(find.text('Count: 2'), findsOneWidget);

      // Type something
      final searchBar = find.byType(SearchBar);
      await tester.enterText(searchBar, 'item 1');
      await tester.pumpAndSettle();
      
      expect(find.text('Count: 1'), findsOneWidget);
      // Find ListTile with 'item 1' text
      expect(find.descendant(
        of: find.byType(ListTile),
        matching: find.text('item 1'),
      ), findsOneWidget);
      expect(find.descendant(
        of: find.byType(ListTile),
        matching: find.text('item 2'),
      ), findsNothing);

      // Clear the search
      await tester.enterText(searchBar, '');
      await tester.pumpAndSettle();
      
      print('After clearing, query: "${searchFilter.controller.query.value}"');
      expect(searchFilter.controller.query.value, equals(''));
      expect(find.text('Count: 2'), findsOneWidget);
      // Both items should be visible in the ListView after clearing
      expect(find.descendant(
        of: find.byType(ListTile),
        matching: find.text('item 1'),
      ), findsOneWidget);
      expect(find.descendant(
        of: find.byType(ListTile),
        matching: find.text('item 2'),
      ), findsOneWidget);

      searchFilter.dispose();
    });
  });

  group('SearchFilter Unit Tests', () {
    test('filterItems with empty query returns all items', () {
      final items = [
        FolderItem(
          content: StringContent(value: 'test 1'),
          type: FolderItemType.link,
        ),
        FolderItem(
          content: StringContent(value: 'test 2'),
          type: FolderItemType.link,
        ),
      ];

      final filter = SearchFilter();
      filter.setup();

      final result = filter.filterItems(items: items, query: '');
      
      expect(result.length, equals(2));
      
      filter.dispose();
    });

    test('filterItems with query filters correctly', () {
      final items = [
        FolderItem(
          content: StringContent(value: 'default item'),
          type: FolderItemType.link,
        ),
        FolderItem(
          content: StringContent(value: 'another item'),
          type: FolderItemType.link,
        ),
      ];

      final filter = SearchFilter();
      filter.setup();

      final result = filter.filterItems(items: items, query: 'default');
      
      expect(result.length, equals(1));
      expect((result.first.path as StringContent).value, equals('default item'));
      
      filter.dispose();
    });
  });
}
