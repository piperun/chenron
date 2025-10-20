/// Utilities for parsing search queries and extracting special patterns
class QueryParser {
  /// Parse a search query and extract tag patterns (#tag and -#tag)
  ///
  /// Text within double quotes is treated as literal and not parsed for tags.
  ///
  /// Returns a record containing:
  /// - `cleanQuery`: The query with tag patterns removed (quoted text preserved)
  /// - `includedTags`: Set of tags from #tag patterns
  /// - `excludedTags`: Set of tags from -#tag patterns
  ///
  /// Example:
  /// ```dart
  /// final result = QueryParser.parseTags("hello #world -#foo #bar test");
  /// // result.cleanQuery == "hello test"
  /// // result.includedTags == {"world", "bar"}
  /// // result.excludedTags == {"foo"}
  ///
  /// final quoted = QueryParser.parseTags('"#notag" #realtag');
  /// // quoted.cleanQuery == "#notag"
  /// // quoted.includedTags == {"realtag"}
  /// ```
  static ({
    String cleanQuery,
    Set<String> includedTags,
    Set<String> excludedTags
  }) parseTags(String query) {
    final includedTags = <String>{};
    final excludedTags = <String>{};
    final cleanParts = <String>[];

    // First, extract quoted strings and replace with placeholders
    final quotedStrings = <String>[];
    var workingQuery = query;
    final quotePattern = RegExp(r'"([^"]*)"');
    
    workingQuery = workingQuery.replaceAllMapped(quotePattern, (match) {
      final quotedText = match.group(1) ?? "";
      quotedStrings.add(quotedText);
      return "___QUOTED_${quotedStrings.length - 1}___";
    });

    // Now parse the working query for tags
    final parts = workingQuery.split(RegExp(r"\s+"));

    for (final part in parts) {
      if (part.isEmpty) continue;

      // Check if this is a quoted placeholder
      if (part.startsWith("___QUOTED_") && part.endsWith("___")) {
        final indexStr = part.substring(10, part.length - 3);
        final index = int.tryParse(indexStr);
        if (index != null && index < quotedStrings.length) {
          cleanParts.add(quotedStrings[index]);
        }
        continue;
      }

      // Check for exclusion pattern: -#tag
      if (part.startsWith("-#") && part.length > 2) {
        final tagName = part.substring(2).trim();
        if (tagName.isNotEmpty) {
          excludedTags.add(tagName);
          continue;
        }
      }

      // Check for inclusion pattern: #tag
      if (part.startsWith("#") && part.length > 1) {
        final tagName = part.substring(1).trim();
        if (tagName.isNotEmpty) {
          includedTags.add(tagName);
          continue;
        }
      }

      // Not a tag pattern, keep it as part of the query
      cleanParts.add(part);
    }

    return (
      cleanQuery: cleanParts.join(" ").trim(),
      includedTags: includedTags,
      excludedTags: excludedTags,
    );
  }
}
