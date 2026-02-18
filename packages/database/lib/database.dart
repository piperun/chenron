/// Chenron Database Package
///
/// Provides database operations for documents, folders, links, tags, and user configuration.
library;

// Core database classes
export "main.dart" show AppDatabase, ConfigDatabase, WebMetadataEntry;

// Models (data classes)
export "models.dart";

// Feature APIs (CRUD operations)
export "features.dart";

// Core handlers
export "src/core/handlers/database_file_handler.dart";
export "src/core/handlers/config_file_handler.dart";
export "src/core/handlers/relation_handler.dart";
export "src/core/handlers/read_handler.dart";
export "src/core/handlers/database_backup_scheduler.dart";

// Export IncludeOptions from shared patterns for backward compatibility
export "package:core/patterns/include_options.dart";
