import "package:database/main.dart";
import "package:database/models/db_result.dart";
import "package:drift/drift.dart";
import "package:database/src/core/builders/result_builder.dart";
import "package:database/src/core/builders/tag_processing_mixin.dart";

class LinkResultBuilder
    with TagProcessingMixin
    implements ResultBuilder<LinkResult> {
  final Link _link;
  final AppDatabase _db;

  LinkResultBuilder(this._link, this._db);

  @override
  String get entityId => _link.id;

  @override
  void processRow(TypedResult row, Set<Enum> includeOptions) {
    processTags(row, includeOptions, _db.tags);
  }

  @override
  LinkResult build() {
    return LinkResult(
      data: _link,
      tags: tags,
    );
  }
}
