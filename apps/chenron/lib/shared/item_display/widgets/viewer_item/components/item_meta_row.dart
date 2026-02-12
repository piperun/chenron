import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:chenron/components/favicon_display/favicon.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";
import "package:chenron/shared/item_detail/item_detail_dialog.dart";
import "package:chenron/shared/utils/time_formatter.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/locator.dart";
import "package:signals/signals_flutter.dart";

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
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            " • ",
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          _TimeDisplay(item: item),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => showItemDetailDialog(context, itemId: item.id!, itemType: item.type),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(2),
              alignment: Alignment.center,
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
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
        _TimeDisplay(item: item),
        const Spacer(),
        InkWell(
          onTap: () => showItemDetailDialog(context, itemId: item.id!, itemType: item.type),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(2),
            alignment: Alignment.center,
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget to display time with tooltip based on user preference
class _TimeDisplay extends StatelessWidget {
  final FolderItem item;

  const _TimeDisplay({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = locator.get<ConfigController>();

    return Watch(
      (context) {
        final timeFormat =
            TimeDisplayFormat.values[controller.timeDisplayFormat.value];

        final addedAt = item.map(
          link: (linkItem) => linkItem.addedAt,
          document: (docItem) => docItem.addedAt,
          folder: (folderItem) => folderItem.addedAt,
        );

        final createdAt = item.map(
          link: (linkItem) => linkItem.createdAt ?? DateTime.now(),
          document: (docItem) => docItem.createdAt ?? DateTime.now(),
          folder: (folderItem) => folderItem.createdAt ?? DateTime.now(),
        );

        final date = addedAt ?? createdAt;
        final prefix = addedAt != null ? "added " : "";
        final displayText =
            "$prefix${TimeFormatter.format(date, timeFormat)}";
        final tooltipText = addedAt != null
            ? "Added to folder: ${TimeFormatter.formatTooltip(date)}"
            : TimeFormatter.formatTooltip(date);

        return Tooltip(
          message: tooltipText,
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
