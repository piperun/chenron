import "dart:io";

import "package:flutter_test/flutter_test.dart";

import "metadata_fixture.dart";

void main() {
  late Directory sandbox;

  setUp(() {
    sandbox = Directory.systemTemp.createTempSync("chenron_fixture_test_");
  });

  tearDown(() {
    sandbox.deleteSync(recursive: true);
  });

  test("reads metadata fixtures from the package root", () {
    final file = File.fromUri(
      sandbox.uri.resolve(
        "test/services/metadata/fixtures/sample.html",
      ),
    );
    file.parent.createSync(recursive: true);
    file.writeAsStringSync("package fixture");

    expect(
      readMetadataFixture("sample.html", baseDirectory: sandbox),
      "package fixture",
    );
  });

  test("reads metadata fixtures from the repository root", () {
    final file = File.fromUri(
      sandbox.uri.resolve(
        "apps/chenron/test/services/metadata/fixtures/sample.html",
      ),
    );
    file.parent.createSync(recursive: true);
    file.writeAsStringSync("repository fixture");

    expect(
      readMetadataFixture("sample.html", baseDirectory: sandbox),
      "repository fixture",
    );
  });

  test("rejects fixture names that can escape the fixture directory", () {
    expect(
      () => readMetadataFixture("../secret.html", baseDirectory: sandbox),
      throwsArgumentError,
    );
  });
}
