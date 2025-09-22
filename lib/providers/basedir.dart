import "dart:io";

import "package:chenron/utils/logger.dart"; // Import logger
import "package:flutter/foundation.dart";
import "package:chenron/utils/directory/directory.dart";
import "package:signals/signals.dart";

final Signal<Future<ChenronDirectories?>> chenronDirsSignal =
    signal(initializeChenronDirs());

Future<ChenronDirectories?> initializeChenronDirs() async {
  try {
    File databaseName = File("app.sqlite");
    const bool debugMode = kDebugMode;

    // Fetch the default application directory
    final Directory baseDir =
        await getDefaultApplicationDirectory(debugMode: debugMode);

    // Instantiate ChenronDirectories
    final chenronDirectories = ChenronDirectories(
      databaseName: databaseName,
      baseDir: baseDir,
    );

    // Create directories (this ensures logDir exists)
    await chenronDirectories.createDirectories();

    // Note: Logger setup is now handled in MainSetup._setupLogging()
    // to avoid initialization order issues

    return chenronDirectories;
  } catch (e, stackTrace) {
    debugPrint("CRITICAL Error in initializeChenronDirs: $e\n$stackTrace");
    // Don't use loggerGlobal here as it may not be initialized yet
    return null;
  }
}
