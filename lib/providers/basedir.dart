import "dart:io";

import "package:flutter/foundation.dart";
import "package:chenron/utils/directory/directory.dart";
import "package:signals/signals.dart";

final FutureSignal<ChenronDirectories> chenronDirsSignal =
    futureSignal(initializeChenronDirs);

Future<ChenronDirectories> initializeChenronDirs() async {
  File databaseName = File("chenron");
  const bool debugMode = kDebugMode;

  // Fetch the default application directory
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
