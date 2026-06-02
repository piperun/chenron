import 'dart:async';
import 'dart:convert';
import 'package:app_logger/app_logger.dart';
import 'package:http/http.dart' as http;
import 'package:web_archiver/src/archive_org/archive_org_options.dart';

/// Factory definition for creating an [ArchiveOrgClient].
typedef ArchiveOrgClientFactory = ArchiveOrgClient Function(
    String apiKey, String apiSecret);

/// Default factory that returns a real [ArchiveOrgClient]. Callers (the
/// archive processor, main setup) wire this through their constructors;
/// tests pass their own fake factory instead. There is no mutable global
/// — that pattern got reassigned across tests and leaked state.
ArchiveOrgClient defaultArchiveOrgClientFactory(
        String apiKey, String apiSecret) =>
    ArchiveOrgClient(apiKey, apiSecret);

const _source = 'ArchiveOrgClient';

/// A client for interacting with the Archive.org Wayback Machine API.
///
/// This client allows you to archive URLs, check the status of archiving jobs,
/// and wait for archiving to complete.
class ArchiveOrgClient {
  /// The API key for authentication.
  final String apiKey;

  /// The API secret for authentication.
  final String apiSecret;

  /// The base URL for the Archive.org API.
  final String baseUrl = "https://web.archive.org";

  /// Timeout for individual HTTP requests.
  static const httpTimeout = Duration(seconds: 30);

  /// Optional caller-owned HTTP client. When supplied (e.g. test fixtures), all
  /// requests route through it and it is **not** closed by this class — the
  /// caller owns its lifecycle. When null, the top-level one-shot `http.get`/
  /// `http.post` helpers are used (each opens and closes its own client), so
  /// production behavior is unchanged and there is nothing to dispose.
  final http.Client? _client;

  /// Creates a new [ArchiveOrgClient] with the given [apiKey] and [apiSecret].
  ///
  /// Pass [client] to inject an HTTP client (tests, connection reuse).
  ArchiveOrgClient(this.apiKey, this.apiSecret, {http.Client? client})
      : _client = client;

  Future<http.Response> _get(Uri url) =>
      (_client?.get(url) ?? http.get(url)).timeout(httpTimeout);

  Future<http.Response> _post(Uri url,
          {Map<String, String>? headers, Object? body}) =>
      (_client?.post(url, headers: headers, body: body) ??
              http.post(url, headers: headers, body: body))
          .timeout(httpTimeout);

  /// Checks if the provided credentials are valid by making a request to the status endpoint.
  ///
  /// Returns `true` if the status code is 200, indicating successful authentication.
  Future<bool> checkAuthentication() async {
    final response = await _get(Uri.parse("$baseUrl/save/status/"));
    return response.statusCode == 200;
  }

