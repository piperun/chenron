import "package:flutter/material.dart";
import "package:cache_manager/cache_manager.dart";
import "package:flutter_cache_manager/flutter_cache_manager.dart" as fcm;
import "package:chenron/components/metadata_factory.dart";

// OG:image header for links
class ItemImageHeader extends StatelessWidget {
  final String url;
  final double height;

  const ItemImageHeader({
    super.key,
    required this.url,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        MetadataFactory.getOrFetch(url),
        ImageCacheManager.instance,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _ImagePlaceholder(height: height, iconSize: 40);
        }

        final metadata = snapshot.data![0] as Map<String, dynamic>?;
        final cacheManager = snapshot.data![1] as fcm.BaseCacheManager;
        final imageUrl = metadata?["image"] as String?;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          return SizedBox(
            height: height,
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
                  _ImagePlaceholder(height: height, iconSize: 40),
            ),
          );
        }
        return _ImagePlaceholder(height: height, iconSize: 40);
      },
    );
  }
}

// Thumbnail image for list view
class ItemThumbnail extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        MetadataFactory.getOrFetch(url),
        ImageCacheManager.instance,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _ImagePlaceholder(
            height: height,
            width: width,
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

        if (imageUrl != null && imageUrl.isNotEmpty) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: SizedBox(
              width: width,
              height: height,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                cacheManager: cacheManager,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _ImagePlaceholder(
                  height: height,
                  width: width,
                  iconSize: 32,
                ),
              ),
            ),
          );
        }
        return _ImagePlaceholder(
          height: height,
          width: width,
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
