/// Chenron Database Package — canonical public entry point.
///
/// Exposes the widely-used surface: the generated Drift database
/// classes (with their row types + companions), the lifecycle and
/// file-service handlers, and the model data classes. Feature
/// operations (createLink, getFolder, etc.) are NOT re-exported here —
/// callers import the specific `src/features/<entity>/<op>.dart` file
/// they need so that jump-to-definition lands on real code instead of
/// a re-export hop.
library;

// Generated Drift database classes + public config enums.
export "package:database/app_database.dart";
export "package:database/config_database.dart";
export "package:database/find_extensions.dart";

// Models (data classes)
export "models.dart";

// Core handlers
export "src/core/handlers/database_lifecycle.dart";
export "src/core/handlers/app_file_service.dart";
export "src/core/handlers/relation_handler.dart";
export "src/core/handlers/read_handler.dart";
export "src/core/handlers/database_backup_scheduler.dart";
