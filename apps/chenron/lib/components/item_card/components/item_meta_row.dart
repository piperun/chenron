import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/components/favicon_display/favicon.dart";
import "package:chenron/components/item_card/item_utils.dart";
import "package:chenron/components/item_card/item_info_modal.dart";

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
          const SizedBox(width: 6),
          InkWell(
            onTap: () => showItemInfoModal(context, item),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(2),
              alignment: Alignment.center,
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.primary.withOpacity(0.7),
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
        Text(
          "1d ago",
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () => showItemInfoModal(context, item),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(2),
            alignment: Alignment.center,
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}
