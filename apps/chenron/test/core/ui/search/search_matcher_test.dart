
import "package:flutter_test/flutter_test.dart";
import "package:chenron/shared/search/search_matcher.dart";
import "package:database/database.dart";

void main() {
  group("SearchMatcher URL Tests", () {
    late SearchMatcher matcher;
    final urlTestCases = [
      // Social Media
      "https://www.facebook.com/groups/dartlang",
      "https://twitter.com/flutter/status/123456789",
      "https://www.instagram.com/p/abc123xyz/",
      "https://www.linkedin.com/in/developer-profile",
      "https://www.reddit.com/r/FlutterDev/comments/123abc",

      // Tech & Development
      "https://github.com/flutter/flutter/issues/12345",
      "https://stackoverflow.com/questions/12345/flutter-navigation",
      "https://medium.com/@author/flutter-best-practices-xyz",
      "https://dev.to/flutter/awesome-article",
      "https://pub.dev/packages/fuzzywuzzy",

      // Video & Streaming
      "https://www.youtube.com/watch?v=abc123xyz",
      "https://www.twitch.tv/programmer_stream",
      "https://vimeo.com/123456789",
      "https://www.netflix.com/watch/12345",
      "https://www.disney.com/movies/latest",

      // Shopping
      "https://www.amazon.com/dp/B123XYZ/ref=abc",
      "https://www.ebay.com/itm/123456789",
      "https://www.alibaba.com/product/12345.html",
      "https://www.walmart.com/ip/123456",
      "https://www.etsy.com/listing/123456",

      // News & Media
      "https://www.cnn.com/2023/tech/article",
      "https://www.bbc.co.uk/news/technology",
      "https://www.reuters.com/technology/article",
      "https://news.ycombinator.com/item?id=12345",
      "https://www.theverge.com/tech/123456",
    ];

    setUp(() {
      matcher = SearchMatcher("test", maxResults: 10);
    });

    test("URL matching with various search terms", () {
      final items = urlTestCases.map((url) => _createMockLink(url)).toList();

      final results = matcher.getTopUrlMatches(
        items,
        (l) => l.data.path,
        (l) => l.tags,
      );

      expect(results, isNotNull);
      expect(results.length, lessThanOrEqualTo(matcher.maxResults));
    });

    test("URL matching with empty search", () {
      matcher = SearchMatcher("");
      final items = urlTestCases.map((url) => _createMockLink(url)).toList();

      final results = matcher.getTopUrlMatches(
        items,
        (l) => l.data.path,
        (l) => l.tags,
      );

      expect(results, isEmpty);
    });
  });

  group("SearchMatcher Content Tests", () {
    late SearchMatcher matcher;
    final contentTestCases = [
      "Simple folder",
      "Folder with numbers 123",
      "UPPERCASE FOLDER",
      "mixed Case Folder",
      "Folder with symbols !@#",
      "Very long folder name that extends beyond typical length",
      "Short",
      "12345",
      "Folder with unicode 你好",
    ];

    setUp(() {
      matcher = SearchMatcher("folder");
    });

    test("Content matching with fuzzy search", () {
      final items = contentTestCases
          .map((content) => _createMockFolder(content))
          .toList();

      final results = matcher.getTopContentMatches(
        items,
        (f) => f.data.title,
        (f) => f.tags,
      );

      expect(results, isNotNull);
      expect(results.length, lessThanOrEqualTo(matcher.maxResults));
    });
  });
}

LinkResult _createMockLink(String url) {
  return LinkResult(
    data: Link(id: "1", path: url, createdAt: DateTime.now()),
    tags: [],
  );
}

FolderResult _createMockFolder(String title) {
  return FolderResult(
    data: Folder(
        id: "1",
        title: title,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: ""),
    tags: [],
    items: [],
  );
}
