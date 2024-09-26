import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class ArchiveOrgClient {
  final String apiKey;
  final String apiSecret;
  final String baseUrl = 'https://web.archive.org';
  final Logger _logger = Logger('ArchiveOrgClient');

  ArchiveOrgClient(this.apiKey, this.apiSecret) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<String> archiveUrl(String targetUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
          'Authorization': 'LOW $apiKey:$apiSecret',
        },
        body: {'url': targetUrl},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['job_id'];
      } else {
        throw Exception('Failed to start archiving: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error in archiveUrl: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkStatus(String jobId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/save/status/$jobId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check status: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error in checkStatus: $e');
      rethrow;
    }
  }

  Future<String> waitForCompletion(String jobId, {int pollInterval = 5}) async {
    while (true) {
      await Future.delayed(Duration(seconds: pollInterval));
      try {
        final status = await checkStatus(jobId);

        if (status['status'] == 'success') {
          return 'https://web.archive.org/web/${status['timestamp']}/${status['original_url']}';
        } else if (status['status'] == 'error') {
          throw Exception('Archiving failed: ${status['message']}');
        }

        _logger.info('Wait, still capturing...');
      } catch (e) {
        _logger.severe('Error in waitForCompletion: $e');
        rethrow;
      }
    }
  }

  Future<String> archiveAndWait(String targetUrl) async {
    try {
      final jobId = await archiveUrl(targetUrl);
      _logger.info('Capture started, job id: $jobId');
      return await waitForCompletion(jobId);
    } catch (e) {
      _logger.severe('Error in archiveAndWait: $e');
      rethrow;
    }
  }
}
