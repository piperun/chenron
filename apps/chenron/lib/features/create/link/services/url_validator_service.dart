import "dart:async";
import "dart:io";
import "package:http/http.dart" as http;

class UrlValidationResult {
  final bool isValid;
  final bool isReachable;
  final String? message;
  final int? statusCode;

  UrlValidationResult({
    required this.isValid,
    required this.isReachable,
    this.message,
    this.statusCode,
  });

  bool get isSuccess => isValid && isReachable;
}

class UrlValidatorService {
  static const Duration _timeout = Duration(seconds: 3);

  /// Validates URL format
  static bool isValidUrlFormat(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Performs async validation: checks DNS resolution and HTTP status
  static Future<UrlValidationResult> validateUrl(String url) async {
    if (!isValidUrlFormat(url)) {
      return UrlValidationResult(
        isValid: false,
        isReachable: false,
        message: "Invalid URL format",
      );
    }

    try {
      final uri = Uri.parse(url);

      // Check DNS resolution
      final addresses = await InternetAddress.lookup(
        uri.host,
        type: InternetAddressType.any,
      ).timeout(_timeout);

      if (addresses.isEmpty) {
        return UrlValidationResult(
          isValid: true,
          isReachable: false,
          message: "Domain not found",
        );
      }

      // Check HTTP status
      try {
        final response = await http
            .head(uri)
            .timeout(_timeout)
            .catchError((_) async => await http.get(uri).timeout(_timeout));

        final isReachable = response.statusCode >= 200 && response.statusCode < 400;

        return UrlValidationResult(
          isValid: true,
          isReachable: isReachable,
          statusCode: response.statusCode,
          message: isReachable
              ? "URL is reachable"
              : "URL returned status ${response.statusCode}",
        );
      } on TimeoutException {
        return UrlValidationResult(
          isValid: true,
          isReachable: false,
          message: "Request timed out",
        );
      } on http.ClientException {
        return UrlValidationResult(
          isValid: true,
          isReachable: false,
          message: "Unable to connect",
        );
      }
    } on SocketException {
      return UrlValidationResult(
        isValid: true,
        isReachable: false,
        message: "Domain not found",
      );
    } on TimeoutException {
      return UrlValidationResult(
        isValid: true,
        isReachable: false,
        message: "DNS lookup timed out",
      );
    } catch (e) {
      return UrlValidationResult(
        isValid: true,
        isReachable: false,
        message: "Validation error: ${e.toString()}",
      );
    }
  }

  /// Batch validate multiple URLs
  static Future<Map<String, UrlValidationResult>> validateUrls(
    List<String> urls,
  ) async {
    final results = <String, UrlValidationResult>{};

    await Future.wait(
      urls.map((url) async {
        results[url] = await validateUrl(url);
      }),
    );

    return results;
  }
}
