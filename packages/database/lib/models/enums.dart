/// Database-layer enums.
///
/// Kept in a no-dependencies file so [schema] definitions can import
/// them without pulling in the generated Drift code (which would
/// create a cycle: schema -> models -> generated drift -> schema).
library;

enum FolderItemType { link, document, folder }

enum MetadataTypeEnum { tag }

// ConfigDatabase enums. Same rationale — these used to back lookup
// tables (themeTypes, timeDisplayFormats, itemClickActions, seedTypes)
// that intEnum<T>() replaces.

enum ThemeType { custom, system }

enum TimeDisplayFormat { relative, absolute }

enum ItemClickAction { openItem, showDetails }

enum SeedType { none, primary, primaryAndSecondary, all }
