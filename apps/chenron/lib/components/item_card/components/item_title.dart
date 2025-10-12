import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/components/metadata_factory.dart";
import "package:chenron/components/item_card/item_utils.dart";

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
