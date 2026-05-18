/// Chenron Database Package — canonical public entry point.
///
/// Provides database operations for documents, folders, links, tags, and
/// user configuration. Prefer this import over `package:database/main.dart`,
/// which now forwards here for backwards compatibility.
library;

// Generated Drift database classes + public config enums (formerly
// reached via main.dart; main.dart is now a deprecated alias).
export "package:database/app_database.dart";
export "package:database/config_database.dart";
export "package:database/find_extensions.dart";

// Models (data classes)
export "models.dart";

// Feature APIs (CRUD operations)
export "features.dart";

// Core handlers
export "src/core/handlers/database_lifecycle.dart";
export "src/core/handlers/app_file_service.dart";
export "src/core/handlers/relation_handler.dart";
export "src/core/handlers/read_handler.dart";
export "src/core/handlers/database_backup_scheduler.dart";

// Shared cross-package types — exposed here so callers don't need to
// reach into `package:core/patterns/...` directly.
export "package:core/patterns/include_options.dart";
