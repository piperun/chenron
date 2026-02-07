import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:chenron/components/metadata_factory.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";

// Title widget
class ItemTitle extends StatefulWidget {
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
  State<ItemTitle> createState() => _ItemTitleState();
}

class _ItemTitleState extends State<ItemTitle> {
  Future<Map<String, dynamic>?>? _metadataFuture;

  @override
  void initState() {
    super.initState();
    if (widget.item.type == FolderItemType.link &&
        widget.url != null &&
        widget.url!.isNotEmpty) {
      _metadataFuture = MetadataFactory.getOrFetch(widget.url!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_metadataFuture != null) {
      return FutureBuilder<Map<String, dynamic>?>(
        future: _metadataFuture,
        builder: (context, snapshot) {
          final title = snapshot.data?["title"] as String? ?? widget.url!;
          return Tooltip(
            message: title,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                height: 1.3,
                letterSpacing: 0,
              ),
              maxLines: widget.maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      );
    }

    // For folders and other items, use prominent styling
    final title = ItemUtils.getItemTitle(widget.item);
    return Tooltip(
      message: title,
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: widget.item.type == FolderItemType.folder ? 16 : 15,
          height: 1.3,
          color: widget.item.type == FolderItemType.folder
              ? theme.colorScheme.onSurface
              : null,
          letterSpacing: widget.item.type == FolderItemType.folder ? 0.1 : 0,
        ),
        maxLines: widget.maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
