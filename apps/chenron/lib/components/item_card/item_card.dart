import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/components/item_card/card_view.dart";
import "package:chenron/components/item_card/list_view.dart";

enum PreviewMode {
  card,
  list,
}

class ItemCard extends StatelessWidget {
  final FolderItem item;
  final PreviewMode mode;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.item,
    this.mode = PreviewMode.card,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return mode == PreviewMode.card
        ? ItemCardView(item: item, onTap: onTap)
        : ItemListView(item: item, onTap: onTap);
  }
}
