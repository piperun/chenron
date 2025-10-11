import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/components/favicon_display/favicon.dart";
import "package:chenron/components/metadata_factory.dart";
import "package:chenron/components/item_card/item_utils.dart";
import "package:cache_manager/cache_manager.dart";

// Meta row with favicon, domain, and time
class ItemMetaRow extends StatelessWidget {
  final FolderItem item;
  final String? url;

  const ItemMetaRow({
    super.key,
    required this.item,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (item.type == FolderItemType.link && url != null && url!.isNotEmpty) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: Favicon(url: url!),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ItemUtils.getDomain(url!),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            " • ",
            style: TextStyle(
              fontSize: 10,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
          Text(
            "1d ago",
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
        ],
      );
    }

    // For non-link items
    return Row(
      children: [
        ItemIcon(type: item.type),
        const SizedBox(width: 8),
        Text(
          "1d ago",
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

// Title widget
class ItemTitle extends StatelessWidget {
  final FolderItem item;
  final String? url;
  final int maxLines;

  const ItemTitle({
    super.key,
    required this.item,
    this.url,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (item.type == FolderItemType.link && url != null && url!.isNotEmpty) {
      return MetadataWidget(url: url!).buildTitle();
    }

    return Text(
      ItemUtils.getItemTitle(item),
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        height: 1.3,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// Description widget
class ItemDescription extends StatelessWidget {
  final FolderItem item;
  final String? url;
  final int maxLines;

  const ItemDescription({
    super.key,
    required this.item,
    this.url,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (item.type == FolderItemType.link && url != null && url!.isNotEmpty) {
      return MetadataDescription(
        widget: MetadataWidget(url: url!),
        maxLines: maxLines,
      );
    }

    return Text(
      ItemUtils.getItemSubtitle(item),
      style: TextStyle(
        fontSize: 13,
        height: 1.4,
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// URL bar with copy button
class ItemUrlBar extends StatelessWidget {
  final String url;

  const ItemUrlBar({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? const Color(0xFFF8F8F8)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.link,
            size: 12,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              url,
              style: TextStyle(
                fontSize: 11,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                fontFamily: "monospace",
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => ItemUtils.copyUrl(url),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border.all(
                  color: theme.dividerColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "copy",
                style: TextStyle(
                  fontSize: 10,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// OG:image header for links
class ItemImageHeader extends StatelessWidget {
  final String url;
  final double height;

  const ItemImageHeader({
    super.key,
    required this.url,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>?>(
      future: MetadataCache.get(url),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data?["image"] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return SizedBox(
            height: height,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              cacheManager: ImageCacheManager.instance,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// Thumbnail image for list view
class ItemThumbnail extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  const ItemThumbnail({
    super.key,
    required this.url,
    this.width = 120,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>?>(
      future: MetadataCache.get(url),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data?["image"] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: SizedBox(
              width: width,
              height: height,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                cacheManager: ImageCacheManager.instance,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
