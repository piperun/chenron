import "dart:convert";

import "package:html/parser.dart" as html_parser;
import "package:html/dom.dart";

class ParsedMetadata {
  final String? title;
  final String? description;
  final String? imageUrl;

  const ParsedMetadata({this.title, this.description, this.imageUrl});
}

ParsedMetadata parseMetadataDocument(String body, {required Uri baseUri}) {
  final document = html_parser.parse(body);
  final jsonLd = _firstJsonLdMetadata(document);

  final image = _firstNonEmpty([
    _meta(document, "property", "og:image"),
    _meta(document, "name", "twitter:image"),
    jsonLd?.imageUrl,
  ]);

  return ParsedMetadata(
    title: _firstNonEmpty([
      _meta(document, "property", "og:title"),
      _meta(document, "name", "twitter:title"),
      jsonLd?.title,
      document.querySelector("title")?.text,
    ]),
    description: _firstNonEmpty([
      _meta(document, "property", "og:description"),
      _meta(document, "name", "twitter:description"),
      jsonLd?.description,
      _meta(document, "name", "description"),
    ]),
    imageUrl: image == null ? null : baseUri.resolve(image).toString(),
  );
}

String? _meta(Document document, String attribute, String value) => document
    .querySelector('meta[$attribute="$value"]')
    ?.attributes["content"]
    ?.trim();

String? _firstNonEmpty(Iterable<String?> values) {
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

ParsedMetadata? _firstJsonLdMetadata(Document document) {
  for (final element
      in document.querySelectorAll('script[type="application/ld+json"]')) {
    final decoded = _decodeJson(element.text);
    for (final object in _jsonLdObjects(decoded)) {
      final title = _firstNonEmpty([
        object["headline"] as String?,
        object["name"] as String?,
      ]);
      if (title == null) continue;
      return ParsedMetadata(
        title: title,
        description: object["description"] as String?,
        imageUrl: _jsonLdImage(object["image"]),
      );
    }
  }
  return null;
}

Object? _decodeJson(String value) {
  try {
    return jsonDecode(value);
  } on FormatException {
    return null;
  }
}

Iterable<Map<String, Object?>> _jsonLdObjects(Object? value) sync* {
  if (value is Map) {
    final object = Map<String, Object?>.from(value);
    yield object;
    final graph = object["@graph"];
    if (graph is List) {
      for (final item in graph) {
        yield* _jsonLdObjects(item);
      }
    }
  } else if (value is List) {
    for (final item in value) {
      yield* _jsonLdObjects(item);
    }
  }
}

String? _jsonLdImage(Object? value) {
  if (value is String) return value;
  if (value is List) return _jsonLdImage(value.firstOrNull);
  if (value is Map) return value["url"] as String?;
  return null;
}
