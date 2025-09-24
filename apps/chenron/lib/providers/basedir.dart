import "dart:io";

import "package:flutter/foundation.dart";
import "package:basedir/directory.dart";
import "package:signals/signals.dart";

import "package:chenron/base_dirs/schema.dart";

final Signal<Future<BaseDirectories<ChenronDir>?>> baseDirsSignal =
    signal(initializeBaseDirs());

Future<BaseDirectories<ChenronDir>?> initializeBaseDirs() async {
  try {
    const bool debugMode = kDebugMode;

    // Fetch the default application directory
    final Directory platformBase =
        await getDefaultApplicationDirectory(debugMode: debugMode);

    // Instantiate BaseDirectories with Chenron schema
    final baseDirs = BaseDirectories<ChenronDir>(
      appName: "chenron",
      platformBaseDir: platformBase,
      schema: chenronSchema,
      debugMode: debugMode,
    );

    // Explicitly create the Chenron directories we need
    await baseDirs.create(include: {
      ChenronDir.database,
      ChenronDir.backupApp,
      ChenronDir.backupConfig,
      ChenronDir.log,
    });

    return baseDirs;
  } catch (e, stackTrace) {
    debugPrint("CRITICAL Error in initializeBaseDirs: $e\n$stackTrace");
    return null;
  }
}
