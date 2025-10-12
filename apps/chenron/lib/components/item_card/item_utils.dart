import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:chenron/models/item.dart";
import "package:url_launcher/url_launcher.dart" as url_launcher;

class ItemUtils {
  static String getUrl(FolderItem item) {
    if (item.path is StringContent) {
      return (item.path as StringContent).value;
    }
    return "";
  }

  static Future<void> launchUrl(FolderItem item) async {
    final url = getUrl(item);
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri);
      }
    }
  }

  static String getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.isEmpty ? url : uri.host;
    } catch (e) {
      return url;
    }
  }

  static String getItemTitle(FolderItem item) {
    if (item.path is StringContent) {
      final url = (item.path as StringContent).value;
      return getDomain(url);
    }
    return "Unknown Item";
  }

  static String getItemSubtitle(FolderItem item) {
    if (item.path is StringContent) {
      return (item.path as StringContent).value;
    }
    return "";
  }

  static void copyUrl(String url) {
    Clipboard.setData(ClipboardData(text: url));
  }

  static List<Widget> buildTags(FolderItem item) {
    // Return empty list - type is shown as a badge, not a tag
    // In the future, actual tags can be added here
    return [];
  }
}

class ItemIcon extends StatelessWidget {
  final FolderItemType type;
  final double size;

  const ItemIcon({
    super.key,
    required this.type,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    late final Color backgroundColor;
    late final Color iconColor;
    late final IconData icon;

    switch (type) {
      case FolderItemType.link:
        backgroundColor = Colors.blue.withOpacity(0.1);
        iconColor = Colors.blue;
        icon = Icons.link;
        break;
      case FolderItemType.document:
        backgroundColor = Colors.purple.withOpacity(0.1);
        iconColor = Colors.purple;
        icon = Icons.description;
        break;
      case FolderItemType.folder:
        backgroundColor = Colors.orange.withOpacity(0.1);
        iconColor = Colors.orange;
        icon = Icons.folder;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Icon(icon, color: iconColor, size: size * 0.625),
    );
  }
}
