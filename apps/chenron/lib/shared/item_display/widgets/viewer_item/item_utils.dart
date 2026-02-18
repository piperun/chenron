import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "dart:async";
import "package:database/models/item.dart";
import "package:url_launcher/url_launcher.dart" as url_launcher;

class ItemUtils {
  static String getUrl(FolderItem item) {
    return item.map(
      link: (linkItem) => linkItem.url,
      document: (docItem) => docItem.filePath,
      folder: (folderItem) => "", // Folders don't have URLs
    );
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
    return item.map(
      link: (linkItem) => getDomain(linkItem.url),
      document: (docItem) => docItem.title,
      folder: (folderItem) => folderItem.title,
    );
  }

  static String getItemSubtitle(FolderItem item) {
    return item.map(
      link: (linkItem) => linkItem.url,
      document: (docItem) => docItem.filePath,
      folder: (folderItem) => folderItem.description ?? "",
    );
  }

  static void copyUrl(String url) {
    unawaited(Clipboard.setData(ClipboardData(text: url)).catchError(
      (Object error) {
        // Clipboard can fail on some platforms (e.g. no display server)
      },
    ));
  }

  static List<Widget> buildTags(
    FolderItem item, {
    int maxTags = 5,
    Set<String> includedTagNames = const {},
    ValueChanged<String>? onTagTap,
    VoidCallback? onOverflowTap,
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
      chips.add(
        Builder(builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          final Color baseColor = tag.color != null
              ? Color(tag.color!)
              : isIncluded
                  ? colorScheme.primary
                  : colorScheme.secondary;
          final child = Container(
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
          );
          if (onTagTap != null) {
            return GestureDetector(
              onTap: () => onTagTap(tag.name),
              child: child,
            );
          }
          return child;
        }),
      );
    }

    final int remaining = tags.length - visibleCount;
    if (remaining > 0) {
      chips.add(
        Builder(builder: (context) {
          final muted = Theme.of(context).colorScheme.onSurfaceVariant;
          final chip = Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: muted.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: muted.withValues(alpha: 0.3)),
            ),
            child: Text(
              "+$remaining more",
              style: TextStyle(
                fontSize: 11,
                color: muted.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
          if (onOverflowTap != null) {
            return GestureDetector(onTap: onOverflowTap, child: chip);
          }
          return chip;
        }),
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
    final colorScheme = Theme.of(context).colorScheme;
    late final Color backgroundColor;
    late final Color iconColor;
    late final IconData icon;

    switch (type) {
      case FolderItemType.link:
        backgroundColor = colorScheme.primary.withValues(alpha: 0.1);
        iconColor = colorScheme.primary;
        icon = Icons.link;
        break;
      case FolderItemType.document:
        backgroundColor = colorScheme.tertiary.withValues(alpha: 0.1);
        iconColor = colorScheme.tertiary;
        icon = Icons.description;
        break;
      case FolderItemType.folder:
        backgroundColor = colorScheme.secondary.withValues(alpha: 0.1);
        iconColor = colorScheme.secondary;
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
