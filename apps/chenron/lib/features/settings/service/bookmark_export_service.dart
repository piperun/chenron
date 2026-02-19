import "dart:io";

import "package:flutter/foundation.dart";

import "package:chenron/locator.dart";
import "package:database/database.dart";
import "package:database/main.dart";
import "package:signals/signals.dart";

class BookmarkExportService {
  late final AppDatabase Function() _resolveDb;

  BookmarkExportService()
      : _resolveDb = (() =>
            locator.get<Signal<AppDatabaseHandler>>().value.appDatabase);

  @visibleForTesting
  BookmarkExportService.withDeps({required AppDatabase appDatabase})
      : _resolveDb = (() => appDatabase);

  Future<File> exportBookmarks(File destination) async {
    final appDb = _resolveDb();

    final allFolders = await appDb.getAllFolders(
      includeOptions:
          const IncludeOptions<AppDataInclude>({AppDataInclude.items, AppDataInclude.tags}),
    );
    final allLinks = await appDb.getAllLinks(
      includeOptions:
          const IncludeOptions<AppDataInclude>({AppDataInclude.tags}),
    );

    final folderMap = {for (final f in allFolders) f.data.id: f};

    // Find link IDs that belong to at least one folder
    final linkedIds = <String>{};
    for (final folder in allFolders) {
      for (final item in folder.items) {
        if (item is LinkItem && item.id != null) {
          linkedIds.add(item.id!);
        }
      }
    }

    // Orphan links: not inside any folder
    final orphanLinks =
        allLinks.where((l) => !linkedIds.contains(l.data.id)).toList();

    // Root folders: not nested inside another folder
    final nestedFolderIds = <String>{};
    for (final folder in allFolders) {
      for (final item in folder.items) {
        if (item is FolderItemNested) {
          nestedFolderIds.add(item.folderId);
        }
      }
    }
    final rootFolders =
        allFolders.where((f) => !nestedFolderIds.contains(f.data.id)).toList();

    final html = _buildHtml(rootFolders, folderMap, orphanLinks);
    await destination.writeAsString(html);
    return destination;
  }

  String _buildHtml(
    List<FolderResult> rootFolders,
    Map<String, FolderResult> folderMap,
    List<LinkResult> orphanLinks,
  ) {
    final sb = StringBuffer();
    sb.writeln("<!DOCTYPE NETSCAPE-Bookmark-file-1>");
    sb.writeln("<!-- This is an automatically generated file. -->");
    sb.writeln("<!--     Do not edit! -->");
    sb.writeln(
        '<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">');
    sb.writeln("<TITLE>Bookmarks</TITLE>");
    sb.writeln("<H1>Bookmarks</H1>");
    sb.writeln("<DL><p>");

    for (final folder in rootFolders) {
      _writeFolder(sb, folder, folderMap, 1);
    }

    for (final link in orphanLinks) {
      _writeLink(sb, link.data.path, link.data.createdAt, link.tags, 1);
    }

    sb.writeln("</DL><p>");
    return sb.toString();
  }

  void _writeFolder(
    StringBuffer sb,
    FolderResult folder,
    Map<String, FolderResult> folderMap,
    int indent,
  ) {
    final pad = "    " * indent;
    final addDate = folder.data.createdAt.millisecondsSinceEpoch ~/ 1000;
    final tagsAttr = _tagsAttr(folder.tags);

    sb.writeln(
        '$pad<DT><H3 ADD_DATE="$addDate"$tagsAttr>${_escape(folder.data.title)}</H3>');

    if (folder.data.description.isNotEmpty) {
      sb.writeln("$pad<DD>${_escape(folder.data.description)}");
    }

    sb.writeln("$pad<DL><p>");

    for (final item in folder.items) {
      switch (item) {
        case LinkItem(:final url, :final createdAt, :final tags):
          _writeLink(sb, url, createdAt, tags, indent + 1);
        case FolderItemNested(:final folderId):
          final nested = folderMap[folderId];
          if (nested != null) {
            _writeFolder(sb, nested, folderMap, indent + 1);
          }
        case DocumentItem():
          break;
      }
    }

    sb.writeln("$pad</DL><p>");
  }

  void _writeLink(
    StringBuffer sb,
    String url,
    DateTime? createdAt,
    List<Tag> tags,
    int indent,
  ) {
    final pad = "    " * indent;
    final addDate = (createdAt?.millisecondsSinceEpoch ?? 0) ~/ 1000;
    final tagsAttr = _tagsAttr(tags);

    sb.writeln(
        '$pad<DT><A HREF="${_escape(url)}" ADD_DATE="$addDate"$tagsAttr>${_escape(url)}</A>');
  }

  String _tagsAttr(List<Tag> tags) {
    if (tags.isEmpty) return "";
    return ' TAGS="${tags.map((t) => _escape(t.name)).join(",")}"';
  }

  String _escape(String text) {
    return text
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;");
  }
}
