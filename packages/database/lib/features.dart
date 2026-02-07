/// Database feature operations (CRUD for all entities).
library;

// Document operations
export "src/features/document/create.dart";
export "src/features/document/read.dart";
export "src/features/document/update.dart";
export "src/features/document/remove.dart";

// Folder operations
export "src/features/folder/create.dart";
export "src/features/folder/read.dart";
export "src/features/folder/update.dart";
export "src/features/folder/remove.dart";
export "src/features/folder/insert.dart";

// Link operations
export "src/features/link/create.dart";
export "src/features/link/read.dart";
export "src/features/link/update.dart";
export "src/features/link/remove.dart";
export "src/features/link/archive.dart";

// Tag operations
export "src/features/tag/create.dart";
export "src/features/tag/read.dart";

// User Config operations
export "src/features/user_config/create.dart";
export "src/features/user_config/read.dart";
export "src/features/user_config/update.dart";
export "src/features/user_config/remove.dart";

// User Theme operations
export "src/features/user_theme/create.dart";
export "src/features/user_theme/remove.dart";
//export 'src/features/user_theme/read.dart';

// Statistics
export "src/features/statistics/track.dart";
export "src/features/statistics/activity.dart";
export "src/features/statistics/recent_access.dart";
export "src/features/statistics/derived.dart";

// Core utilities that users might need
export "src/core/id.dart" show GlobalIdGenerator;
export "src/core/convert.dart";
export "src/core/payload.dart";
