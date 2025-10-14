import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/create/link/services/url_validator_service.dart";
import "package:chenron/features/create/link/services/bulk_validator_service.dart";

/// Benchmark test to compare different validation strategies for bulk URL validation
///
/// Tests three approaches:
/// 1. Sequential: Validate URLs one by one in sequence
/// 2. Future.wait: Validate all URLs in parallel using Future.wait
/// 3. Isolate/Compute: Validate URLs using Flutter's compute function (separate isolate)
void main() {
  group("Validation Performance Benchmark", () {
    // Test with different dataset sizes
    final testSizes = [10, 50, 100, 200];

    for (final size in testSizes) {
      group("Dataset size: $size URLs", () {
        late List<String> testUrls;

        setUp(() {
          // Generate test URLs
          testUrls = _generateTestUrls(size);
        });

        test("Sequential validation (baseline)", () async {
          final stopwatch = Stopwatch()..start();

          final results = <String, UrlValidationResult>{};
          for (final url in testUrls) {
            results[url] = await UrlValidatorService.validateUrl(url);
          }

          stopwatch.stop();

          debugPrint(
              "Sequential ($size URLs): ${stopwatch.elapsedMilliseconds}ms");
          debugPrint("  - Results: ${results.length} URLs validated");
          debugPrint(
              "  - Average: ${stopwatch.elapsedMilliseconds / size}ms per URL");

          expect(results.length, equals(size));
        }, timeout: const Timeout(Duration(minutes: 5)));

        test("Future.wait parallel validation", () async {
          final stopwatch = Stopwatch()..start();

          final results = await UrlValidatorService.validateUrls(testUrls);

          stopwatch.stop();

          debugPrint(
              "Future.wait ($size URLs): ${stopwatch.elapsedMilliseconds}ms");
          debugPrint("  - Results: ${results.length} URLs validated");
          debugPrint(
              "  - Average: ${stopwatch.elapsedMilliseconds / size}ms per URL");
          debugPrint(
              "  - Speedup vs Sequential: ~${size / (stopwatch.elapsedMilliseconds / 1000)}x");

          expect(results.length, equals(size));
        }, timeout: const Timeout(Duration(minutes: 3)));

        test("Compute/Isolate validation", () async {
          final stopwatch = Stopwatch()..start();

          // Use compute to run validation in a separate isolate
          final results = await compute(_validateUrlsInIsolate, testUrls);

          stopwatch.stop();

          debugPrint(
              "Compute/Isolate ($size URLs): ${stopwatch.elapsedMilliseconds}ms");
          debugPrint("  - Results: ${results.length} URLs validated");
          debugPrint(
              "  - Average: ${stopwatch.elapsedMilliseconds / size}ms per URL");

          expect(results.length, equals(size));
        }, timeout: const Timeout(Duration(minutes: 3)));

        test("Batch validation with chunking", () async {
          final stopwatch = Stopwatch()..start();

          // Process in chunks to balance parallelism and resource usage
          const chunkSize = 20;
          final results = <String, UrlValidationResult>{};

          for (var i = 0; i < testUrls.length; i += chunkSize) {
            final end = (i + chunkSize < testUrls.length)
                ? i + chunkSize
                : testUrls.length;
            final chunk = testUrls.sublist(i, end);

            final chunkResults = await UrlValidatorService.validateUrls(chunk);
            results.addAll(chunkResults);
          }

          stopwatch.stop();

          debugPrint(
              "Chunked validation ($size URLs, chunk size $chunkSize): ${stopwatch.elapsedMilliseconds}ms");
          debugPrint("  - Results: ${results.length} URLs validated");
          debugPrint(
              "  - Average: ${stopwatch.elapsedMilliseconds / size}ms per URL");

          expect(results.length, equals(size));
        }, timeout: const Timeout(Duration(minutes: 3)));
      });
    }

    test("Comparison summary", () async {
      const testSize = 50;
      final urls = _generateTestUrls(testSize);

      // Sequential
      final sw1 = Stopwatch()..start();
      for (final url in urls) {
        await UrlValidatorService.validateUrl(url);
      }
      sw1.stop();
      final sequentialTime = sw1.elapsedMilliseconds;

      // Future.wait
      final sw2 = Stopwatch()..start();
      await UrlValidatorService.validateUrls(urls);
      sw2.stop();
      final parallelTime = sw2.elapsedMilliseconds;

      // Compute
      final sw3 = Stopwatch()..start();
      await compute(_validateUrlsInIsolate, urls);
      sw3.stop();
      final isolateTime = sw3.elapsedMilliseconds;

      debugPrint("\n=== BENCHMARK SUMMARY ($testSize URLs) ===");
      debugPrint("Sequential:     ${sequentialTime}ms (baseline)");
      debugPrint(
          "Future.wait:    ${parallelTime}ms (${(sequentialTime / parallelTime).toStringAsFixed(2)}x faster)");
      debugPrint(
          "Compute/Isolate: ${isolateTime}ms (${(sequentialTime / isolateTime).toStringAsFixed(2)}x faster)");
      debugPrint("\nRecommendation:");

      if (parallelTime < isolateTime) {
        debugPrint("  → Use Future.wait for best performance");
        debugPrint("    (Lower overhead than isolate spawning)");
      } else {
        debugPrint("  → Use Compute/Isolate for best performance");
        debugPrint("    (Better for large datasets, prevents UI blocking)");
      }
    }, timeout: const Timeout(Duration(minutes: 5)));
  });

  group("Format Validation Benchmark", () {
    test("Bulk validator service performance", () async {
      const size = 100;
      final input = _generateTestUrls(size).join("\n");

      final stopwatch = Stopwatch()..start();
      final result = BulkValidatorService.validateBulkInput(input);
      stopwatch.stop();

      debugPrint("\n=== BULK VALIDATOR PERFORMANCE ===");
      debugPrint("Input: $size URLs");
      debugPrint("Time: ${stopwatch.elapsedMilliseconds}ms");
      debugPrint("Valid: ${result.validLines}");
      debugPrint("Invalid: ${result.invalidLines}");
      debugPrint("Average: ${stopwatch.elapsedMilliseconds / size}ms per line");

      expect(result.totalLines, equals(size));
    }, timeout: const Timeout(Duration(seconds: 30)));

    test("Format validation vs full validation", () async {
      const size = 50;
      final urls = _generateTestUrls(size);
      final input = urls.join("\n");

      // Format validation only
      final sw1 = Stopwatch()..start();
      final formatResult = BulkValidatorService.validateBulkInput(input);
      sw1.stop();

      // Full validation (with network checks)
      final sw2 = Stopwatch()..start();
      await UrlValidatorService.validateUrls(urls);
      sw2.stop();

      debugPrint("\n=== FORMAT vs FULL VALIDATION ===");
      debugPrint("Format validation: ${sw1.elapsedMilliseconds}ms");
      debugPrint("Full validation:   ${sw2.elapsedMilliseconds}ms");
      debugPrint(
          "Ratio: ${(sw2.elapsedMilliseconds / sw1.elapsedMilliseconds).toStringAsFixed(2)}x slower");
      debugPrint("\nValid URLs (format): ${formatResult.validLines}");
    });
  });

  group("Memory Usage Test", () {
    test("Large dataset memory efficiency", () async {
      const size = 500;
      final urls = _generateTestUrls(size);

      debugPrint("\n=== MEMORY EFFICIENCY TEST ===");
      debugPrint("Dataset: $size URLs");

      // Sequential (lower memory footprint)
      final sw1 = Stopwatch()..start();
      var count = 0;
      for (final url in urls) {
        await UrlValidatorService.validateUrl(url);
        count++;
        if (count % 100 == 0) {
          debugPrint("  Sequential: $count/$size processed...");
        }
      }
      sw1.stop();
      debugPrint("Sequential completed: ${sw1.elapsedMilliseconds}ms");

      // Parallel (higher memory, but faster)
      final sw2 = Stopwatch()..start();
      await UrlValidatorService.validateUrls(urls);
      sw2.stop();
      debugPrint("Parallel completed: ${sw2.elapsedMilliseconds}ms");

      debugPrint(
          "Time saved with parallel: ${sw1.elapsedMilliseconds - sw2.elapsedMilliseconds}ms");
    });
  });

  group("Error Handling Performance", () {
    test("Mixed valid and invalid URLs", () async {
      final mixedUrls = [
        ...List.generate(25, (i) => "https://example$i.com"), // Valid
        ...List.generate(25, (i) => "not-a-url-$i"), // Invalid
      ];

      final stopwatch = Stopwatch()..start();
      final results = await UrlValidatorService.validateUrls(mixedUrls);
      stopwatch.stop();

      final validCount = results.values.where((r) => r.isValid).length;
      final invalidCount = results.values.where((r) => !r.isValid).length;

      debugPrint("\n=== ERROR HANDLING TEST ===");
      debugPrint("Total URLs: ${mixedUrls.length}");
      debugPrint("Valid: $validCount");
      debugPrint("Invalid: $invalidCount");
      debugPrint("Time: ${stopwatch.elapsedMilliseconds}ms");
      debugPrint(
          "Average: ${stopwatch.elapsedMilliseconds / mixedUrls.length}ms per URL");
    });
  });

  group("Timeout Behavior", () {
    test("Handling unreachable URLs", () async {
      // These should timeout quickly
      final unreachableUrls = [
        "https://definitely-not-a-real-domain-12345.com",
        "https://another-fake-domain-67890.com",
        "https://timeout-test-domain-abcdef.com",
      ];

      final stopwatch = Stopwatch()..start();
      final results = await UrlValidatorService.validateUrls(unreachableUrls);
      stopwatch.stop();

      debugPrint("\n=== TIMEOUT TEST ===");
      debugPrint("URLs: ${unreachableUrls.length}");
      debugPrint("Time: ${stopwatch.elapsedMilliseconds}ms");
      debugPrint(
          "Average: ${stopwatch.elapsedMilliseconds / unreachableUrls.length}ms per URL");

      for (final entry in results.entries) {
        debugPrint("  ${entry.key}: ${entry.value.message}");
      }
    });
  });
}

