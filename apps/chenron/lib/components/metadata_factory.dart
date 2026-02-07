import "package:logger/logger.dart";
import "package:core/utils/str_sanitizer.dart";
import "package:chenron/utils/metadata.dart";
import "package:flutter/material.dart";
import "package:cache_manager/cache_manager.dart";

enum MetadataType { title, description, image, url }

class MetadataFactory {
  static final Map<String, MetadataWidget> _widgetCache = {};

  /// Get cached metadata; if missing or stale, fetch fresh from web and cache it.
  static Future<Map<String, dynamic>?> getOrFetch(String url) async {
    // Try cache (returns null if MISS or STALE)
    final cached = await MetadataCache.get(url);
    if (cached != null) return cached;

    // Avoid duplicate concurrent fetches
    if (MetadataCache.isFetching(url)) return null;
    if (!MetadataCache.shouldRetry(url)) return null;

    try {
      MetadataCache.startFetching(url);
      final fetched = await MetadataFetcher.fetch(url);
      final data = <String, dynamic>{
        "title": fetched.title,
        "description": fetched.description,
        "image": fetched.image,
        "url": fetched.url ?? url,
      };
      await MetadataCache.set(url, data);
      MetadataCache.clearFailure(url);
      return data;
    } catch (e) {
      MetadataCache.recordFailure(url);
      return null;
    } finally {
      MetadataCache.stopFetching(url);
    }
  }

  static Future<MetadataWidget> createMetadataWidget(String url) async {
    final cacheKey = "widget_$url";

    if (_widgetCache.containsKey(cacheKey)) {
      return _widgetCache[cacheKey]!;
    }

    // Try cache or fetch on miss
    final metadata = await getOrFetch(url);

    final widget = MetadataWidget(url: url, metadata: metadata);
    _widgetCache[cacheKey] = widget;

    return widget;
  }
}

class MetadataWidget {
  final String url;
  final Map<String, dynamic>? metadata;

  MetadataWidget({required this.url, this.metadata});

  Widget buildTitle() => MetadataTitle(widget: this);
  Widget buildDescription() => MetadataDescription(widget: this);
  Widget buildImage() => MetadataImage(widget: this);
  Widget buildUrl() => MetadataUrl(widget: this);
}

class MetadataTitle extends StatelessWidget {
  final MetadataWidget widget;

  const MetadataTitle({super.key, required this.widget});

  Future<Map<String, dynamic>?> _getCachedMetadata() async {
    if (widget.metadata != null) {
      loggerGlobal.info(
        "MetadataTitle",
        "Using provided metadata for: ${widget.url} | Title: ${widget.metadata?['title'] ?? 'N/A'}",
      );
      return widget.metadata;
    }
    final data = await MetadataFactory.getOrFetch(widget.url);
    if (data != null) {
      loggerGlobal.info(
        "MetadataTitle",
        "Loaded metadata for: ${widget.url} | Title: ${data['title'] ?? 'N/A'}",
      );
    } else {
      loggerGlobal.warning(
        "MetadataTitle",
        "No metadata available for: ${widget.url}",
      );
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getCachedMetadata(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        } else if (snapshot.hasError) {
          return Text(widget.url);
        } else {
          final title = snapshot.data?["title"] as String? ?? "";
          return Text(
            removeDupSpaces(title),
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }
      },
    );
  }
}

class MetadataDescription extends StatelessWidget {
  final MetadataWidget widget;
  final int maxLines;

  const MetadataDescription({
    super.key,
    required this.widget,
    this.maxLines = 2,
  });

  Future<Map<String, dynamic>?> _getCachedMetadata() async {
    if (widget.metadata != null) return widget.metadata;
    return await MetadataFactory.getOrFetch(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getCachedMetadata(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        } else if (snapshot.hasError) {
          loggerGlobal.warning(
              "MetadataDescription", "Error: ${snapshot.error}");
          return const Text("No description available.");
        } else {
          final description = snapshot.data?["description"] as String?;
          if (description != null) {
            return Text(
              description,
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              softWrap: true,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            );
          }
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class MetadataImage extends StatelessWidget {
  final MetadataWidget widget;

  const MetadataImage({super.key, required this.widget});

  Future<Map<String, dynamic>?> _getCachedMetadata() async {
    if (widget.metadata != null) return widget.metadata;
    return await MetadataFactory.getOrFetch(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getCachedMetadata(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (snapshot.hasError) {
          return const SizedBox();
        } else {
          final imageUrl = snapshot.data?["image"] as String?;
          if (imageUrl != null) {
            return Image.network(imageUrl);
          }
          return const SizedBox();
        }
      },
    );
  }
}

class MetadataUrl extends StatelessWidget {
  final MetadataWidget widget;

  const MetadataUrl({super.key, required this.widget});

  Future<Map<String, dynamic>?> _getCachedMetadata() async {
    if (widget.metadata != null) return widget.metadata;
    return await MetadataFactory.getOrFetch(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getCachedMetadata(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        } else if (snapshot.hasError) {
          return Text(widget.url);
        } else {
          final url = snapshot.data?["url"] as String? ?? widget.url;
          return Text(url);
        }
      },
    );
  }
}

