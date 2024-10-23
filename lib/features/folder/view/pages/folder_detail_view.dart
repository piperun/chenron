import "package:chenron/components/metadata_factory.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/item.dart";
import "package:chenron/utils/logger.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:chenron/features/folder/view/ui/detail_viewer.dart";
import "package:signals/signals_flutter.dart";
import "package:url_launcher/url_launcher.dart";
import "package:chenron/components/favicon_display/favicon.dart";

class FolderDetailView extends StatelessWidget {
  final String folderId;
  final Logger? logger;

  const FolderDetailView({super.key, required this.folderId, this.logger});

  @override
  Widget build(BuildContext context) {
    final database = locator
        .get<Signal<Future<AppDatabaseHandler>>>()
        .value
        .then((db) =>
            db.appDatabase.getFolder(folderId).then((folder) => folder!));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Folder Details"),
      ),
      body: DetailViewer(
        fetchData: database,
        listBuilder: (context, item) {
          return ItemTile(itemContent: item.content);
        },
      ),
    );
  }
}

class ItemTile extends StatelessWidget {
  final ItemContent itemContent;
  final String tileContent;
  final Function() launchFunc;

  ItemTile({super.key, required this.itemContent})
      : tileContent = _getTileContent(itemContent),
        launchFunc = _getLaunchFunc(itemContent);

  static String _getTileContent(ItemContent content) {
    switch (content) {
      case StringContent stringContent:
        return stringContent.value;
      case MapContent mapContent:
        return mapContent.value["title"] ?? "";
      default:
        return "";
    }
  }

  static Function() _getLaunchFunc(ItemContent content) {
    switch (content) {
      case StringContent stringContent:
        return () => _launchURL(Uri.parse(stringContent.value));
      default:
        return () {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Favicon(url: tileContent),
      title: MetadataWidget(url: tileContent).buildTitle(),
      subtitle: MetadataWidget(url: tileContent).buildDescription(),
      trailing: const Icon(Icons.launch, color: Colors.grey),
      isThreeLine: true,
      onTap: launchFunc,
    );
  }
}

void _launchURL(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw ("Could not launch $url");
  }
}
