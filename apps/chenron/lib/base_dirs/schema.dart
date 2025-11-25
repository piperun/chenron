import "dart:io";

import "package:basedir/directory.dart";

/// Enum keys representing Chenron app directories.
enum ChenronDir { database, backupApp, backupConfig, log }

/// Chenron directory schema mapping keys to relative path segments.
const chenronSchema = DirSchema<ChenronDir>(paths: {
  ChenronDir.database: ["database"],
  ChenronDir.backupApp: ["backup", "app"],
  ChenronDir.backupConfig: ["backup", "config"],
  ChenronDir.log: ["log"],
});

/// Convenience getters for Chenron directories.
extension ChenronDirs on BaseDirectories<ChenronDir> {
  Directory get databaseDir => this[ChenronDir.database];
  Directory get backupAppDir => this[ChenronDir.backupApp];
  Directory get backupConfigDir => this[ChenronDir.backupConfig];
  Directory get logDir => this[ChenronDir.log];
}

