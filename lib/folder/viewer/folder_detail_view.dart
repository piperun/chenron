import 'package:chenron/data_struct/item.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder/read.dart';
import 'package:chenron/components/edviewer/viewer/detail_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

class FolderDetailView extends StatelessWidget {
  final String folderId;
  final Logger? logger;

  const FolderDetailView({super.key, required this.folderId, this.logger});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context, listen: false);
    return DetailViewer(
        folderId: folderId,
        fetchData: database.getFolder(folderId).then((folder) => folder!),
        listBuilder: (context, item) {
          return ContentTile(itemContent: item.content);
        });
  }
}

class ContentTile extends StatelessWidget {
  final ItemContent itemContent;
  final String tileContent;
  final Function() launchFunc;

  ContentTile({super.key, required this.itemContent})
      : tileContent = _getTileContent(itemContent),
        launchFunc = _getLaunchFunc(itemContent);

  static String _getTileContent(ItemContent content) {
    switch (content) {
      case StringContent stringContent:
        return stringContent.value;
      case MapContent mapContent:
        return mapContent.value['title'] ?? '';
      default:
        return '';
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
      subtitle: Text(
        tileContent,
        style: const TextStyle(color: Colors.blue, fontSize: 12),
      ),
      trailing: const Icon(Icons.launch, color: Colors.grey),
      onTap: launchFunc,
    );
  }
}

void _launchURL(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw ('Could not launch $url');
  }
}
