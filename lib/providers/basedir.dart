import "dart:io";

import "package:chenron/utils/logger.dart"; // Import logger
import "package:flutter/foundation.dart";
import "package:chenron/utils/directory/directory.dart";
import "package:signals/signals.dart";

final Signal<Future<ChenronDirectories?>> chenronDirsSignal =
    signal(initializeChenronDirs());

Future<ChenronDirectories?> initializeChenronDirs() async {
  try {
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

    // Create directories (this ensures logDir exists)
    await chenronDirectories.createDirectories();

    loggerGlobal.setupLogging(
      logDir: chenronDirectories.logDir,
      logToFileInDebug: false,
    );

    loggerGlobal.info(
        "BaseDir", "Chenron directories created and logger setup complete.");

    return chenronDirectories;
  } catch (e, stackTrace) {
    debugPrint("CRITICAL Error in initializeChenronDirs: $e\n$stackTrace");
    loggerGlobal.severe(
        "BaseDirSignal", "Error in initializeChenronDirs: $e\n$stackTrace");
    return null;
  }
}
