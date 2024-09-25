import 'package:chenron/components/metadata_comp.dart';
import 'package:chenron/data_struct/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder/read.dart';
import 'package:chenron/components/edviewer/viewer/detail_viewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:favicon/favicon.dart';

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
      leading: Favicon(url: tileContent),
      title: MetadataWidget(url: tileContent).buildTitle(),
      subtitle: MetadataWidget(url: tileContent).buildDescription(),
      trailing: const Icon(Icons.launch, color: Colors.grey),
      isThreeLine: true,
      onTap: launchFunc,
    );
  }
}

class Favicon extends StatelessWidget {
  final String url;
  static final Map<String, Future<String?>> _cache = {};

  factory Favicon({Key? key, required String url}) {
    return Favicon._internal(key: key, url: url);
  }

  const Favicon._internal({super.key, required this.url});

  static Future<String?> _getFavIconUrl(String url) async {
    if (!_cache.containsKey(url)) {
      _cache[url] = FaviconFinder.getBest(url).then((favicon) => favicon?.url);
    }
    return _cache[url];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getFavIconUrl(url),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data!.endsWith('svg')) {
            return SvgPicture.network(snapshot.data!);
          } else {
            return Image.network(snapshot.data!);
          }
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const RepaintBoundary(
            child: CircularProgressIndicator(
                strokeWidth: 8,
                strokeAlign: BorderSide.strokeAlignCenter,
                backgroundColor: Colors.blue),
          );
        } else {
          return const Icon(Icons.link);
        }
      },
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
