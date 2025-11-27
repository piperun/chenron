import "package:chenron/components/metadata_factory.dart";
import "package:chenron/components/favicon_display/favicon.dart";

import "package:database/models/db_result.dart";
import "package:database/models/item.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

class FolderDetailItems extends StatelessWidget {
  final FolderResult folderResult;

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
          child: ItemTile(item: item),
        );
      },
    );
  }
}

class ItemTile extends StatelessWidget {
  final FolderItem item;
  final String tileContent;
  final Function() launchFunc;

  ItemTile({super.key, required this.item})
      : tileContent = _getTileContent(item),
        launchFunc = _getLaunchFunc(item);

  static String _getTileContent(FolderItem item) {
    return item.map(
      link: (link) => link.url,
      document: (doc) => doc.title,
      folder: (folder) => folder.folderId,
    );
  }

  static Function() _getLaunchFunc(FolderItem item) {
    return item.map(
      link: (link) => () => _launchURL(Uri.parse(link.url)),
      document: (_) => () {},
      folder: (_) => () {},
    );
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

Future<void> _launchURL(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw ("Could not launch $url");
  }
}
