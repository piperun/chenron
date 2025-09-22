import "dart:io";

import "package:chenron/utils/web_archive/monolith/monolith_runner.dart";
import "package:flutter_test/flutter_test.dart";

Future<bool> _isMonolithAvailable() async {
  try {
    final res = await Process.run('monolith', ['--version'], runInShell: true);
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

    test("runs with default options (skips if monolith not installed)", () async {
      if (!await _isMonolithAvailable()) {
        // Not installed on this machine; skip gracefully
        print('Skipping monolith test: monolith CLI not installed.');
        return;
      }
      final result = await runner.run("https://sqlite.org/cli.html");
      expect(result, isNotEmpty);
    });
  });
}
