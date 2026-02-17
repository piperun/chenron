import "package:flutter/material.dart";
import "package:cache_manager/cache_manager.dart";
import "package:flutter_cache_manager/flutter_cache_manager.dart" as fcm;
import "package:signals/signals_flutter.dart";
import "package:chenron/components/metadata_factory.dart";

bool _isValidImageUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && uri.hasScheme && uri.hasAuthority;
}

// OG:image header for links
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

class _ItemImageHeaderState extends State<ItemImageHeader> {
  late Future<List<dynamic>> _future;
  void Function()? _disposeEffect;

  @override
  void initState() {
    super.initState();
    _initFuture();
    _listenForRefresh();
  }

  void _initFuture() {
    _future = Future.wait([
      MetadataFactory.getOrFetch(widget.url),
      ImageCacheManager.instance,
    ]);
  }

  void _listenForRefresh() {
    _disposeEffect = effect(() {
      final refreshed = MetadataFactory.lastRefreshedUrl.value;
      if (refreshed == widget.url) {
        setState(_initFuture);
      }
    });
  }

  @override
  void dispose() {
    _disposeEffect?.call();
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

// Thumbnail image for list view
class ItemThumbnail extends StatefulWidget {
  final String url;
  final double width;
  final double height;

  const ItemThumbnail({
    super.key,
    required this.url,
    this.width = 120,
    this.height = 80,
  });

  @override
  State<ItemThumbnail> createState() => _ItemThumbnailState();
}

class _ItemThumbnailState extends State<ItemThumbnail> {
  late Future<List<dynamic>> _future;
  void Function()? _disposeEffect;

  @override
  void initState() {
    super.initState();
    _initFuture();
    _listenForRefresh();
  }

  void _initFuture() {
    _future = Future.wait([
      MetadataFactory.getOrFetch(widget.url),
      ImageCacheManager.instance,
    ]);
  }

  void _listenForRefresh() {
    _disposeEffect = effect(() {
      final refreshed = MetadataFactory.lastRefreshedUrl.value;
      if (refreshed == widget.url) {
        setState(_initFuture);
      }
    });
  }

  @override
  void dispose() {
    _disposeEffect?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _ImagePlaceholder(
            height: widget.height,
            width: widget.width,
            iconSize: 32,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          );
        }

        final metadata = snapshot.data![0] as Map<String, dynamic>?;
        final cacheManager = snapshot.data![1] as fcm.BaseCacheManager;
        final imageUrl = metadata?["image"] as String?;

        if (imageUrl != null && _isValidImageUrl(imageUrl)) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                cacheManager: cacheManager,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _ImagePlaceholder(
                  height: widget.height,
                  width: widget.width,
                  iconSize: 32,
                ),
              ),
            ),
          );
        }
        return _ImagePlaceholder(
          height: widget.height,
          width: widget.width,
          iconSize: 32,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        );
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double height;
  final double? width;
  final double iconSize;
  final BorderRadius? borderRadius;

  const _ImagePlaceholder({
    required this.height,
    this.width,
    required this.iconSize,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final container = Container(
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

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: container,
      );
    }
    return container;
  }
}
