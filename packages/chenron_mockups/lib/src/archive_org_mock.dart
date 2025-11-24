import "package:web_archiver/web_archiver.dart";

/// A configurable mock for [ArchiveOrgClient] that simulates various archiving scenarios.
///
/// This mock allows tests to simulate success, pending, error, and timeout scenarios
/// without making actual network requests to archive.org.
class MockArchiveOrgClient extends ArchiveOrgClient {
  /// The behavior mode for this mock.
  final MockBehavior behavior;

  /// Number of times [checkStatus] should return pending before success.
  final int pendingCount;

  /// Tracks how many times checkStatus has been called for a job.
  final Map<String, int> _jobCallCounts = {};

  /// Tracks the URL associated with each job ID.
  final Map<String, String> _jobUrls = {};

  /// Simulated delay for operations (milliseconds).
  final int delayMs;

  /// Whether authentication should succeed.
  final bool authSuccess;

  /// Custom error message for failure scenarios.
  final String? errorMessage;

  MockArchiveOrgClient({
    this.behavior = MockBehavior.immediateSuccess,
    this.pendingCount = 2,
    this.delayMs = 10,
    this.authSuccess = true,
    this.errorMessage,
  }) : super("mock_key", "mock_secret");

  @override
  Future<bool> checkAuthentication() async {
    await Future.delayed(Duration(milliseconds: delayMs));
    return authSuccess;
  }

  @override
  Future<String> archiveUrl(String targetUrl,
      {ArchiveOrgOptions? options}) async {
    await Future.delayed(Duration(milliseconds: delayMs));

    switch (behavior) {
      case MockBehavior.immediateSuccess:
        return _generateArchivedUrl(targetUrl);

      case MockBehavior.pending:
        final jobId = _generateJobId(targetUrl);
        _jobUrls[jobId] = targetUrl; // Track URL for this job
        return jobId;

      case MockBehavior.error:
        throw Exception(errorMessage ?? "Mock archiving failed");

      case MockBehavior.timeout:
        await Future.delayed(const Duration(seconds: 60));
        throw TimeoutException("Archive request timed out");

      case MockBehavior.invalidUrl:
        throw ArgumentError("Invalid URL: $targetUrl");

      case MockBehavior.rateLimited:
        throw Exception("Rate limit exceeded. Please try again later.");

      case MockBehavior.optionsRespected:
        // Simulate that options affect the result
        final timestamp =
            options?.forceGet == true ? "20990102000000" : "20990101000000";
        return "https://web.archive.org/web/$timestamp/$targetUrl";
    }
  }

  @override
  Future<String> archiveAndWait(String targetUrl,
      {ArchiveOrgOptions? options}) async {
    final result = await archiveUrl(targetUrl, options: options);

    // If archiveUrl returned a URL (immediate success), return it directly
    if (result.startsWith("http")) {
      return result;
    }

    // Otherwise, it's a job ID - wait for completion
    return waitForCompletion(result);
  }

  @override
  Future<Map<String, dynamic>> checkStatus(String jobId) async {
    await Future.delayed(Duration(milliseconds: delayMs));

    _jobCallCounts[jobId] = (_jobCallCounts[jobId] ?? 0) + 1;
    final callCount = _jobCallCounts[jobId]!;

    if (behavior == MockBehavior.pending) {
      if (callCount < pendingCount) {
        return {
          "status": "pending",
          "job_id": jobId,
          "message": "Archiving in progress...",
        };
      } else {
        final url = _extractUrlFromJobId(jobId);
        return {
          "status": "success",
          "archived_snapshots": {
            "closest": {
              "url": _generateArchivedUrl(url),
              "timestamp": "20990101000000",
            }
          },
        };
      }
    }

    if (behavior == MockBehavior.error) {
      return {
        "status": "error",
        "message": errorMessage ?? "Archiving failed",
        "job_id": jobId,
      };
    }

    // Default success
    final url = _extractUrlFromJobId(jobId);
    return {
      "status": "success",
      "archived_snapshots": {
        "closest": {
          "url": _generateArchivedUrl(url),
          "timestamp": "20990101000000",
        }
      },
    };
  }

  @override
  Future<String> waitForCompletion(String jobId, {int pollInterval = 5}) async {
    final status = await checkStatus(jobId);

    if (status["status"] == "success") {
      return status["archived_snapshots"]["closest"]["url"] as String;
    }

    if (status["status"] == "error") {
      throw Exception(status["message"] ?? "Archiving failed");
    }

    // For pending, recursively check again
    if (behavior == MockBehavior.pending) {
      await Future.delayed(Duration(milliseconds: delayMs));
      return waitForCompletion(jobId, pollInterval: pollInterval);
    }

    throw Exception("Unexpected status: ${status['status']}");
  }

  String _generateArchivedUrl(String targetUrl) {
    return "https://web.archive.org/web/20990101000000/$targetUrl";
  }

  String _generateJobId(String targetUrl) {
    return "spn2-${targetUrl.hashCode.abs()}";
  }

  String _extractUrlFromJobId(String jobId) {
    // Return the tracked URL for this job, or a default
    return _jobUrls[jobId] ?? "https://example.com";
  }

  /// Resets the internal state of the mock.
  void reset() {
    _jobCallCounts.clear();
    _jobUrls.clear();
  }
}

/// Defines different behavior modes for the mock client.
enum MockBehavior {
  /// Archive request immediately returns success with archived URL.
  immediateSuccess,

  /// Archive request returns job ID, checkStatus returns pending N times before success.
  pending,

  /// Archive request throws an error.
  error,

  /// Archive request times out.
  timeout,

  /// Archive request fails due to invalid URL.
  invalidUrl,

  /// Archive request fails due to rate limiting.
  rateLimited,

  /// Archive respects options (e.g., forceGet changes timestamp).
  optionsRespected,
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => "TimeoutException: $message";
}
