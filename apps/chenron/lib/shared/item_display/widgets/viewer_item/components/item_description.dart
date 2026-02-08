import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:chenron/components/metadata_factory.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";

// Description widget
class ItemDescription extends StatefulWidget {
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
  State<ItemDescription> createState() => _ItemDescriptionState();
}

class _ItemDescriptionState extends State<ItemDescription> {
  Future<Map<String, dynamic>?>? _metadataFuture;

  @override
  void initState() {
    super.initState();
    _initFuture();
  }

  void _initFuture() {
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }
          final description = snapshot.data?["description"] as String?;
          if (description != null) {
            return Text(
              description,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color
                    ?.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
              softWrap: true,
              maxLines: widget.maxLines,
              overflow: TextOverflow.ellipsis,
            );
          }
          return const SizedBox.shrink();
        },
      );
    }

    return Text(
      ItemUtils.getItemSubtitle(widget.item),
      style: TextStyle(
        fontSize: 13,
        height: 1.4,
        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
      ),
      maxLines: widget.maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
