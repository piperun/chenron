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

  static List<Widget> buildTags(
    FolderItem item, {
    int maxTags = 5,
    Set<String> includedTagNames = const {},
  }) {
    final List<Widget> chips = [];
    final tags = item.tags;
    final int visibleCount = tags.length > maxTags ? maxTags : tags.length;

    // Reorder: included tags first
    final ordered = [
      ...tags.where((t) => includedTagNames.contains(t.name)),
      ...tags.where((t) => !includedTagNames.contains(t.name)),
    ];

    for (var i = 0; i < visibleCount; i++) {
      final tag = ordered[i];
      final bool isIncluded = includedTagNames.contains(tag.name);
      final Color baseColor = isIncluded ? Colors.green : Colors.blue;
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: baseColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tag, size: 12, color: baseColor),
              const SizedBox(width: 4),
              Text(
                tag.name,
                style: TextStyle(
                  fontSize: 11,
                  color: baseColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final int remaining = tags.length - visibleCount;
    if (remaining > 0) {
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Text(
            "+$remaining more",
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return chips;
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
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        iconColor = Colors.blue;
        icon = Icons.link;
        break;
      case FolderItemType.document:
        backgroundColor = Colors.purple.withValues(alpha: 0.1);
        iconColor = Colors.purple;
        icon = Icons.description;
        break;
      case FolderItemType.folder:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
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
