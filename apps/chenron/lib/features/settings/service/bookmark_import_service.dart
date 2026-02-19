import "dart:io";

import "package:flutter/foundation.dart";

import "package:chenron/locator.dart";
import "package:database/database.dart";
import "package:html/dom.dart";
import "package:html/parser.dart" as html_parser;
import "package:signals/signals.dart";

class BookmarkImportResult {
  final int foldersCreated;
  final int linksImported;
  final int linksSkipped;
  final int tagsCreated;

  const BookmarkImportResult({
    required this.foldersCreated,
    required this.linksImported,
    required this.linksSkipped,
    required this.tagsCreated,
  });
}

class BookmarkImportService {
  late final AppDatabase Function() _resolveDb;

  BookmarkImportService()
      : _resolveDb = (() =>
            locator.get<Signal<AppDatabaseHandler>>().value.appDatabase);

  @visibleForTesting
  BookmarkImportService.withDeps({required AppDatabase appDatabase})
      : _resolveDb = (() => appDatabase);

  Future<BookmarkImportResult> importBookmarks(File sourceFile) async {
    final appDb = _resolveDb();

    final content = await sourceFile.readAsString();
    final document = html_parser.parse(content);

    final rootDl = document.querySelector("dl");
    if (rootDl == null) {
      throw ArgumentError("Invalid bookmark file: no bookmark data found.");
    }

    // Pre-load existing URLs for duplicate detection
    final allLinks = await appDb.getAllLinks();
    final existingUrls = allLinks.map((l) => l.data.path).toSet();

    final counters = _ImportCounters();

    await appDb.transaction(() async {
      await _processDl(appDb, rootDl, null, counters, existingUrls);
    });

    return BookmarkImportResult(
      foldersCreated: counters.foldersCreated,
      linksImported: counters.linksImported,
      linksSkipped: counters.linksSkipped,
      tagsCreated: counters.tagsCreated,
    );
  }

  Future<void> _processDl(
    AppDatabase appDb,
    Element dl,
    String? parentFolderId,
    _ImportCounters counters,
    Set<String> existingUrls,
  ) async {
    final children = dl.children.where((e) => e.localName == "dt").toList();

    for (final dt in children) {
      final h3 = dt.querySelector("h3");
      final a = dt.querySelector("a");

      if (h3 != null) {
        await _handleFolder(appDb, dt, h3, parentFolderId, counters, existingUrls);
      } else if (a != null) {
        await _handleLink(appDb, a, parentFolderId, counters, existingUrls);
      }
    }
  }

  Future<void> _handleFolder(
    AppDatabase appDb,
    Element dt,
    Element h3,
    String? parentFolderId,
    _ImportCounters counters,
    Set<String> existingUrls,
  ) async {
    final title = _sanitizeFolderTitle(h3.text.trim());
    final description = _extractDescription(dt);
    final tags = _parseTagNames(h3.attributes["tags"] ?? "");

    final tagMetadata = tags
        .map((t) => Metadata(value: t, type: MetadataTypeEnum.tag))
        .toList();

    final result = await appDb.createFolder(
      folderInfo: FolderDraft(
        title: title,
        description: _sanitizeDescription(description),
      ),
      tags: tagMetadata.isNotEmpty ? tagMetadata : null,
    );
    counters.foldersCreated++;
    counters.tagsCreated += tags.length;

    // Add this folder to parent if nested
    if (parentFolderId != null) {
      await appDb.updateFolder(
        parentFolderId,
        itemUpdates: CUD(
          update: [
            FolderItem.folder(
              id: null,
              itemId: result.folderId,
              folderId: result.folderId,
              title: title,
            ),
          ],
        ),
      );
    }

    // Find the nested <DL> for this folder's contents
    final nestedDl = _findNestedDl(dt);
    if (nestedDl != null) {
      await _processDl(appDb, nestedDl, result.folderId, counters, existingUrls);
    }
  }

  Future<void> _handleLink(
    AppDatabase appDb,
    Element a,
    String? parentFolderId,
    _ImportCounters counters,
    Set<String> existingUrls,
  ) async {
    final url = a.attributes["href"] ?? "";
    if (!_isValidUrl(url)) return;

    final tags = _parseTagNames(a.attributes["tags"] ?? "");
    final tagMetadata = tags
        .map((t) => Metadata(value: t, type: MetadataTypeEnum.tag))
        .toList();

    final isNew = !existingUrls.contains(url);

    final linkResult = await appDb.createLink(
      link: url,
      tags: tagMetadata.isNotEmpty ? tagMetadata : null,
    );

    if (isNew) {
      counters.linksImported++;
      counters.tagsCreated += tags.length;
      existingUrls.add(url);
    } else {
      counters.linksSkipped++;
    }

    // Add to parent folder, or default folder for root-level links
    final targetFolderId =
        parentFolderId ?? await appDb.getDefaultFolderId();
    if (targetFolderId != null) {
      await appDb.updateFolder(
        targetFolderId,
        itemUpdates: CUD(
          update: [
            FolderItem.link(
              id: null,
              itemId: linkResult.linkId,
              url: url,
            ),
          ],
        ),
      );
    }
  }

  Element? _findNestedDl(Element dt) {
    // Check if <DL> is a direct child of this <DT>
    final childDl = dt.querySelector("dl");
    if (childDl != null) return childDl;

    // Check next siblings (Netscape format quirk)
    Element? sibling = dt.nextElementSibling;
    while (sibling != null) {
      if (sibling.localName == "dl") return sibling;
      if (sibling.localName == "dt") break;
      sibling = sibling.nextElementSibling;
    }
    return null;
  }

  String _extractDescription(Element dt) {
    // <DD> follows <H3> in some bookmark files
    Element? sibling = dt.nextElementSibling;
    while (sibling != null) {
      if (sibling.localName == "dd") return sibling.text.trim();
      if (sibling.localName == "dt" || sibling.localName == "dl") break;
      sibling = sibling.nextElementSibling;
    }
    return "";
  }

  String _sanitizeFolderTitle(String title) {
    if (title.isEmpty) return "Untitled Folder";
    if (title.length < 6) return "$title (imported)";
    if (title.length > 30) return title.substring(0, 30);
    return title;
  }

  String _sanitizeDescription(String description) {
    if (description.length > 1000) return description.substring(0, 1000);
    return description;
  }

  bool _isValidUrl(String url) {
    if (url.length < 10 || url.length > 2048) return false;
    return url.startsWith("http://") || url.startsWith("https://");
  }

  List<String> _parseTagNames(String tagsStr) {
    if (tagsStr.isEmpty) return [];
    return tagsStr
        .split(",")
        .map((t) => t.trim())
        .where((t) => t.length >= 3 && t.length <= 12)
        .toList();
  }
}

class _ImportCounters {
  int foldersCreated = 0;
  int linksImported = 0;
  int linksSkipped = 0;
  int tagsCreated = 0;
}
