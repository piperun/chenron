import "package:chenron/shared/search/search_matcher.dart";
import "package:chenron/shared/search/search_controller.dart";

import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron/shared/item_detail/item_detail_dialog.dart";
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

    // Check for tag autocomplete: #partial at the end of query
    final tagSuggestions = await _buildTagSuggestions(appDb, query);
    if (tagSuggestions.isNotEmpty) return tagSuggestions;

    final folders = await appDb.searchFolders(query: query);
    final links = await appDb.searchLinks(query: query);
    final documents = await appDb.searchDocuments(query: query);

    // Also search web metadata (title/description) for links
    // whose URL didn't match but whose metadata does
    final metadataMatches = await appDb.searchWebMetadata(query);

    // Also try direct ID lookups so pasted IDs resolve to results
    final idResults = await _lookupById(appDb, query);

    if (!context.mounted) return [];

    // Build URL-to-metadata map for enriching link suggestions
    final metadataByUrl = <String, WebMetadataEntry>{};
    for (final entry in metadataMatches) {
      metadataByUrl[entry.url] = entry;
    }
    // Also fetch metadata for links found by URL search
    for (final link in links) {
      if (!metadataByUrl.containsKey(link.data.path)) {
        final meta = await appDb.getWebMetadata(link.data.path);
        if (meta != null) metadataByUrl[link.data.path] = meta;
      }
    }

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

    final matchedDocuments = searchMatcher.getTopContentMatches(
      documents,
      (d) => d.data.title,
      (d) => d.tags ?? [],
    );

    // Collect IDs already present from text search to avoid duplicates
    final seenFolderIds = matchedFolders.map((f) => f.data.id).toSet();
    final seenLinkIds = matchedLinks.map((l) => l.data.id).toSet();
    final seenDocumentIds = matchedDocuments.map((d) => d.data.id).toSet();
    final seenUrls = matchedLinks.map((l) => l.data.path).toSet();

    // Build metadata-only matches: links found via metadata but not URL
    final metadataOnlyLinks = <SuggestionData>[];
    for (final entry in metadataMatches) {
      if (seenUrls.contains(entry.url)) continue;
      metadataOnlyLinks.add(suggestionFactory.linkDataFromMetadata(entry));
      seenUrls.add(entry.url);
    }

    return [
      // ID-matched results first (exact match is highest relevance)
      for (final folder in idResults.folders)
        if (!seenFolderIds.contains(folder.data.id))
          suggestionFactory.folderData(folder),
      for (final link in idResults.links)
        if (!seenLinkIds.contains(link.data.id))
          suggestionFactory.linkData(link, metadataByUrl[link.data.path]),
      for (final doc in idResults.documents)
        if (!seenDocumentIds.contains(doc.data.id))
          suggestionFactory.documentData(doc),
      ...matchedFolders.map(suggestionFactory.folderData),
      ...matchedLinks.map(
        (l) => suggestionFactory.linkData(l, metadataByUrl[l.data.path]),
      ),
      ...matchedDocuments.map(suggestionFactory.documentData),
      ...metadataOnlyLinks,
    ];
  }

  /// Build tag autocomplete suggestions when the query ends with #partial.
  Future<List<SuggestionData>> _buildTagSuggestions(
    AppDatabase appDb,
    String query,
  ) async {
    // Match a #tag being typed at the end of the query
    final tagMatch = RegExp(r"#(\w*)$").firstMatch(query);
    if (tagMatch == null) return [];

    final partial = tagMatch.group(1) ?? "";
    final tags = partial.isEmpty
        ? await appDb.getAllTags()
        : await appDb.searchTags(query: partial);

    if (!context.mounted) return [];

    final queryController = this.queryController;
    return tags.take(10).map((tag) {
      return SuggestionData(
        icon: Icons.sell,
        title: tag.data.name,
        searchText: partial,
        onTap: () {
          if (queryController == null) return;
          // Replace the #partial with the full #tagName
          final before = query.substring(0, tagMatch.start);
          final completed = "$before#${tag.data.name} ";
          queryController.value = completed;
        },
      );
    }).toList();
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
      appDb.getDocument(documentId: trimmed),
    ]);

    return _IdLookupResults(
      folders: [if (results[0] != null) results[0]! as FolderResult],
      links: [if (results[1] != null) results[1]! as LinkResult],
      documents: [if (results[2] != null) results[2]! as DocumentResult],
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

  SuggestionData linkData(LinkResult link, [WebMetadataEntry? metadata]) {
    final displayTitle = metadata?.title ?? link.data.path;
    final subtitle = metadata?.title != null ? link.data.path : null;

    return SuggestionData(
      icon: Icons.link,
      title: displayTitle,
      subtitle: subtitle,
      searchText: controller?.text ?? "",
      onTap: () => _handleUrlLaunch(
        link.data.path,
        displayTitle,
      ),
    );
  }

  SuggestionData documentData(DocumentResult document) {
    return SuggestionData(
      icon: Icons.description,
      title: document.data.title,
      searchText: controller?.text ?? "",
      onTap: () => _handleDocumentOpen(
        document.data.id,
        document.data.title,
      ),
    );
  }

  SuggestionData linkDataFromMetadata(WebMetadataEntry metadata) {
    return SuggestionData(
      icon: Icons.link,
      title: metadata.title ?? metadata.url,
      subtitle: metadata.url,
      searchText: controller?.text ?? "",
      onTap: () => _handleUrlLaunch(
        metadata.url,
        metadata.title ?? metadata.url,
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

  Future<void> _handleDocumentOpen(String documentId, String title) async {
    await onItemSelected?.call(
      type: "document",
      id: documentId,
      title: title,
    );

    if (context.mounted) {
      showItemDetailDialog(
        context,
        itemId: documentId,
        itemType: FolderItemType.document,
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
  final List<DocumentResult> documents;

  const _IdLookupResults({
    this.folders = const [],
    this.links = const [],
    this.documents = const [],
  });
}

/// Data model for a search suggestion, separating data from presentation.
class SuggestionData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String searchText;
  final VoidCallback onTap;

  const SuggestionData({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.searchText,
    required this.onTap,
  });
}
