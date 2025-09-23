import "dart:io";

import "package:flutter/foundation.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

/// A typed, unbiased directory schema that maps enum keys to relative path segments.
///
/// This class is generic and does not prescribe any particular directory layout.
/// Consumers define their own enum and provide the mapping via [paths].
class DirSchema<K extends Enum> {
  /// Creates a directory schema from a mapping of enum keys to relative path segments.
  const DirSchema({required this.paths});

  /// The mapping from enum keys to relative path segments under the app root.
  final Map<K, List<String>> paths;
}

/// Resolves and manages application directories defined by a [DirSchema].
///
/// - [K] is an enum type declared by the consumer to represent directory keys.
/// - No defaults are assumed. Call [create] with explicit keys, or [createAll].
class BaseDirectories<K extends Enum> {
  /// Creates a resolver for application directories defined by [schema].
  BaseDirectories({
    required this.appName,
    required this.platformBaseDir,
    required this.schema,
    this.debugMode = false,
  }) {
    appRoot = Directory(
      debugMode
          ? p.join(platformBaseDir.path, appName, 'debug')
          : p.join(platformBaseDir.path, appName),
    );

    _dirs = <K, Directory>{
      for (final MapEntry<K, List<String>> entry in schema.paths.entries)
        entry.key: Directory(
            p.joinAll(<String>[appRoot.path, ...entry.value])),
    };
  }

  /// The application name used for the root folder under the platform directory.
  final String appName;

  /// The platform-provided base directory (e.g., path_provider's documents/support dir).
  final Directory platformBaseDir;

  /// The schema describing which directories exist, relative to [appRoot].
  final DirSchema<K> schema;

  /// Whether to include a "debug" segment under the app root.
  final bool debugMode;

  /// The resolved application root directory: `<platform>/<appName>[/debug]`
  late final Directory appRoot;

  /// Resolved directories for each enum key in [schema].
  late final Map<K, Directory> _dirs;

/// Creates directories for the specified [include] keys.
/// If [include] is null or empty, nothing is created.
Future<void> create({Set<K>? include}) async {
  final Set<K> keys = include ?? <K>{};
  if (keys.isEmpty) return;
  await Future.wait<Directory>(
      keys.map((K k) => _dirs[k]!.create(recursive: true)));
}

  /// Convenience to create all directories declared in the schema.
  Future<void> createAll() async {
    await create(include: schema.paths.keys.toSet());
  }

  /// Returns the resolved [Directory] for the given [key].
  Directory operator [](K key) => _dirs[key]!;

  /// Returns the resolved [Directory] for the given [key].
  Directory dir(K key) => _dirs[key]!;

  /// Returns the resolved [Directory] for the given [key], or null if missing.
  Directory? tryDir(K key) => _dirs[key];
}

/// Selects a reasonable default application directory for the platform and build mode.
///
/// - Debug: getApplicationDocumentsDirectory()
/// - Release: getApplicationSupportDirectory()
///
/// Throws if the selected directory is not writable.
Future<Directory> getDefaultApplicationDirectory({bool debugMode = false}) async {
  final Directory defaultDir = debugMode
      ? await getApplicationDocumentsDirectory()
      : await getApplicationSupportDirectory();

  if (await isDirWritable(defaultDir)) {
    return defaultDir;
  }

  throw Exception(
      "No writable directory found. Debug mode: $debugMode, $defaultDir");
}

/// Checks whether [directory] is writable by attempting to create, write, and delete a temp file.
Future<bool> isDirWritable(Directory directory) async {
  try {
    final File tempFile = File(p.join(
        directory.path, "temp_${DateTime.now().millisecondsSinceEpoch}"));
    await tempFile.create();
    await tempFile
        .writeAsBytes(<int>[DateTime.now().millisecondsSinceEpoch]);
    await tempFile.delete();
    return true;
  } on FileSystemException catch (e) {
    // Use debugPrint instead of logger as this may be called before logger initialization
    debugPrint("ApplicationDirectory Write Error: ${e.message}");
    return false;
  }
}
