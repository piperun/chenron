import "dart:io";

import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "package:chenron/utils/logger.dart";

class ChenronDirectories {
  final File databaseName;
  final Directory baseDir;

  late final Directory chenronDir;
  late final Directory dbDir;
  late final Directory importDir;
  late final Directory configDir;
  late final Directory backupAppDbDir;
  late final Directory backupConfigDbDir;
  late final Directory logDir;

  // Private constructor
  ChenronDirectories._internal({
    required this.databaseName,
    required this.baseDir,
  }) {
    _initializeDirectories();
  }

  // Cache to store instances
  static final Map<String, ChenronDirectories> _cache = {};

  // Factory constructor
  factory ChenronDirectories({
    required File databaseName,
    required Directory baseDir,
  }) {
    final key = "${databaseName}_${baseDir.path}";
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    } else {
      final instance = ChenronDirectories._internal(
        databaseName: databaseName,
        baseDir: baseDir,
      );
      _cache[key] = instance;
      return instance;
    }
  }

  void _initializeDirectories() {
    chenronDir = Directory(p.join(baseDir.path, "chenron"));
    dbDir = Directory(p.join(chenronDir.path, "db"));
    importDir = Directory(p.join(chenronDir.path, "import"));
    configDir = Directory(p.join(chenronDir.path, "config"));
    backupAppDbDir = Directory(p.join(chenronDir.path, "backup",
        p.basenameWithoutExtension(databaseName.path)));
    backupConfigDbDir = Directory(p.join(chenronDir.path, "backup", "config"));
    logDir = Directory(p.join(chenronDir.path, "log"));
  }

  Future<void> createDirectories() async {
    await Future.wait([
      dbDir.create(recursive: true),
      importDir.create(recursive: true),
      configDir.create(recursive: true),
      backupAppDbDir.create(recursive: true),
      backupConfigDbDir.create(recursive: true),
      logDir.create(recursive: true),
    ]);
  }
}

Future<Directory> getDefaultApplicationDirectory(
    {bool debugMode = false}) async {
  final appDir = await getApplicationSupportDirectory();
  if (await isDirWritable(appDir) && !debugMode) {
    return appDir;
  }

  final docDir = await getApplicationDocumentsDirectory();
  if (await isDirWritable(docDir) && debugMode) {
    return docDir;
  }

  throw Exception("No writable directory found");
}

/// Checks if the provided [directory] is writable.
///
/// This function attempts to create, write to, and delete a temporary file
/// within the specified [directory] to determine if it has write permissions.
///
/// - If all operations succeed, the function returns `true`, indicating that
///   the directory is writable.
/// - If a `FileSystemException` occurs during any of the file operations,
///   it logs the error and returns `false`, indicating that the directory
///   is not writable.
///
/// **Parameters:**
/// - `directory` (`Directory`): The directory to check for write permissions.
///
/// **Returns:**
/// - `Future<bool>`: A `Future` that completes with `true` if the directory
///   is writable, or `false` otherwise.
///
/// **Example:**
/// ```dart
/// final dir = Directory('/path/to/directory');
/// final isWritable = await isDirWritable(dir);
/// if (isWritable) {
///   print('The directory is writable.');
/// } else {
///   print('The directory is not writable.');
/// }
/// ```
///
/// **Throws:**
/// - Does not throw. Exceptions are caught and handled internally.
Future<bool> isDirWritable(Directory directory) async {
  try {
    final tempFile = File(p.join(
        directory.path, "temp_${DateTime.now().millisecondsSinceEpoch}"));
    await tempFile.create();
    await tempFile.writeAsBytes([DateTime.now().millisecondsSinceEpoch]);
    await tempFile.delete();
    return true;
  } on FileSystemException catch (e) {
    loggerGlobal.severe("ApplicationDirectory", "Write Error: ${e.message}");
    return false;
  }
}
