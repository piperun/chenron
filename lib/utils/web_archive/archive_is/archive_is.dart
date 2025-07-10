import 'dart:async';
import 'dart:convert'; // For Uri.encodeComponent if needed, though http handles it
import 'package:chenron/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

class ArchiveIsClient {
  final String defaultUserAgent =
      "ChenronFlutterClient/1.0 (https://github.com/piperun/chenron-flutter; dart:http)";
  final Duration defaultTimeout = const Duration(seconds: 120);

  ArchiveIsClient(); // No API keys needed

  /// Attempts to find the currently active domain for archive.is (e.g., .is, .today, .ph)
  /// by following redirects from a known starting point.
  Future<String> _findCurrentDomain(http.Client client,
      {String startDomain = "https://archive.is"}) async {
    loggerGlobal.info("ArchiveIsClient",
        "Attempting to find current domain starting from $startDomain");
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
        loggerGlobal.info(
            "ArchiveIsClient", "Found current domain: $currentDomain");
        return currentDomain;
      } else {
        loggerGlobal.warning("ArchiveIsClient",
            "Could not reliably determine current domain from $startDomain. Status: ${response.statusCode}. Falling back to $startDomain");
        // Fallback to the starting domain if detection fails
        return startDomain;
      }
    } catch (e) {
      loggerGlobal.severe("ArchiveIsClient",
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
      final element = document.querySelector('input[name="submitid"]');
      if (element != null) {
        final submitId = element.attributes['value'];
        if (submitId != null && submitId.isNotEmpty) {
          loggerGlobal.info("ArchiveIsClient", "Extracted submitid: $submitId");
          return submitId;
        }
      }
    } catch (e) {
      loggerGlobal.warning(
          "ArchiveIsClient", "Could not parse submitid from HTML: $e");
    }
    loggerGlobal.info("ArchiveIsClient", "Could not find submitid in HTML.");
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
        loggerGlobal.info(
            "ArchiveIsClient", "GET $currentDomain to find submitid");
        final homeResponse = await client
            .get(domainUri, headers: headers)
            .timeout(defaultTimeout);
        if (homeResponse.statusCode == 200) {
          submitId = _extractSubmitId(homeResponse.body);
        } else {
          loggerGlobal.warning("ArchiveIsClient",
              "Failed to GET homepage ($currentDomain): ${homeResponse.statusCode}");
        }
      } catch (e) {
        loggerGlobal.warning(
            "ArchiveIsClient", "Error during homepage GET for submitid: $e");
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
        loggerGlobal.info(
            "ArchiveIsClient", "Using submitid $submitId for POST");
      } else {
        loggerGlobal.info(
            "ArchiveIsClient", "Proceeding without submitid for POST");
      }

      // 4. POST to submit URL - DO NOT follow redirects automatically
      loggerGlobal.info(
          "ArchiveIsClient", "POST $submitUrl with target: $targetUrl");
      final request = http.Request('POST', submitUrl)
        ..headers.addAll(headers)
        ..followRedirects =
            false // Important: We need to check headers before redirect
        ..bodyFields =
            body; // Use bodyFields for application/x-www-form-urlencoded

      final streamedResponse =
          await client.send(request).timeout(defaultTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      // 5. Check response headers for the memento URL
      loggerGlobal.info("ArchiveIsClient",
          "Checking POST response. Status: ${response.statusCode}");
      // loggerGlobal.debug("ArchiveIsClient", "Response Headers: ${response.headers}"); // Optional: Debug headers

      // Check Refresh header (often used for immediate redirect)
      if (response.headers.containsKey('refresh')) {
        final refreshHeader = response.headers['refresh']!;
        final parts = refreshHeader.split(';url=');
        if (parts.length == 2) {
          final memento = parts[1];
          loggerGlobal.info("ArchiveIsClient",
              "Success: Found memento in Refresh header: $memento");
          return memento;
        }
      }

      // Check Location header (standard for redirects, status 3xx)
      if ((response.statusCode >= 300 && response.statusCode < 400) &&
          response.headers.containsKey('location')) {
        final memento = response.headers['location']!;
        // Sometimes the location might be relative, resolve it against the domain
        final mementoUri = Uri.parse(memento);
        if (!mementoUri.hasScheme) {
          final resolvedMemento = domainUri.resolve(memento).toString();
          loggerGlobal.info("ArchiveIsClient",
              "Success: Found relative memento in Location header, resolved to: $resolvedMemento");
          return resolvedMemento;
        } else {
          loggerGlobal.info("ArchiveIsClient",
              "Success: Found absolute memento in Location header: $memento");
          return memento;
        }
      }

      // If we reach here, no memento was found in the expected headers
      loggerGlobal.severe("ArchiveIsClient",
          "Archiving failed for $targetUrl. Memento URL not found in response headers.");
      loggerGlobal.severe(
          "ArchiveIsClient", "Response Status: ${response.statusCode}");
      loggerGlobal.severe("ArchiveIsClient",
          "Response Body (truncated): ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}");
      throw Exception(
          "Archiving failed: Memento URL not found in archive.is response.");
    } catch (e) {
      loggerGlobal.severe(
          "ArchiveIsClient", "Error during archiveUrl for $targetUrl: $e");
      rethrow; // Rethrow the exception to be handled by the caller
    } finally {
      client.close(); // Ensure the client is always closed
    }
  }
}
