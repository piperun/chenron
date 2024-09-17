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
          return ListTile(
            subtitle: Text(
              item.content,
              style: const TextStyle(color: Colors.blue, fontSize: 12),
            ),
            trailing: const Icon(Icons.launch, color: Colors.grey),
            onTap: () => _launchURL(Uri.parse(item.content)),
          );
        });
  }
}

void _launchURL(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    print('Could not launch $url');
  }
}
