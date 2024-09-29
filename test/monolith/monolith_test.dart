import 'package:chenron/utils/web_archive/monolith/monolith_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MonolithRunner', () {
    late MonolithRunner runner;

    setUp(() {
      runner = MonolithRunner();
    });

    test('runs with default options', () async {
      final result = await runner.run('https://sqlite.org/cli.html');
      expect(result, allOf([returnsNormally, isNotEmpty]));
    });
  });
}
