/// Parses the timestamp from an Archive.org Wayback Machine URL.
///
/// [url] is the archived URL (e.g., `https://web.archive.org/web/20231027120000/https://example.com`).
///
/// Returns a [DateTime] object representing the capture time, or `null` if the URL format is invalid.
DateTime? parseArchiveDate(String url) {
  final regex = RegExp(r"/web/(\d{14})/");
  final match = regex.firstMatch(url);

  if (match != null && match.groupCount >= 1) {
    final dateString = match.group(1);
    if (dateString != null) {
      try {
        return DateTime.parse("${dateString.substring(0, 8)}"
            "T${dateString.substring(8)}");
      } catch (e) {
        rethrow;
      }
    }
  }

  return null;
}
