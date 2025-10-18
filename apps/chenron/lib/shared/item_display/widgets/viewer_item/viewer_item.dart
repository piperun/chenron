import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/card_view.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/row_item.dart";

enum PreviewMode {
  card,
  list,
}

class ViewerItem extends StatelessWidget {
  final FolderItem item;
  final PreviewMode mode;
  final VoidCallback? onTap;
  final bool showImage;

  const ViewerItem({
    super.key,
    required this.item,
    this.mode = PreviewMode.card,
    this.onTap,
    this.showImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return mode == PreviewMode.card
        ? CardItem(item: item, onTap: onTap, showImage: showImage)
        : RowItem(item: item, onTap: onTap, showImage: showImage);
  }
}
