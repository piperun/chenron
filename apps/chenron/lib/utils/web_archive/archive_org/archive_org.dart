import "dart:async";
import "dart:convert";
import "package:chenron/utils/logger.dart";
import "package:http/http.dart" as http;
import "package:chenron/utils/web_archive/archive_org/archive_org_options.dart";

class ArchiveOrgClient {
  final String apiKey;
  final String apiSecret;
  final String baseUrl = "https://web.archive.org";

  ArchiveOrgClient(this.apiKey, this.apiSecret);

  Future<bool> checkAuthentication() async {
    final response = await http.get(Uri.parse("$baseUrl/save/status/"));
    return response.statusCode == 200;
  }

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
            loggerGlobal.info("ArchiveOrgClient",
                'Archiving succeeded for $targetUrl. Archived URL: ${data['archived_snapshots']['closest']['url']}');
            return data["archived_snapshots"]["closest"]["url"];
          case "error":
            loggerGlobal.warning("ArchiveOrgClient",
                'Archiving failed for $targetUrl: \n message: ${data['message']} \n ${data['status_ext']}');
            throw Exception('Archiving failed: ${data['message']}');
          case "pending":
            loggerGlobal.info("ArchiveOrgClient",
                'Archiving in progress for $targetUrl. Job ID: ${data['job_id']}');
            return data["job_id"];
          default:
            if (data["job_id"].isNotEmpty) {
              loggerGlobal.info("ArchiveOrgClient",
                  'Archiving in progress for $targetUrl. Job ID: ${data['job_id']}');
              return data["job_id"];
            }
            loggerGlobal.severe("ArchiveOrgClient",
                'Unexpected status for $targetUrl: ${data['status']}');
            throw Exception('Unexpected status: ${data['status']}');
        }
      } else {
        throw Exception("Failed to start archiving: ${response.body}");
      }
    } catch (e) {
      loggerGlobal.severe("ArchiveOrgClient", "Error in archiveUrl: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkStatus(String jobId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/save/status/$jobId"));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to check status: ${response.body}");
      }
    } catch (e) {
      loggerGlobal.severe("ArchiveOrgClient", "Error in checkStatus: $e");
      rethrow;
    }
  }

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

        loggerGlobal.info("ArchiveOrgClient", "Wait, still capturing...");
      } catch (e) {
        loggerGlobal.severe(
            "ArchiveOrgClient", "Error in waitForCompletion: $e");
        rethrow;
      }
    }
  }

  Future<String> archiveAndWait(String targetUrl) async {
    try {
      final jobId = await archiveUrl(targetUrl);
      loggerGlobal.info("ArchiveOrgClient", "Capture started, job id: $jobId");
      return await waitForCompletion(jobId);
    } catch (e) {
      loggerGlobal.severe("ArchiveOrgClient", "Error in archiveAndWait: $e");
      rethrow;
    }
  }
}
