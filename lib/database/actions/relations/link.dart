import "package:chenron/database/actions/joins/tag.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/base_query_builder.dart";
import "package:chenron/database/extensions/link/read.dart";
import "package:drift/drift.dart";

class LinkRelationBuilder implements RelationBuilder<LinkResult> {
  final AppDatabase db;
  final TagJoins tagJoins;

  @override
  final List<Join> joinList = [];

  LinkRelationBuilder(this.db) : tagJoins = TagJoins(db);

  @override
  void createJoins(Set<IncludeOptions> includes) {
    if (includes.contains(IncludeOptions.tags)) {
      joinList.addAll(tagJoins.joins(db.links.id));
    }
  }

  @override
  List<LinkResult?> buildRelations({
    required List<TypedResult?> rows,
    Set<IncludeOptions> includes = const {},
  }) {
    final results = <LinkResult>[];
    for (final row in rows) {
      if (row == null) {
        continue;
      }
      final link = row.readTable(db.links);
      final linkResult = LinkResult(item: link);

      if (includes.contains(IncludeOptions.tags)) {
        final tag = tagJoins.readJoins(row);
        if (tag != null) {
          linkResult.tags.add(tag);
        }
      }

      results.add(linkResult);
    }
    return results;
  }
}
