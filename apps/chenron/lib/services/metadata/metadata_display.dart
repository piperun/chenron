import "package:cache_manager/cache_manager.dart";
import "package:chenron/services/metadata/metadata_quality.dart";

const _queryKeys = [
  "tags",
  "tag",
  "q",
  "query",
  "search",
  "title",
  "name",
  "id",
];

const _genericPathSegments = {
  "index",
  "index.html",
  "index.htm",
  "index.php",
  "home",
};

String inferMetadataTitle(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return url;

  final siteLabel = _siteLabel(uri.host);
  final queryValue = _meaningfulQueryValue(uri);
  final pathValue = _meaningfulPathSegment(uri);
  final subject = _humanize(queryValue ?? pathValue);
  if (subject == null) return siteLabel;
  return "$subject — $siteLabel";
}

String resolveMetadataDisplayTitle(String url, MetadataState state) {
  if (state case MetadataStateAvailable(:final data)) {
    final title = data.title?.trim();
    if (title != null &&
        title.isNotEmpty &&
        !isDomainPlaceholderTitle(title, url)) {
      return title;
    }
  }
  return inferMetadataTitle(url);
}

String? _meaningfulQueryValue(Uri uri) {
  for (final key in _queryKeys) {
    final value = uri.queryParameters[key]?.trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

String? _meaningfulPathSegment(Uri uri) {
  for (final segment in uri.pathSegments.reversed) {
    final value = segment.trim();
    if (value.isNotEmpty &&
        !_genericPathSegments.contains(value.toLowerCase())) {
      return value;
    }
  }
  return null;
}

String? _humanize(String? value) {
  if (value == null) return null;
  final humanized = value
      .replaceAll(RegExp(r"[+_-]+"), " ")
      .replaceAll(RegExp(r"\s+"), " ")
      .trim();
  return humanized.isEmpty ? null : humanized;
}

String _siteLabel(String host) {
  final withoutWww = host.toLowerCase().replaceFirst(RegExp(r"^www\."), "");
  final labels = withoutWww.split(".");
  final core = labels.length > 1
      ? labels.sublist(0, labels.length - 1).join(".")
      : withoutWww;
  return core.isEmpty
      ? withoutWww
      : "${core[0].toUpperCase()}${core.substring(1)}";
}
