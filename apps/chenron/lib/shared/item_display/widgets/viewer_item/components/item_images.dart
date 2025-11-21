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
        if (!snapshot.hasData) return _buildPlaceholder(theme);

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
              errorWidget: (context, url, error) => _buildPlaceholder(theme),
            ),
          );
        }
        // Show placeholder if no image URL
        return _buildPlaceholder(theme);
      },
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      height: height,
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
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
    final theme = Theme.of(context);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        MetadataFactory.getOrFetch(url),
        ImageCacheManager.instance,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildThumbnailPlaceholder(theme);

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
                errorWidget: (context, url, error) =>
                    _buildThumbnailPlaceholder(theme),
              ),
            ),
          );
        }
        // Show placeholder if no image URL
        return _buildThumbnailPlaceholder(theme);
      },
    );
  }

  Widget _buildThumbnailPlaceholder(ThemeData theme) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: Container(
        width: width,
        height: height,
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 32,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}
