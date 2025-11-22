import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:web_archiver/src/archive_org/archive_org_options.dart';

/// Factory definition for creating an [ArchiveOrgClient].
typedef ArchiveOrgClientFactory = ArchiveOrgClient Function(
    String apiKey, String apiSecret);

/// Default factory instance for creating [ArchiveOrgClient]s.
ArchiveOrgClientFactory archiveOrgClientFactory =
    (apiKey, apiSecret) => ArchiveOrgClient(apiKey, apiSecret);

final _logger = Logger('ArchiveOrgClient');

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

  /// Creates a new [ArchiveOrgClient] with the given [apiKey] and [apiSecret].
  ArchiveOrgClient(this.apiKey, this.apiSecret);

  /// Checks if the provided credentials are valid by making a request to the status endpoint.
  ///
  /// Returns `true` if the status code is 200, indicating successful authentication.
  Future<bool> checkAuthentication() async {
    final response = await http.get(Uri.parse("$baseUrl/save/status/"));
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

      final response = await http.post(
        Uri.parse("$baseUrl/save"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
          "Authorization": "LOW $apiKey:$apiSecret",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        switch (data["status"]) {
          case "success":
            _logger.info(
                'Archiving succeeded for $targetUrl. Archived URL: ${data['archived_snapshots']['closest']['url']}');
            return data["archived_snapshots"]["closest"]["url"];
          case "error":
            _logger.warning(
                'Archiving failed for $targetUrl: \n message: ${data['message']} \n ${data['status_ext']}');
            throw Exception('Archiving failed: ${data['message']}');
          case "pending":
            _logger.info(
                'Archiving in progress for $targetUrl. Job ID: ${data['job_id']}');
            return data["job_id"];
          default:
            if (data["job_id"].isNotEmpty) {
              _logger.info(
                  'Archiving in progress for $targetUrl. Job ID: ${data['job_id']}');
              return data["job_id"];
            }
            _logger
                .severe('Unexpected status for $targetUrl: ${data['status']}');
            throw Exception('Unexpected status: ${data['status']}');
        }
      } else {
        throw Exception("Failed to start archiving: ${response.body}");
      }
    } catch (e) {
      _logger.severe("Error in archiveUrl", e);
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
      final response = await http.get(Uri.parse("$baseUrl/save/status/$jobId"));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to check status: ${response.body}");
      }
    } catch (e) {
      _logger.severe("Error in checkStatus", e);
      rethrow;
    }
  }

  /// Waits for an archiving job to complete.
  ///
  /// [jobId] is the ID of the job to wait for.
  /// [pollInterval] is the number of seconds to wait between status checks (default is 5).
  ///
  /// Returns the URL of the archived snapshot upon success.
  /// Throws an [Exception] if the archiving fails.
  Future<String> waitForCompletion(String jobId, {int pollInterval = 5}) async {
    while (true) {
      await Future.delayed(Duration(seconds: pollInterval));
      try {
        final status = await checkStatus(jobId);

        if (status["status"] == "success") {
          return 'https://web.archive.org/web/${status['timestamp']}/${status['original_url']}';
        } else if (status["status"] == "error") {
          throw Exception('Archiving failed: ${status['message']}');
        }

        _logger.info("Wait, still capturing...");
      } catch (e) {
        _logger.severe("Error in waitForCompletion", e);
        rethrow;
      }
    }
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
      _logger.info("Capture started, job id: $jobId");
      return await waitForCompletion(jobId);
    } catch (e) {
      _logger.severe("Error in archiveAndWait", e);
      rethrow;
    }
  }
}
