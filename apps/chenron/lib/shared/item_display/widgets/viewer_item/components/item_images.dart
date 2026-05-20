import "package:cache_manager/cache_manager.dart";
import "package:flutter/material.dart";
import "package:flutter_cache_manager/flutter_cache_manager.dart" as fcm;
import "package:signals/signals_flutter.dart";

const _videoExtensions = {".mp4", ".webm", ".mov", ".avi", ".mkv", ".flv"};

bool _isValidImageUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) return false;

  // Some sites put video URLs in og:image — reject those to avoid
  // downloading entire video files into the image cache.
  final path = uri.path.toLowerCase();
  return !_videoExtensions.any(path.endsWith);
}

/// Card-mode "hero" image atop a viewer item.
///
/// Reads the OG image URL from the injected [metadata] signal; while
/// loading or on failure shows a neutral placeholder.
class ItemImageHeader extends StatefulWidget {
  final String url;
  final Signal<MetadataState>? metadata;
  final double height;

  const ItemImageHeader({
    super.key,
    required this.url,
    this.metadata,
    this.height = 120,
  });

  @override
  State<ItemImageHeader> createState() => _ItemImageHeaderState();
}

class _ItemImageHeaderState extends State<ItemImageHeader> {
  /// Resolved lazily — the flutter_cache_manager singleton is heavy to
  /// build but immutable once initialised, so we hold it on the State.
  late final Future<fcm.BaseCacheManager> _cacheManagerFuture;

  @override
  void initState() {
    super.initState();
    _cacheManagerFuture = ImageCacheManager.instance;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<fcm.BaseCacheManager>(
      future: _cacheManagerFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _ImagePlaceholder(height: widget.height, iconSize: 40);
        }
        final cacheManager = snapshot.data!;
        final metadataSignal = widget.metadata;

        if (metadataSignal == null) {
          return _ImagePlaceholder(height: widget.height, iconSize: 40);
        }

        return Watch((context) {
          final state = metadataSignal.value;
          final imageUrl = switch (state) {
            MetadataStateReady(:final data) => data.imageUrl,
            MetadataStateLoading() => null,
            MetadataStateFailed() => null,
          };
          if (imageUrl != null && _isValidImageUrl(imageUrl)) {
            return _NetworkImageBox(
              imageUrl: imageUrl,
              cacheManager: cacheManager,
              height: widget.height,
              iconSize: 40,
            );
          }
          return _ImagePlaceholder(height: widget.height, iconSize: 40);
        });
      },
    );
  }
}

/// List-mode thumbnail rendered to the left of card content.
class ItemThumbnail extends StatefulWidget {
  final String url;
  final Signal<MetadataState>? metadata;
  final double width;
  final double? height;

  const ItemThumbnail({
    super.key,
    required this.url,
    this.metadata,
    this.width = 120,
    this.height,
  });

  @override
  State<ItemThumbnail> createState() => _ItemThumbnailState();
}

class _ItemThumbnailState extends State<ItemThumbnail> {
  late final Future<fcm.BaseCacheManager> _cacheManagerFuture;

  @override
  void initState() {
    super.initState();
    _cacheManagerFuture = ImageCacheManager.instance;
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;

    return FutureBuilder<fcm.BaseCacheManager>(
      future: _cacheManagerFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _ImagePlaceholder(
            height: h ?? double.infinity,
            width: widget.width,
            iconSize: 32,
          );
        }
        final cacheManager = snapshot.data!;
        final metadataSignal = widget.metadata;

        if (metadataSignal == null) {
          return _ImagePlaceholder(
            height: h ?? double.infinity,
            width: widget.width,
            iconSize: 32,
          );
        }

        return Watch((context) {
          final state = metadataSignal.value;
          final imageUrl = switch (state) {
            MetadataStateReady(:final data) => data.imageUrl,
            MetadataStateLoading() => null,
            MetadataStateFailed() => null,
          };
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
        });
      },
    );
  }
}

class _NetworkImageBox extends StatelessWidget {
  final String imageUrl;
  final fcm.BaseCacheManager cacheManager;
  final double height;
  final double iconSize;

  const _NetworkImageBox({
    required this.imageUrl,
    required this.cacheManager,
    required this.height,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
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
            _ImagePlaceholder(height: height, iconSize: iconSize),
      ),
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
