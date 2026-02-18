import "package:chenron/shared/search/search_matcher.dart";
import "package:chenron/shared/search/search_controller.dart";

import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:database/database.dart";

import "package:flutter/material.dart";

import "package:signals/signals_flutter.dart";
import "package:url_launcher/url_launcher.dart";

class GlobalSuggestionBuilder {
  final Signal<AppDatabaseHandler> db;
  final BuildContext context;
  final SearchController? controller;
  final SearchBarController? queryController;
  final Future<void> Function({
    required String type,
    required String id,
    required String title,
  })? onItemSelected;

  GlobalSuggestionBuilder({
    required this.db,
    required this.context,
    this.controller,
    this.queryController,
    this.onItemSelected,
  });

  Future<List<SuggestionData>> buildSuggestions() async {
    final handler = db.value;
    final appDb = handler.appDatabase;
    final query = queryController?.query.value ?? controller?.text ?? "";
    final folders = await appDb.searchFolders(query: query);
    final links = await appDb.searchLinks(query: query);

    // Also try direct ID lookups so pasted IDs resolve to results
    final idResults = await _lookupById(appDb, query);

    if (!context.mounted) return [];

    final searchMatcher = SearchMatcher(query);
    final suggestionFactory = SuggestionFactory(
      context,
      controller,
      onItemSelected,
    );

    final matchedFolders = searchMatcher.getTopContentMatches(
      folders,
      (f) => f.data.title,
      (f) => f.tags,
    );

    final matchedLinks = searchMatcher.getTopUrlMatches(
      links,
      (link) => link.data.path,
      (link) => link.tags,
    );

    // Collect IDs already present from text search to avoid duplicates
    final seenFolderIds = matchedFolders.map((f) => f.data.id).toSet();
    final seenLinkIds = matchedLinks.map((l) => l.data.id).toSet();

    return [
      // ID-matched results first (exact match is highest relevance)
      for (final folder in idResults.folders)
        if (!seenFolderIds.contains(folder.data.id))
          suggestionFactory.folderData(folder),
      for (final link in idResults.links)
        if (!seenLinkIds.contains(link.data.id))
          suggestionFactory.linkData(link),
      ...matchedFolders.map(suggestionFactory.folderData),
      ...matchedLinks.map(suggestionFactory.linkData),
    ];
  }

  /// Tries to find entities by direct ID lookup when the query is long
  /// enough to be a valid ID (30+ hex characters).
  Future<_IdLookupResults> _lookupById(
      AppDatabase appDb, String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 30) return const _IdLookupResults();

    final results = await Future.wait([
      appDb.getFolder(folderId: trimmed),
      appDb.getLink(linkId: trimmed),
    ]);

    return _IdLookupResults(
      folders: [if (results[0] != null) results[0]! as FolderResult],
      links: [if (results[1] != null) results[1]! as LinkResult],
    );
  }
}

class SuggestionFactory {
  final BuildContext context;
  final SearchController? controller;
  final Future<void> Function({
    required String type,
    required String id,
    required String title,
  })? onItemSelected;

  SuggestionFactory(
    this.context,
    this.controller,
    this.onItemSelected,
  );

  SuggestionData folderData(FolderResult folder) {
    return SuggestionData(
      icon: Icons.folder,
      title: folder.data.title,
      searchText: controller?.text ?? "",
      onTap: () => _handleFolderNavigation(
        folder.data.id,
        folder.data.title,
      ),
    );
  }

  SuggestionData linkData(LinkResult link) {
    return SuggestionData(
      icon: Icons.link,
      title: link.data.path,
      searchText: controller?.text ?? "",
      onTap: () => _handleUrlLaunch(
        link.data.path,
        link.data.path,
      ),
    );
  }

  Future<void> _handleFolderNavigation(String folderId, String title) async {
    await onItemSelected?.call(
      type: "folder",
      id: folderId,
      title: title,
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => FolderViewerPage(folderId: folderId),
        ),
      );
    }
  }

  Future<void> _handleUrlLaunch(String url, String title) async {
    await onItemSelected?.call(
      type: "link",
      id: url,
      title: title,
    );

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _IdLookupResults {
  final List<FolderResult> folders;
  final List<LinkResult> links;

  const _IdLookupResults({
    this.folders = const [],
    this.links = const [],
  });
}

/// Data model for a search suggestion, separating data from presentation.
class SuggestionData {
  final IconData icon;
  final String title;
  final String searchText;
  final VoidCallback onTap;

  const SuggestionData({
    required this.icon,
    required this.title,
    required this.searchText,
    required this.onTap,
  });
}