/// Helper function to generate test URLs
List<String> _generateTestUrls(int count) {
  return List.generate(count, (i) {
    // Mix of different URL patterns
    final patterns = [
      "https://example$i.com",
      "https://test$i.org/path",
      "https://site$i.net/api/v1",
      "https://domain$i.com/page?query=value$i",
    ];
    return patterns[i % patterns.length];
  });
}

/// Isolate entry point for validation
/// This runs in a separate isolate to avoid blocking the main thread
Future<Map<String, UrlValidationResult>> _validateUrlsInIsolate(
    List<String> urls) async {
  final results = <String, UrlValidationResult>{};

  // In an isolate, we need to validate sequentially or use limited parallelism
  // since spawning too many futures in an isolate can be problematic
  await Future.wait(
    urls.map((url) async {
      results[url] = await UrlValidatorService.validateUrl(url);
    }),
  );

  return results;
}

/// Alternative chunked validation for isolates
Future<Map<String, UrlValidationResult>> _validateUrlsInIsolateChunked(
    List<String> urls) async {
  const chunkSize = 10;
  final results = <String, UrlValidationResult>{};

  for (var i = 0; i < urls.length; i += chunkSize) {
    final end = (i + chunkSize < urls.length) ? i + chunkSize : urls.length;
    final chunk = urls.sublist(i, end);

    await Future.wait(
      chunk.map((url) async {
        results[url] = await UrlValidatorService.validateUrl(url);
      }),
    );
  }

  return results;
}
