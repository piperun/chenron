import "package:drift/drift.dart";
import "package:database/actions/builders/result_builder.dart";
import "package:database/database.dart";
import "package:database/models/db_result.dart";

class LinkResultBuilder implements ResultBuilder<LinkResult> {
  final Link _link;
  final List<Tag> _tags = [];
  final AppDatabase _db;

  LinkResultBuilder(this._link, this._db);

  @override
  String get entityId => _link.id;

  @override
  void processRow(TypedResult row, Set<Enum> includeOptions) {
    if (includeOptions.contains(AppDataInclude.tags)) {
      final tag = row.readTableOrNull(_db.tags);
      if (tag != null && !_tags.any((t) => t.id == tag.id)) {
        _tags.add(tag);
      }
    }
  }

  @override
  LinkResult build() {
    return LinkResult(
      data: _link,
      tags: _tags,
    );
  }
}