  /// Submits a URL to be archived.
  ///
  /// [targetUrl] is the URL you want to archive.
  /// [options] are optional parameters for the archiving request.
  ///
  /// Returns a job ID if the request is pending, or the archived URL if it succeeded immediately.
  /// Throws an [Exception] if the request fails.
  Future<String> archiveUrl(String targetUrl,
      {ArchiveOrgOptions? options}) async {
    try {
      final Map<String, dynamic> body = {"url": targetUrl};
      if (options != null) {
        body.addAll(options.toJson());
      }

      final response = await _post(
        Uri.parse("$baseUrl/save"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
          "Authorization": "LOW $apiKey:$apiSecret",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Decode defensively: the API can return malformed or unexpected JSON
        // (a bare value, a null field, a missing key). Treat anything that
        // doesn't match the expected shape as an error result rather than
        // letting a NoSuchMethodError / type error escape as a crash.
        final decoded = json.decode(response.body);
        if (decoded is! Map) {
          loggerGlobal.severe(_source,
              'Unexpected response body for $targetUrl (not a JSON object): ${response.body}');
          throw Exception(
              'Archiving failed: unexpected response body for $targetUrl');
        }
        final Map<String, dynamic> data =
            decoded.cast<String, dynamic>();
        switch (data["status"]) {
          case "success":
            final String? archivedUrl = _readClosestUrl(data);
            if (archivedUrl == null || archivedUrl.isEmpty) {
              loggerGlobal.severe(_source,
                  'Archiving reported success for $targetUrl but no snapshot URL was present: ${response.body}');
              throw Exception(
                  'Archiving succeeded but no snapshot URL was returned for $targetUrl');
            }
            loggerGlobal.info(_source,
                'Archiving succeeded for $targetUrl. Archived URL: $archivedUrl');
            return archivedUrl;
          case "error":
            loggerGlobal.warning(_source,
                'Archiving failed for $targetUrl: \n message: ${data['message']} \n ${data['status_ext']}');
            throw Exception('Archiving failed: ${data['message']}');
          case "pending":
            final String? jobId = _readJobId(data);
            if (jobId == null) {
              loggerGlobal.severe(_source,
                  'Archiving pending for $targetUrl but no job_id was present: ${response.body}');
              throw Exception(
                  'Archiving pending but no job_id was returned for $targetUrl');
            }
            loggerGlobal.info(_source,
                'Archiving in progress for $targetUrl. Job ID: $jobId');
            return jobId;
          default:
            final String? jobId = _readJobId(data);
            if (jobId != null) {
              loggerGlobal.info(_source,
                  'Archiving in progress for $targetUrl. Job ID: $jobId');
              return jobId;
            }
            loggerGlobal.severe(
                _source, 'Unexpected status for $targetUrl: ${data['status']}');
            throw Exception('Unexpected status: ${data['status']}');
        }
      } else {
        throw Exception("Failed to start archiving: ${response.body}");
      }
    } catch (e) {
      loggerGlobal.severe(_source, "Error in archiveUrl", e);
      rethrow;
    }
  }

  /// Safely extracts `archived_snapshots.closest.url` from a decoded response.
  ///
  /// Returns the URL string when every level is present and correctly typed,
  /// or null when any level is missing or of the wrong type. Never throws.
  static String? _readClosestUrl(Map<String, dynamic> data) {
    final snapshots = data["archived_snapshots"];
    if (snapshots is! Map) return null;
    final closest = snapshots["closest"];
    if (closest is! Map) return null;
    final url = closest["url"];
    return url is String ? url : null;
  }

  /// Safely extracts a non-empty `job_id` string from a decoded response.
  ///
  /// Returns the job id when present, a String, and non-empty; otherwise null.
  /// Never throws — guards the historical `data['job_id'].isNotEmpty` crash on
  /// a null or non-string value.
  static String? _readJobId(Map<String, dynamic> data) {
    final jobId = data["job_id"];
    return (jobId is String && jobId.isNotEmpty) ? jobId : null;
  }

  /// Checks the status of an archiving job.
  ///
  /// [jobId] is the ID of the job to check.
  ///
  /// Returns a map containing the status information.
  Future<Map<String, dynamic>> checkStatus(String jobId) async {
    try {
      final response = await _get(Uri.parse("$baseUrl/save/status/$jobId"));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to check status: ${response.body}");
      }
    } catch (e) {
      loggerGlobal.severe(_source, "Error in checkStatus", e);
      rethrow;
    }
  }

  /// Waits for an archiving job to complete.
  ///
  /// [jobId] is the ID of the job to wait for.
  /// [pollInterval] is the number of seconds to wait between status checks (default is 5).
  /// [maxDuration] is the maximum time to wait before throwing a [TimeoutException].
  ///
  /// Returns the URL of the archived snapshot upon success.
  /// Throws an [Exception] if the archiving fails.
  /// Throws a [TimeoutException] if the job does not complete within [maxDuration].
  Future<String> waitForCompletion(
    String jobId, {
    int pollInterval = 5,
    Duration maxDuration = const Duration(minutes: 5),
  }) async {
    final deadline = DateTime.now().add(maxDuration);
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(Duration(seconds: pollInterval));
      try {
        final status = await checkStatus(jobId);

        if (status["status"] == "success") {
          return 'https://web.archive.org/web/${status['timestamp']}/${status['original_url']}';
        } else if (status["status"] == "error") {
          throw Exception('Archiving failed: ${status['message']}');
        }

        loggerGlobal.info(_source, "Wait, still capturing...");
      } catch (e) {
        loggerGlobal.severe(_source, "Error in waitForCompletion", e);
        rethrow;
      }
    }
    throw TimeoutException(
      'Archiving job $jobId did not complete within $maxDuration',
      maxDuration,
    );
  }

  /// Archives a URL and waits for the process to complete.
  ///
  /// This is a convenience method that combines [archiveUrl] and [waitForCompletion].
  ///
  /// [targetUrl] is the URL to archive.
  /// [options] are optional parameters for the archiving request.
  ///
  /// Returns the URL of the archived snapshot.
  Future<String> archiveAndWait(String targetUrl,
      {ArchiveOrgOptions? options}) async {
    try {
      final jobId = await archiveUrl(targetUrl, options: options);
      loggerGlobal.info(_source, "Capture started, job id: $jobId");
      return await waitForCompletion(jobId);
    } catch (e) {
      loggerGlobal.severe(_source, "Error in archiveAndWait", e);
      rethrow;
    }
  }
}
