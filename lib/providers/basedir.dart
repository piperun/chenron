import "dart:io";

import "package:flutter/foundation.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:chenron/utils/directory/directory.dart";

// Necessary for code-generation to work
part "basedir.g.dart";

/// This will create a provider named `activityProvider`
/// which will cache the result of this function.
@riverpod
Future<ChenronDirectories> chenronBaseDirs(ChenronBaseDirsRef ref) async {
  File databaseName = File("chenron");
  const bool debugMode = kDebugMode;
  // TODO: Implement database config fetching the database path
  final Directory baseDir =
      await getDefaultApplicationDirectory(debugMode: debugMode);

  // Instantiate ChenronDirectories
  final chenronDirectories = ChenronDirectories(
    databaseName: databaseName,
    baseDir: baseDir,
  );

  // Create directories
  await chenronDirectories.createDirectories();

  // Return the initialized instance
  return chenronDirectories;
}
