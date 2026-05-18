/// Database-layer enums.
///
/// Kept in a no-dependencies file so [schema] definitions can import
/// them without pulling in the generated Drift code (which would
/// create a cycle: schema -> models -> generated drift -> schema).
library;

enum FolderItemType { link, document, folder }

enum MetadataTypeEnum { tag }
