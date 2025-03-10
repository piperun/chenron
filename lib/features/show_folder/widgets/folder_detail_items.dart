import "package:chenron/components/metadata_factory.dart";
import "package:chenron/components/favicon_display/favicon.dart";
import "package:chenron/database/actions/handlers/read_handler.dart"
    show Result;
import "package:chenron/database/database.dart" show Folder;
import "package:chenron/models/item.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

class FolderDetailItems extends StatelessWidget {
  final Result<Folder> folderResult;

  const FolderDetailItems({super.key, required this.folderResult});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: folderResult.items.length,
      itemBuilder: (context, index) {
        final item = folderResult.items.toList()[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: ItemTile(itemContent: item.content),
        );
      },
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
