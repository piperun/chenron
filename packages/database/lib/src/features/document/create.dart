import "package:database/database.dart";
import "package:database/src/core/handlers/run_vepr.dart";
import "package:database/src/core/id.dart";
import "package:database/src/features/tag/handlers/insert_handler.dart";
import "package:drift/drift.dart";

typedef _DocumentCreateProcess = ({List<TagResultIds>? createdTagIds});

extension DocumentCreateExtensions on AppDatabase {
  Future<DocumentResultIds> createDocument({
    required String title,
    required String filePath,
    required DocumentFileType fileType,
    int? fileSize,
    String? checksum,
    List<Metadata>? tags,
  }) {
    return runVepr<String, _DocumentCreateProcess, DocumentResultIds>(
      logSource: "createDocument",
      validate: () {
        if (title.trim().isEmpty) {
          throw ArgumentError("Document title cannot be empty.");
        }
        if (filePath.trim().isEmpty) {
          throw ArgumentError("Document file path cannot be empty.");
        }
      },
      execute: () async {
        final existing = await (select(documents)
              ..where((tbl) => tbl.filePath.equals(filePath)))
            .getSingleOrNull();
        if (existing != null) return existing.id;
        final id = generateId();
        await documents.insertOne(
          DocumentsCompanion.insert(
            id: id,
            title: title,
            filePath: filePath,
            fileType: fileType,
            fileSize: Value(fileSize),
            checksum: Value(checksum),
          ),
          mode: InsertMode.insertOrIgnore,
        );
        return id;
      },
      process: (docId) async {
        if (tags == null || tags.isEmpty) {
          return (createdTagIds: null);
        }
        List<TagResultIds>? createdTagIds;
        await batch((b) async {
          createdTagIds = await insertTags(batch: b, tagMetadata: tags);
          for (final tagResult in createdTagIds!) {
            insertMetadataRelation(
              batch: b,
              metadataId: tagResult.tagId,
              itemId: docId,
              type: MetadataTypeEnum.tag,
            );
          }
        });
        return (createdTagIds: createdTagIds);
      },
      build: (docId, proc) => DocumentResultIds(
        documentId: docId,
        tagIds: proc.createdTagIds?.map((t) => t.tagId).toList(),
      ),
    );
  }
}
