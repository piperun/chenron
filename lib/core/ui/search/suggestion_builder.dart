import "package:chenron/core/ui/search/search_matcher.dart";
import "package:chenron/core/utils/text_highlighter.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/features/show_folder/pages/show_folder.dart";
import "package:flutter/material.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/link/read.dart";
import "package:signals/signals_flutter.dart";
import "package:url_launcher/url_launcher.dart";

class GlobalSuggestionBuilder {
  final Signal<Future<AppDatabaseHandler>> db;
  final BuildContext context;
  final SearchController controller;

  GlobalSuggestionBuilder({
    required this.db,
    required this.context,
    required this.controller,
  });

  Future<List<ListTile>> buildSuggestions() async {
    final handler = await db.value;
    final folders =
        await handler.appDatabase.searchFolders(query: controller.text);

    final links = await handler.appDatabase.searchLinks(query: controller.text);

    if (!context.mounted) return [];

    final searchMatcher = SearchMatcher(controller.text);
    final suggestionFactory = SuggestionFactory(context, controller);

    final matchedFolders = searchMatcher.getTopContentMatches(
      folders,
      (f) => f.folder.title,
      (f) => f.tags,
    );

    final matchedLinks = searchMatcher.getTopUrlMatches(
      links,
      (link) => link.item.content,
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
  final SearchController controller;

  SuggestionFactory(this.context, this.controller);

  ListTile createFolderSuggestion(FolderResult folder) {
    return SuggestionTile(
      icon: Icons.folder,
      title: folder.folder.title,
      searchText: controller.text,
      onTapAction: () => _handleFolderNavigation(folder.folder.id),
    ).build(context);
  }

  ListTile createLinkSuggestion(LinkResult link) {
    return SuggestionTile(
      icon: Icons.link,
      title: link.item.content,
      searchText: controller.text,
      onTapAction: () => _handleUrlLaunch(link.item.content),
    ).build(context);
  }

  void _handleFolderNavigation(String folderId) async {
    controller.closeView(controller.text);
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShowFolder(folderId: folderId),
        ),
      );
    }
  }

  void _handleUrlLaunch(String url) async {
    controller.closeView(controller.text);
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
