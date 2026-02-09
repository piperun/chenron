import "package:database/main.dart";
import "package:drift/drift.dart";

/// Shared tag-collection logic for result builders.
///
/// Deduplicates tags by ID as rows are processed.
mixin TagProcessingMixin {
  final List<Tag> tags = [];

  void processTags(
      TypedResult row, Set<Enum> includeOptions, $TagsTable tagsTable) {
    if (includeOptions.contains(AppDataInclude.tags)) {
      final tag = row.readTableOrNull(tagsTable);
      if (tag != null && !tags.any((t) => t.id == tag.id)) {
        tags.add(tag);
      }
    }
  }
}
