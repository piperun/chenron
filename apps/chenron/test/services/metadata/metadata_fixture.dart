import "dart:io";

String readMetadataFixture(
  String name, {
  Directory? baseDirectory,
}) {
  if (name.isEmpty || name.contains("/") || name.contains(r"\")) {
    throw ArgumentError.value(name, "name", "must be a plain filename");
  }

  final base = baseDirectory ?? Directory.current;
  final relativePaths = <String>[
    "test/services/metadata/fixtures/$name",
    "apps/chenron/test/services/metadata/fixtures/$name",
  ];
  final attempted = <String>[];

  for (final relativePath in relativePaths) {
    final file = File.fromUri(base.uri.resolve(relativePath));
    attempted.add(file.path);
    if (file.existsSync() &&
        FileSystemEntity.typeSync(
              file.path,
              followLinks: false,
            ) ==
            FileSystemEntityType.file) {
      return file.readAsStringSync();
    }
  }

  throw FileSystemException(
    "Metadata fixture not found. Tried: ${attempted.join(", ")}",
    name,
  );
}
