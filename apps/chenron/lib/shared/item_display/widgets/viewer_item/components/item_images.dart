import "package:flutter/material.dart";
import "package:cache_manager/cache_manager.dart";
import "package:flutter_cache_manager/flutter_cache_manager.dart" as fcm;
import "package:chenron/components/metadata_factory.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/components/metadata_lifecycle_mixin.dart";

bool _isValidImageUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && uri.hasScheme && uri.hasAuthority;
}

class ItemImageHeader extends StatefulWidget {
  final String url;
  final double height;

  const ItemImageHeader({
    super.key,
    required this.url,
    this.height = 120,
  });

  @override
  State<ItemImageHeader> createState() => _ItemImageHeaderState();
}

class _ItemImageHeaderState extends State<ItemImageHeader>
    with MetadataLifecycleMixin {
  late Future<List<dynamic>> _future;

  @override
  String? get metadataUrl => widget.url;

  @override
  void onMetadataRefreshed() => setState(_initFuture);

  @override
  void initState() {
    super.initState();
    _initFuture();
    initMetadataRefreshListener();
  }

  void _initFuture() {
    _future = Future.wait([
      MetadataFactory.getOrFetch(widget.url),
      ImageCacheManager.instance,
    ]);
  }

  @override
  void dispose() {
    disposeMetadataRefreshListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _ImagePlaceholder(height: widget.height, iconSize: 40);
        }

        final metadata = snapshot.data![0] as Map<String, dynamic>?;
        final cacheManager = snapshot.data![1] as fcm.BaseCacheManager;
        final imageUrl = metadata?["image"] as String?;

        if (imageUrl != null && _isValidImageUrl(imageUrl)) {
          return SizedBox(
            height: widget.height,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              cacheManager: cacheManager,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              placeholder: (context, url) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) =>
                  _ImagePlaceholder(height: widget.height, iconSize: 40),
            ),
          );
        }
        return _ImagePlaceholder(height: widget.height, iconSize: 40);
      },
    );
  }
}

class ItemThumbnail extends StatefulWidget {
  final String url;
  final double width;
  final double? height;

  const ItemThumbnail({
    super.key,
    required this.url,
    this.width = 120,
    this.height,
  });

  @override
  State<ItemThumbnail> createState() => _ItemThumbnailState();
}

class _ItemThumbnailState extends State<ItemThumbnail>
    with MetadataLifecycleMixin {
  late Future<List<dynamic>> _future;

  @override
  String? get metadataUrl => widget.url;

  @override
  void onMetadataRefreshed() => setState(_initFuture);

  @override
  void initState() {
    super.initState();
    _initFuture();
    initMetadataRefreshListener();
  }

  void _initFuture() {
    _future = Future.wait([
      MetadataFactory.getOrFetch(widget.url),
      ImageCacheManager.instance,
    ]);
  }

  @override
  void dispose() {
    disposeMetadataRefreshListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;

    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _ImagePlaceholder(
            height: h ?? double.infinity,
            width: widget.width,
            iconSize: 32,
          );
        }

        final metadata = snapshot.data![0] as Map<String, dynamic>?;
        final cacheManager = snapshot.data![1] as fcm.BaseCacheManager;
        final imageUrl = metadata?["image"] as String?;

        if (imageUrl != null && _isValidImageUrl(imageUrl)) {
          return SizedBox(
            width: widget.width,
            height: h,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              cacheManager: cacheManager,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorWidget: (context, url, error) => _ImagePlaceholder(
                height: h ?? double.infinity,
                width: widget.width,
                iconSize: 32,
              ),
            ),
          );
        }
        return _ImagePlaceholder(
          height: h ?? double.infinity,
          width: widget.width,
          iconSize: 32,
        );
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double height;
  final double? width;
  final double iconSize;

  const _ImagePlaceholder({
    required this.height,
    this.width,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      width: width ?? double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: iconSize,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
