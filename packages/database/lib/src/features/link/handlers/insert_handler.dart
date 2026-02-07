import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/src/core/id.dart";

import "package:core/utils/str_sanitizer.dart";
import "package:drift/drift.dart";

extension LinkInsertHandler on AppDatabase {
  Future<List<LinkResultIds>> insertLinks({
    required Batch batch,
    required List<String> urls,
  }) async {
    final List<LinkResultIds> results = <LinkResultIds>[];
    if (urls.isEmpty) return results;

    final List<String> sanitizedUrls =
        urls.map((url) => removeTrailingSlash(url)).toList();
    final List<Link> existingLinks = await (select(links)
          ..where((tbl) => tbl.path.isIn(sanitizedUrls)))
        .get();

    final Map<String, String> existingLinkMap = {
      for (final Link link in existingLinks) link.path: link.id
    };

    for (final String url in sanitizedUrls) {
      final String linkId;

      if (existingLinkMap.containsKey(url)) {
        linkId = existingLinkMap[url]!;
      } else {
        linkId = generateId();
        batch.insert(
          links,
          LinksCompanion.insert(id: linkId, path: url),
          mode: InsertMode.insertOrIgnore,
        );
      }

      results.add(LinkResultIds(linkId: linkId));
    }

    return results;
  }
}
