import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:chenron/components/metadata_factory.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/components/metadata_lifecycle_mixin.dart";

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

class _ItemDescriptionState extends State<ItemDescription>
    with MetadataLifecycleMixin {
  Future<Map<String, dynamic>?>? _metadataFuture;

  @override
  String? get metadataUrl => widget.url;

  @override
  void onMetadataRefreshed() {
    setState(() {
      _metadataFuture = MetadataFactory.getOrFetch(widget.url!);
    });
  }

  @override
  void initState() {
    super.initState();
    _initFuture();
    initMetadataRefreshListener();
  }

  void _initFuture() {
    if (widget.item.type == FolderItemType.link &&
        widget.url != null &&
        widget.url!.isNotEmpty) {
      _metadataFuture = MetadataFactory.getOrFetch(widget.url!);
    }
  }

  @override
  void dispose() {
    disposeMetadataRefreshListener();
    super.dispose();
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
                color: theme.colorScheme.onSurfaceVariant,
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
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: widget.maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
