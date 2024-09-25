import 'package:flutter/material.dart';
import 'package:metadata_fetch/metadata_fetch.dart';

enum MetadataType { title, description, image, url }

class MetadataFactory {
  static final Map<String, Metadata?> _cache = {};
  static final Map<String, MetadataWidget> _widgetCache = {};

  static Future<MetadataWidget> createMetadataWidget(String url) async {
    if (!_cache.containsKey(url)) {
      _cache[url] = await MetadataFetch.extract(url);
    }

    final metadata = _cache[url];
    final cacheKey = _getCacheKey(metadata);

    return _widgetCache.putIfAbsent(
      cacheKey,
      () => MetadataWidget(url: url, metadata: metadata),
    );
  }

  static String _getCacheKey(Metadata? metadata) {
    if (metadata?.title != null) {
      return 'title:${metadata!.title}';
    } else if (metadata?.image != null) {
      return 'image:${metadata!.image}';
    } else {
      return 'url:${metadata?.url ?? ''}';
    }
  }
}

class MetadataWidget {
  final String url;
  final Metadata? metadata;

  MetadataWidget({required this.url, this.metadata});

  Widget buildTitle() => MetadataTitle(widget: this);
  Widget buildDescription() => MetadataDescription(widget: this);
  Widget buildImage() => MetadataImage(widget: this);
  Widget buildUrl() => MetadataUrl(widget: this);
}

class MetadataTitle extends StatelessWidget {
  final MetadataWidget widget;

  const MetadataTitle({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Metadata?>(
      future: MetadataFetch.extract(widget.url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        } else if (snapshot.hasError) {
          return Text(widget.url);
        } else {
          return Text(
            snapshot.data?.title ?? widget.url,
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Metadata?>(
      future: MetadataFetch.extract(widget.url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        } else if (snapshot.hasError) {
          return const Text('No description available');
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.url,
                style: const TextStyle(color: Colors.blue),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (snapshot.data?.description != null)
                Text(
                  snapshot.data!.description!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          );
        }
      },
    );
  }
}

class MetadataImage extends StatelessWidget {
  final MetadataWidget widget;

  const MetadataImage({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Metadata?>(
      future: MetadataFetch.extract(widget.url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError || snapshot.data?.image == null) {
          return const SizedBox();
        } else {
          return Image.network(snapshot.data!.image!);
        }
      },
    );
  }
}

class MetadataUrl extends StatelessWidget {
  final MetadataWidget widget;

  const MetadataUrl({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Metadata?>(
      future: MetadataFetch.extract(widget.url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        } else if (snapshot.hasError) {
          return Text(widget.url);
        } else {
          return Text(snapshot.data?.url ?? widget.url);
        }
      },
    );
  }
}
