import "package:chenron/shared/search/search_matcher.dart";
import "package:chenron/shared/utils/text_highlighter.dart";
import "package:chenron/shared/search/search_controller.dart";

import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron/models/db_result.dart" show FolderResult, LinkResult;
import "package:flutter/material.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/link/read.dart";
import "package:signals/signals_flutter.dart";
import "package:url_launcher/url_launcher.dart";

class GlobalSuggestionBuilder {
  final Signal<Future<AppDatabaseHandler>> db;
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

  Future<List<ListTile>> buildSuggestions() async {
    final handler = await db.value;
    final query = queryController?.query.value ?? controller?.text ?? "";
    final folders =
        await handler.appDatabase.searchFolders(query: query);

    final links = await handler.appDatabase.searchLinks(query: query);

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

    return [
      ...matchedFolders.map(suggestionFactory.createFolderSuggestion),
      ...matchedLinks.map(suggestionFactory.createLinkSuggestion),
    ];
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

  ListTile createFolderSuggestion(FolderResult folder) {
    return SuggestionTile(
      icon: Icons.folder,
      title: folder.data.title,
      searchText: controller?.text ?? "",
      onTapAction: () => _handleFolderNavigation(
        folder.data.id,
        folder.data.title,
      ),
    ).build(context);
  }

  ListTile createLinkSuggestion(LinkResult link) {
    return SuggestionTile(
      icon: Icons.link,
      title: link.data.path,
      searchText: controller?.text ?? "",
      onTapAction: () => _handleUrlLaunch(
        link.data.path,
        link.data.path, // URL as title for links
      ),
    ).build(context);
  }

  void _handleFolderNavigation(String folderId, String title) async {
    // Save to history
    await onItemSelected?.call(
      type: "folder",
      id: folderId,
      title: title,
    );
    
    // Overlay will be removed by SuggestionsOverlay after selection
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FolderViewerPage(folderId: folderId),
        ),
      );
    }
  }

  void _handleUrlLaunch(String url, String title) async {
    // Save to history
    await onItemSelected?.call(
      type: "link",
      id: url,
      title: title,
    );
    
    // Overlay will be removed by SuggestionsOverlay after selection
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class SuggestionTile {
  final IconData icon;
  final String title;
  final String searchText;
  final VoidCallback onTapAction;

  const SuggestionTile({
    required this.icon,
    required this.title,
    required this.searchText,
    required this.onTapAction,
  });

  ListTile build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: RichText(
        text: TextSpan(
          children: TextHighlighter.highlight(context, title, searchText),
        ),
      ),
      onTap: onTapAction,
    );
  }
}
