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

  /// Creates a new [ArchiveOrgClient] with the given [apiKey] and [apiSecret].
  ArchiveOrgClient(this.apiKey, this.apiSecret);

  /// Checks if the provided credentials are valid by making a request to the status endpoint.
  ///
  /// Returns `true` if the status code is 200, indicating successful authentication.
  Future<bool> checkAuthentication() async {
    final response =
        await http.get(Uri.parse("$baseUrl/save/status/")).timeout(httpTimeout);
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

      final response = await http
          .post(
            Uri.parse("$baseUrl/save"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
              "Authorization": "LOW $apiKey:$apiSecret",
            },
            body: body,
          )
          .timeout(httpTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        switch (data["status"]) {
          case "success":
            loggerGlobal.info(_source,
                'Archiving succeeded for $targetUrl. Archived URL: ${data['archived_snapshots']['closest']['url']}');
            return data["archived_snapshots"]["closest"]["url"];
          case "error":
            loggerGlobal.warning(_source,
                'Archiving failed for $targetUrl: \n message: ${data['message']} \n ${data['status_ext']}');
            throw Exception('Archiving failed: ${data['message']}');
          case "pending":
            loggerGlobal.info(_source,
                'Archiving in progress for $targetUrl. Job ID: ${data['job_id']}');
            return data["job_id"];
          default:
            if (data["job_id"].isNotEmpty) {
              loggerGlobal.info(_source,
                  'Archiving in progress for $targetUrl. Job ID: ${data['job_id']}');
              return data["job_id"];
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

  /// Checks the status of an archiving job.
  ///
  /// [jobId] is the ID of the job to check.
  ///
  /// Returns a map containing the status information.
  Future<Map<String, dynamic>> checkStatus(String jobId) async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/save/status/$jobId"))
          .timeout(httpTimeout);

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
