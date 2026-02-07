import "package:chenron/utils/metadata.dart";
import "package:cache_manager/cache_manager.dart";

class MetadataFactory {
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
}
