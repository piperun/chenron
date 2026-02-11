import "package:database/main.dart";
import "package:database/models/db_result.dart";
import "package:drift/drift.dart";
import "package:database/src/core/builders/result_builder.dart";
import "package:database/src/core/builders/tag_processing_mixin.dart";

class DocumentResultBuilder
    with TagProcessingMixin
    implements ResultBuilder<DocumentResult> {
  final Document _document;
  final AppDatabase _db;

  DocumentResultBuilder(this._document, this._db);

  @override
  String get entityId => _document.id;

  @override
  void processRow(TypedResult row, Set<Enum> includeOptions) {
    processTags(row, includeOptions, _db.tags);
  }

  @override
  DocumentResult build() {
    return DocumentResult(
      data: _document,
      tags: tags.isEmpty ? null : tags,
    );
  }
}
