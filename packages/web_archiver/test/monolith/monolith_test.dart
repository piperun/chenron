import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:web_archiver/web_archiver.dart";

Future<bool> _isMonolithAvailable() async {
  try {
    final res = await Process.run("monolith", ["--version"], runInShell: true);
    return res.exitCode == 0;
  } catch (_) {
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("MonolithRunner", () {
    late MonolithRunner runner;

    setUp(() {
      runner = MonolithRunner();
    });

    test("runs with default options (skips if monolith not installed)",
        () async {
      if (!await _isMonolithAvailable()) {
        // Not installed on this machine; skip gracefully
        // ignore: avoid_print
        print("Skipping monolith test: monolith CLI not installed.");
        return;
      }
      final result = await runner.run("https://sqlite.org/cli.html");
      expect(result, isNotEmpty);
    });
  });
}
