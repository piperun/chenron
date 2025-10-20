import 'package:chenron/shared/tag_filter/tag_filter_state.dart';
import 'package:chenron/shared/search/query_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QueryParser', () {
    test('parses single included tag', () {
      final result = QueryParser.parseTags('#test');
      
      expect(result.includedTags, {'test'});
      expect(result.excludedTags, isEmpty);
      expect(result.cleanQuery, '');
    });

    test('parses single excluded tag', () {
      final result = QueryParser.parseTags('-#test');
      
      expect(result.includedTags, isEmpty);
      expect(result.excludedTags, {'test'});
      expect(result.cleanQuery, '');
    });

    test('parses multiple tags with text', () {
      final result = QueryParser.parseTags('hello #world -#foo #bar test');
      
      expect(result.includedTags, {'world', 'bar'});
      expect(result.excludedTags, {'foo'});
      expect(result.cleanQuery, 'hello test');
    });

    test('parses tags and preserves non-tag text', () {
      final result = QueryParser.parseTags('#cool some text -#notcool more text');
      
      expect(result.includedTags, {'cool'});
      expect(result.excludedTags, {'notcool'});
      expect(result.cleanQuery, 'some text more text');
    });

    test('handles empty query', () {
      final result = QueryParser.parseTags('');
      
      expect(result.includedTags, isEmpty);
      expect(result.excludedTags, isEmpty);
      expect(result.cleanQuery, '');
    });

    test('handles query with no tags', () {
      final result = QueryParser.parseTags('just some text');
      
      expect(result.includedTags, isEmpty);
      expect(result.excludedTags, isEmpty);
      expect(result.cleanQuery, 'just some text');
    });

    test('treats text in quotes as literal (not tags)', () {
      final result = QueryParser.parseTags('"#notag" #realtag');
      
      expect(result.includedTags, {'realtag'});
      expect(result.excludedTags, isEmpty);
      expect(result.cleanQuery, '#notag');
    });

    test('handles multiple quoted strings', () {
      final result = QueryParser.parseTags('"#foo" text "#bar" #baz');
      
      expect(result.includedTags, {'baz'});
      expect(result.excludedTags, isEmpty);
      expect(result.cleanQuery, '#foo text #bar');
    });

    test('handles quoted excluded tags as literal', () {
      final result = QueryParser.parseTags('"-#notag" -#realtag');
      
      expect(result.includedTags, isEmpty);
      expect(result.excludedTags, {'realtag'});
      expect(result.cleanQuery, '-#notag');
    });

    test('handles empty quotes', () {
      final result = QueryParser.parseTags('"" #tag');
      
      expect(result.includedTags, {'tag'});
      expect(result.excludedTags, isEmpty);
      expect(result.cleanQuery, '');
    });

    test('handles unclosed quotes (treats as regular text)', () {
      final result = QueryParser.parseTags('"unclosed #tag');
      
      expect(result.includedTags, {'tag'});
      expect(result.excludedTags, isEmpty);
      expect(result.cleanQuery, '"unclosed');
    });

    test('handles quotes with spaces', () {
      final result = QueryParser.parseTags('"hello #world test" #foo');
      
      expect(result.includedTags, {'foo'});
      expect(result.excludedTags, isEmpty);
      expect(result.cleanQuery, 'hello #world test');
    });

    test('mixed tags and quoted text', () {
      final result = QueryParser.parseTags('#start "#literal" middle #end "-#also"');
      
      expect(result.includedTags, {'start', 'end'});
      expect(result.excludedTags, isEmpty);
      expect(result.cleanQuery, '#literal middle -#also');
    });
  });

  group('TagFilterState', () {
    test('starts with empty tags', () {
      final state = TagFilterState();
      
      expect(state.includedTagNames, isEmpty);
      expect(state.excludedTagNames, isEmpty);
      
      state.dispose();
    });

    test('addIncluded adds tag to included set', () {
      final state = TagFilterState();
      
      state.addIncluded('test');
      
      expect(state.includedTagNames, {'test'});
      expect(state.excludedTagNames, isEmpty);
      
      state.dispose();
    });

    test('addExcluded adds tag to excluded set', () {
      final state = TagFilterState();
      
      state.addExcluded('test');
      
      expect(state.includedTagNames, isEmpty);
      expect(state.excludedTagNames, {'test'});
      
      state.dispose();
    });

    test('addIncluded removes tag from excluded if present', () {
      final state = TagFilterState();
      
      state.addExcluded('test');
      expect(state.excludedTagNames, {'test'});
      
      state.addIncluded('test');
      expect(state.includedTagNames, {'test'});
      expect(state.excludedTagNames, isEmpty);
      
      state.dispose();
    });

    test('includeMany/excludeMany handle conflicts and idempotency', () {
      final state = TagFilterState();

      state.includeMany({'a', 'b', 'c'});
      expect(state.includedTagNames, {'a', 'b', 'c'});
      expect(state.excludedTagNames, isEmpty);

      // Exclude b and d (d new)
      state.excludeMany({'b', 'd'});
      expect(state.includedTagNames, {'a', 'c'});
      expect(state.excludedTagNames, {'b', 'd'});

      // Include b again should remove from excluded
      state.includeMany({'b'});
      expect(state.includedTagNames, {'a', 'b', 'c'});
      expect(state.excludedTagNames, {'d'});

      // Idempotent operations
      state.includeMany({'a', 'b'});
      state.excludeMany({'d'});
      expect(state.includedTagNames, {'a', 'b', 'c'});
      expect(state.excludedTagNames, {'d'});

      state.dispose();
    });

    test('parseAndAddFromQuery adds tags from query', () {
      final state = TagFilterState();
      
      final cleanQuery = state.parseAndAddFromQuery('#test hello -#cool world');
      
      print('Test: cleanQuery = "$cleanQuery"');
      print('Test: includedTags = ${state.includedTagNames}');
      print('Test: excludedTags = ${state.excludedTagNames}');
      
      expect(cleanQuery, 'hello world');
      expect(state.includedTagNames, {'test'});
      expect(state.excludedTagNames, {'cool'});
      
      state.dispose();
    });

    test('parseAndAddFromQuery accumulates tags', () {
      final state = TagFilterState();
      
      // First submission
      state.parseAndAddFromQuery('#tag1');
      expect(state.includedTagNames, {'tag1'});
      
      // Second submission
      state.parseAndAddFromQuery('#tag2');
      expect(state.includedTagNames, {'tag1', 'tag2'});
      
      state.dispose();
    });

    test('clear removes all tags', () {
      final state = TagFilterState();
      
      state.addIncluded('test1');
      state.addIncluded('test2');
      state.addExcluded('cool');
      
      state.clear();
      
      expect(state.includedTagNames, isEmpty);
      expect(state.excludedTagNames, isEmpty);
      
      state.dispose();
    });

    test('signals react to changes', () {
      final state = TagFilterState();
      
      // Track signal updates
      var includedUpdates = 0;
      var excludedUpdates = 0;
      
      final includedDispose = state.includedTags.subscribe((value) {
        includedUpdates++;
      });
      
      final excludedDispose = state.excludedTags.subscribe((value) {
        excludedUpdates++;
      });
      
      // Make changes
      state.addIncluded('test');
      state.addExcluded('cool');
      
      // Verify signals updated
      expect(includedUpdates, greaterThan(0));
      expect(excludedUpdates, greaterThan(0));
      
      includedDispose();
      excludedDispose();
      state.dispose();
    });
  });
}
