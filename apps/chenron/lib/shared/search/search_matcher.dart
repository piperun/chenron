import "dart:math";

import "package:fuzzywuzzy/fuzzywuzzy.dart";
import "package:database/database.dart";

class SearchMatcher {
  final String searchText;
  final int maxResults;
  final int fuzzyThreshold;
  static const int minSearchLength = 2;

  SearchMatcher(
    String searchText, {
    this.maxResults = 10,
    this.fuzzyThreshold = 60,
  }) : searchText = searchText.toLowerCase();

  List<T> getTopContentMatches<T>(
    List<T> items,
    String Function(T) getContent,
    List<Tag> Function(T) getTags,
  ) {
    if (!_isValidSearch()) return [];

    final scoredItems = List<(T, int)>.empty(growable: true);

    for (final item in items) {
      final score = _calculateScore(getContent(item), getTags(item));
      if (score > fuzzyThreshold) {
        scoredItems.add((item, score));
      }
    }

    scoredItems.sort((a, b) => b.$2.compareTo(a.$2));
    return _limitResults(scoredItems.map((e) => e.$1).toList());
  }

  List<T> getTopUrlMatches<T>(
    List<T> items,
    String Function(T) getContent,
    List<Tag> Function(T) getTags,
  ) {
    if (!_isValidSearch()) return [];

    final scoredItems = <(T, int)>[];

    for (final item in items) {
      final searchableParts = _parseUrlParts(getContent(item));
      final tagNames = getTags(item).map((tag) => tag.name.toLowerCase());
      final combinedParts = [...searchableParts, ...tagNames].join(" ");

      final score = partialRatio(searchText, combinedParts);
      if (score > fuzzyThreshold) {
        scoredItems.add((item, score));
      }
    }

    scoredItems.sort((a, b) => b.$2.compareTo(a.$2));
    return _limitResults(scoredItems.map((e) => e.$1).toList());
  }

  int _calculateScore(String content, List<Tag> tags) {
    final contentScore = partialRatio(searchText, content.toLowerCase());

    if (tags.isEmpty) return contentScore;

    var maxTagScore = 0;
    for (final tag in tags) {
      final score = partialRatio(searchText, tag.name.toLowerCase());
      maxTagScore = max(maxTagScore, score);
    }

    return max(contentScore, maxTagScore);
  }

  bool _isValidSearch() => searchText.length >= minSearchLength;

  List<T> _limitResults<T>(List<T> items) {
    if (items.isEmpty) return [];
    return items.length <= maxResults ? items : items.sublist(0, maxResults);
  }

  List<String> _parseUrlParts(String url) {
    try {
      final urlParts = Uri.parse(url.toLowerCase());
      return [
        urlParts.host,
        ...urlParts.pathSegments,
        urlParts.query,
      ].where((part) => part.isNotEmpty).toList();
    } catch (e) {
      return [url.toLowerCase()];
    }
  }
}

