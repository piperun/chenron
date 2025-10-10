import "package:chenron/utils/logger.dart";
import "package:chenron/utils/str_sanitizer.dart";
import "package:flutter/material.dart";
import "package:cache_manager/cache_manager.dart";

enum MetadataType { title, description, image, url }

class MetadataFactory {
  static final Map<String, MetadataWidget> _widgetCache = {};

  static Future<MetadataWidget> createMetadataWidget(String url) async {
    final cacheKey = "widget_$url";

    if (_widgetCache.containsKey(cacheKey)) {
      return _widgetCache[cacheKey]!;
    }

    // Use MetadataCache instead of direct SharedPreferences
    final metadata = await MetadataCache.get(url);

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
    if (widget.metadata != null) return widget.metadata;
    return await MetadataCache.get(widget.url);
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

  const MetadataDescription({super.key, required this.widget});

  Future<Map<String, dynamic>?> _getCachedMetadata() async {
    if (widget.metadata != null) return widget.metadata;
    return await MetadataCache.get(widget.url);
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
    return await MetadataCache.get(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getCachedMetadata(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
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
    return await MetadataCache.get(widget.url);
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
