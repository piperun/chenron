import "dart:async";
import "package:logging/logging.dart";
import "package:http/http.dart" as http;
import "package:html/parser.dart";

/// Client for archiving URLs using archive.is.
class ArchiveIsClient {
  /// Default user agent used for requests.
  final String defaultUserAgent =
      "ChenronFlutterClient/1.0 (https://github.com/piperun/chenron-flutter; dart:http)";

  /// Default timeout for requests.
  final Duration defaultTimeout = const Duration(seconds: 120);
  final _logger = Logger("ArchiveIsClient");

  /// Creates a new [ArchiveIsClient].
  ArchiveIsClient(); // No API keys needed

  /// Attempts to find the currently active domain for archive.is (e.g., .is, .today, .ph)
  /// by following redirects from a known starting point.
  Future<String> _findCurrentDomain(http.Client client,
      {String startDomain = "https://archive.is"}) async {
    _logger
        .info("Attempting to find current domain starting from $startDomain");
    try {
      // Use a HEAD request first as it's lighter, follow redirects
      final response =
          await client.head(Uri.parse(startDomain)).timeout(defaultTimeout);

      // The final URL after redirects should be in the request object of the response
      final finalUri = response.request?.url;

      if (finalUri != null &&
          (response.statusCode >= 200 && response.statusCode < 400)) {
        // Construct base domain (scheme + host)
        final currentDomain = "${finalUri.scheme}://${finalUri.host}";
        _logger.info("Found current domain: $currentDomain");
        return currentDomain;
      } else {
        _logger.warning(
            "Could not reliably determine current domain from $startDomain. Status: ${response.statusCode}. Falling back to $startDomain");
        // Fallback to the starting domain if detection fails
        return startDomain;
      }
    } catch (e) {
      _logger.severe(
          "Error finding current domain: $e. Falling back to $startDomain");
      // Fallback on any error
      return startDomain;
    }
  }

  /// Attempts to extract the 'submitid' from the homepage HTML.
  String? _extractSubmitId(String htmlBody) {
    try {
      final document = parse(htmlBody);
      // Find the input element with name="submitid"
      final element = document.querySelector("input[name='submitid']");
      if (element != null) {
        final submitId = element.attributes["value"];
        if (submitId != null && submitId.isNotEmpty) {
          _logger.info("Extracted submitid: $submitId");
          return submitId;
        }
      }
    } catch (e) {
      _logger.warning("Could not parse submitid from HTML: $e");
    }
    _logger.info("Could not find submitid in HTML.");
    return null;
  }

  /// Archives the target URL using archive.is.
  /// Returns the URL of the archived snapshot (memento).
  Future<String> archiveUrl(String targetUrl, {String? userAgent}) async {
    final client = http.Client();
    final effectiveUserAgent = userAgent ?? defaultUserAgent;
    String? currentDomain;

    try {
      // 1. Find the current domain
      currentDomain = await _findCurrentDomain(client);
      final domainUri = Uri.parse(currentDomain);
      final submitUrl =
          domainUri.resolve("/submit/"); // Use resolve for correct path joining

      final headers = {
        "User-Agent": effectiveUserAgent,
        "host": domainUri.host,
        // Archive.is might check referer or origin, though not explicitly in python script
        "Origin": currentDomain,
        "Referer": "$currentDomain/",
      };

      // 2. Get homepage to potentially extract submitid
      String? submitId;
      try {
        _logger.info("GET $currentDomain to find submitid");
        final homeResponse = await client
            .get(domainUri, headers: headers)
            .timeout(defaultTimeout);
        if (homeResponse.statusCode == 200) {
          submitId = _extractSubmitId(homeResponse.body);
        } else {
          _logger.warning(
              "Failed to GET homepage ($currentDomain): ${homeResponse.statusCode}");
        }
      } catch (e) {
        _logger.warning("Error during homepage GET for submitid: $e");
        // Continue without submitid if GET fails
      }

      // 3. Prepare POST data
      final Map<String, String> body = {
        "url": targetUrl,
        "anyway":
            "1", // Force capture even if recent snapshot exists? Matches python script.
      };
      if (submitId != null) {
        body["submitid"] = submitId;
        _logger.info("Using submitid $submitId for POST");
      } else {
        _logger.info("Proceeding without submitid for POST");
      }

      // 4. POST to submit URL - DO NOT follow redirects automatically
      _logger.info("POST $submitUrl with target: $targetUrl");
      final request = http.Request("POST", submitUrl)
        ..headers.addAll(headers)
        ..followRedirects =
            false // Important: We need to check headers before redirect
        ..bodyFields =
            body; // Use bodyFields for application/x-www-form-urlencoded

      final streamedResponse =
          await client.send(request).timeout(defaultTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      // 5. Check response headers for the memento URL
      _logger.info("Checking POST response. Status: ${response.statusCode}");
      // _logger.fine("Response Headers: ${response.headers}"); // Optional: Debug headers

      // Check Refresh header (often used for immediate redirect)
      if (response.headers.containsKey("refresh")) {
        final refreshHeader = response.headers["refresh"]!;
        final parts = refreshHeader.split(";url=");
        if (parts.length == 2) {
          final memento = parts[1];
          _logger.info("Success: Found memento in Refresh header: $memento");
          return memento;
        }
      }

      // Check Location header (standard for redirects, status 3xx)
      if ((response.statusCode >= 300 && response.statusCode < 400) &&
          response.headers.containsKey("location")) {
        final memento = response.headers["location"]!;
        // Sometimes the location might be relative, resolve it against the domain
        final mementoUri = Uri.parse(memento);
        if (!mementoUri.hasScheme) {
          final resolvedMemento = domainUri.resolve(memento).toString();
          _logger.info(
              "Success: Found relative memento in Location header, resolved to: $resolvedMemento");
          return resolvedMemento;
        } else {
          _logger.info(
              "Success: Found absolute memento in Location header: $memento");
          return memento;
        }
      }

      // If we reach here, no memento was found in the expected headers
      _logger.severe(
          "Archiving failed for $targetUrl. Memento URL not found in response headers.");
      _logger.severe("Response Status: ${response.statusCode}");
      _logger.severe(
          "Response Body (truncated): ${response.body.length > 500 ? "${response.body.substring(0, 500)}..." : response.body}");
      throw Exception(
          "Archiving failed: Memento URL not found in archive.is response.");
    } catch (e) {
      _logger.severe("Error during archiveUrl for $targetUrl: $e");
      rethrow; // Rethrow the exception to be handled by the caller
    } finally {
      client.close(); // Ensure the client is always closed
    }
  }
}
