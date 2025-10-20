/// Utilities for parsing search queries and extracting special patterns
class QueryParser {
  /// Parse a search query and extract tag patterns (#tag and -#tag)
  ///
  /// Returns a record containing:
  /// - `cleanQuery`: The query with tag patterns removed
  /// - `includedTags`: Set of tags from #tag patterns
  /// - `excludedTags`: Set of tags from -#tag patterns
  ///
  /// Example:
  /// ```dart
  /// final result = QueryParser.parseTags("hello #world -#foo #bar test");
  /// // result.cleanQuery == "hello test"
  /// // result.includedTags == {"world", "bar"}
  /// // result.excludedTags == {"foo"}
  /// ```
  static ({
    String cleanQuery,
    Set<String> includedTags,
    Set<String> excludedTags
  }) parseTags(String query) {
    final includedTags = <String>{};
    final excludedTags = <String>{};
    final tokens = <String>[];

    // Split by whitespace and process each token
    final parts = query.split(RegExp(r'\s+'));

    for (final part in parts) {
      if (part.isEmpty) continue;

      // Check for exclusion pattern: -#tag
      if (part.startsWith('-#') && part.length > 2) {
        final tagName = part.substring(2).trim();
        if (tagName.isNotEmpty) {
          excludedTags.add(tagName);
          continue;
        }
      }

      // Check for inclusion pattern: #tag
      if (part.startsWith('#') && part.length > 1) {
        final tagName = part.substring(1).trim();
        if (tagName.isNotEmpty) {
          includedTags.add(tagName);
          continue;
        }
      }

      // Not a tag pattern, keep it as part of the query
      tokens.add(part);
    }

    return (
      cleanQuery: tokens.join(' ').trim(),
      includedTags: includedTags,
      excludedTags: excludedTags,
    );
  }
}
