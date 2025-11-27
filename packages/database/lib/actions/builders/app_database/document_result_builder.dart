import "package:drift/drift.dart";
import "package:database/actions/builders/result_builder.dart";
import "package:database/database.dart";
import "package:database/models/db_result.dart";

class DocumentResultBuilder implements ResultBuilder<DocumentResult> {
  final Document _document;
  final List<Tag> _tags = [];
  final AppDatabase _db;

  DocumentResultBuilder(this._document, this._db);

  @override
  String get entityId => _document.id;

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
  DocumentResult build() {
    return DocumentResult(
      title: _document.title,
      filePath: _document.filePath,
      tags: _tags.isEmpty ? null : _tags,
    );
  }
}
