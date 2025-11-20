import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/components/metadata_factory.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";

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
        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
