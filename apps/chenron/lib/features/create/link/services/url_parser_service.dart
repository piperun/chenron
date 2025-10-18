class ParsedUrl {
  final String url;
  final List<String> tags;

  ParsedUrl({required this.url, required this.tags});
}

class UrlParserService {
  /// Parses a single line input that may contain URL and inline tags
  /// Supports formats:
  /// - https://example.com | tag1, tag2
  /// - https://example.com #tag1 #tag2
  static ParsedUrl? parseSingleLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return null;

    // Check for pipe separator
    if (trimmed.contains("|")) {
      final parts = trimmed.split("|");
      if (parts.length >= 2) {
        final url = parts[0].trim();
        final tagsStr = parts.sublist(1).join("|").trim();
        final tags = _parseTags(tagsStr);
        return ParsedUrl(url: url, tags: tags);
      }
    }

    // Check for hashtag format
    final hashtagPattern = RegExp(r"#\w+");
    if (hashtagPattern.hasMatch(trimmed)) {
      final matches = hashtagPattern.allMatches(trimmed);
      final tags = matches.map((m) => m.group(0)!.substring(1).toLowerCase()).toList();
      
      // Extract URL (everything before first hashtag or entire string)
      final firstHashIndex = trimmed.indexOf("#");
      final url = trimmed.substring(0, firstHashIndex).trim();
      
      if (url.isNotEmpty) {
        return ParsedUrl(url: url, tags: tags);
      }
    }

    // No tags found, just return URL
    return ParsedUrl(url: trimmed, tags: []);
  }

  /// Parses multiple lines for bulk input
  /// Filters out empty lines and comments (lines starting with #)
  static List<ParsedUrl> parseBulkLines(String text) {
    final lines = text.split("\n");
    final results = <ParsedUrl>[];

    for (final line in lines) {
      final trimmed = line.trim();
      
      // Skip empty lines
      if (trimmed.isEmpty) continue;
      
      // Skip comment lines (lines starting with # at the beginning)
      if (RegExp(r"^\s*#").hasMatch(line)) continue;

      final parsed = parseSingleLine(trimmed);
      if (parsed != null && parsed.url.isNotEmpty) {
        results.add(parsed);
      }
    }

    return results;
  }

  /// Extracts tags from a string
  /// Supports comma-separated and space-separated formats
  /// Returns all tags (including potentially invalid ones) for validation
  static List<String> _parseTags(String tagsStr) {
    if (tagsStr.isEmpty) return [];

    final tags = <String>{};
    
    // Split by comma and/or spaces
    final parts = tagsStr.split(RegExp(r"[,\s]+"));
    
    for (final part in parts) {
      final cleaned = part.trim().replaceAll(RegExp(r"^#+"), "").toLowerCase();
      
      // Keep ALL non-empty tags (including invalid ones) so they can be validated
      if (cleaned.isNotEmpty) {
        tags.add(cleaned);
      }
    }

    return tags.toList();
  }
}
