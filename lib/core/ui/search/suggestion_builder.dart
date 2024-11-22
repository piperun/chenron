import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/features/show_folder/pages/show_folder.dart";
import "package:flutter/material.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/link/read.dart";
import "package:signals/signals_flutter.dart";
import "package:url_launcher/url_launcher.dart";

class GlobalSuggestionBuilder {
  // TODO: Once we rewrite loading the appdatabase so that it doesn't use future this will be AppDatabase only.
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
    final folders = await handler.appDatabase.getAllFolders();
    final links = await handler.appDatabase.getAllLinks();

    return [
      ...folders
          .where((f) => _matchesSearch(f.folder.title, f.tags))
          .map((f) => SuggestionTile(
                icon: Icons.folder,
                title: f.folder.title,
                onTapAction: () => _navigateToFolder(f.folder.id),
              ).build()),
      ...links
          .where((l) => _matchesSearch(l.link.content, l.tags))
          .map((l) => SuggestionTile(
                icon: Icons.link,
                title: l.link.content,
                onTapAction: () => _launchURL(l.link.content),
              ).build()),
    ];
  }

  bool _matchesSearch(String content, List<Tag> tags) {
    final searchText = controller.text.toLowerCase();
    return content.toLowerCase().contains(searchText) ||
        tags.any((t) => t.name.toLowerCase().contains(searchText));
  }

  void _navigateToFolder(String folderId) {
    controller.closeView(controller.text);
    Future.microtask(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShowFolder(folderId: folderId),
        ),
      );
    });
  }

  void _launchURL(String url) {
    controller.closeView(controller.text);
    Future.microtask(() async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    });
  }
}

class SuggestionTile {
  final IconData icon;
  final String title;
  final VoidCallback onTapAction;

  const SuggestionTile({
    required this.icon,
    required this.title,
    required this.onTapAction,
  });

  ListTile build() {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTapAction,
    );
  }
}
