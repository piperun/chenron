import "dart:io";

import "package:flutter/foundation.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";


class ChenronDirectories {
  final File databaseName;
  final Directory baseDir;

  late final Directory chenronDir;
  // Canonical database directory
  late final Directory databaseDir;
  // Backwards-compatible aliases
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
    // Use chenron/debug in debug builds, otherwise chenron/
    chenronDir = kDebugMode
        ? Directory(p.join(baseDir.path, "chenron", "debug"))
        : Directory(p.join(baseDir.path, "chenron"));

    // New base structure: database/, log/, backup/
    databaseDir = Directory(p.join(chenronDir.path, "database"));

    // Backwards-compatible aliases point to the canonical database folder
    dbDir = databaseDir;
    configDir = databaseDir;

    importDir = Directory(p.join(chenronDir.path, "import"));

    // Backups split into app and config
    backupAppDbDir = Directory(p.join(chenronDir.path, "backup", "app"));
    backupConfigDbDir = Directory(p.join(chenronDir.path, "backup", "config"));
    logDir = Directory(p.join(chenronDir.path, "log"));
  }

  Future<void> createDirectories() async {
    await Future.wait([
      databaseDir.create(recursive: true),
      importDir.create(recursive: true),
      backupAppDbDir.create(recursive: true),
      backupConfigDbDir.create(recursive: true),
      logDir.create(recursive: true),
    ]);
  }
}

Future<Directory> getDefaultApplicationDirectory(
    {bool debugMode = false}) async {
  final defaultDir = debugMode
      ? await getApplicationDocumentsDirectory()
      : await getApplicationSupportDirectory();

  if (await isDirWritable(defaultDir)) {
    return defaultDir;
  }

  throw Exception(
      "No writable directory found. Debug mode: $debugMode, $defaultDir");
}


Future<bool> isDirWritable(Directory directory) async {
  try {
    final tempFile = File(p.join(
        directory.path, "temp_${DateTime.now().millisecondsSinceEpoch}"));
    await tempFile.create();
    await tempFile.writeAsBytes([DateTime.now().millisecondsSinceEpoch]);
    await tempFile.delete();
    return true;
  } on FileSystemException catch (e) {
    // Use debugPrint instead of logger as this may be called before logger initialization
    debugPrint("ApplicationDirectory Write Error: ${e.message}");
    return false;
  }
}
