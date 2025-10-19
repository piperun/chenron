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
  final int maxTags;
  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;

  const ViewerItem({
    super.key,
    required this.item,
    this.mode = PreviewMode.card,
    this.onTap,
    this.showImage = true,
    this.maxTags = 5,
    this.includedTagNames = const {},
    this.excludedTagNames = const {},
  });

  @override
  Widget build(BuildContext context) {
    return mode == PreviewMode.card
        ? CardItem(
            item: item,
            onTap: onTap,
            showImage: showImage,
            maxTags: maxTags,
            includedTagNames: includedTagNames,
            excludedTagNames: excludedTagNames,
          )
        : RowItem(
            item: item,
            onTap: onTap,
            showImage: showImage,
            maxTags: maxTags,
            includedTagNames: includedTagNames,
            excludedTagNames: excludedTagNames,
          );
  }
}
