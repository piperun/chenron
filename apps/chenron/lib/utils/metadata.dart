import "package:metadata_fetch/metadata_fetch.dart";
import "package:app_logger/app_logger.dart";

class MetadataFetcher {
  final String? title;
  final String? description;
  final String? image;
  final String? url;

  MetadataFetcher({this.title, this.description, this.image, this.url});

  static Future<MetadataFetcher> fetch(String url) async {
    loggerGlobal.info("MetadataFetcher", "Fetching metadata for: $url");
    try {
      final metadata = await MetadataFetch.extract(url);
      loggerGlobal.info(
        "MetadataFetcher",
        "Successfully fetched metadata for: $url | Title: ${metadata?.title ?? 'N/A'} | Description: ${metadata?.description != null ? '${metadata!.description!.substring(0, metadata.description!.length > 50 ? 50 : metadata.description!.length)}...' : 'N/A'} | Image: ${metadata?.image != null ? 'Yes' : 'No'}",
      );
      return MetadataFetcher(
        title: metadata?.title,
        description: metadata?.description,
        image: metadata?.image,
        url: metadata?.url,
      );
    } catch (e) {
      loggerGlobal.warning(
        "MetadataFetcher",
        "Failed to fetch metadata for: $url | Error: $e",
      );
      rethrow;
    }
  }
}

