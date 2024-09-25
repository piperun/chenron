import 'package:metadata_fetch/metadata_fetch.dart';

class MetadataFetcher {
  final String? title;
  final String? description;
  final String? image;
  final String? url;

  MetadataFetcher({this.title, this.description, this.image, this.url});

  static Future<MetadataFetcher> fetch(String url) async {
    try {
      final metadata = await MetadataFetch.extract(url);
      return MetadataFetcher(
        title: metadata?.title,
        description: metadata?.description,
        image: metadata?.image,
        url: metadata?.url,
      );
    } catch (e) {
      rethrow;
    }
  }
}
