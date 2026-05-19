import "package:database/database.dart";
import "package:database/src/core/handlers/run_vepr.dart";
import "package:database/src/core/id.dart";
import "package:database/src/features/tag/handlers/insert_handler.dart";
import "package:drift/drift.dart";

typedef _LinkCreateProcess = ({List<TagResultIds>? createdTagIds});

extension LinkCreateExtensions on AppDatabase {
  Future<LinkResultIds> createLink({
    required String link,
    List<Metadata>? tags,
  }) {
    return runVepr<String, _LinkCreateProcess, LinkResultIds>(
      logSource: "createLink",
      validate: () {
        if (link.trim().isEmpty) {
          throw ArgumentError("Link URL cannot be empty.");
        }
        if (!link.startsWith("http://") && !link.startsWith("https://")) {
          throw ArgumentError("Link URL must start with http:// or https://");
        }
      },
      execute: () async {
        final existing = await (select(links)
              ..where((tbl) => tbl.path.equals(link)))
            .getSingleOrNull();
        if (existing != null) return existing.id;
        final id = generateId();
        await links.insertOne(
          LinksCompanion.insert(id: id, path: link),
          mode: InsertMode.insertOrIgnore,
        );
        return id;
      },
      process: (linkId) async {
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
              itemId: linkId,
              type: MetadataTypeEnum.tag,
            );
          }
        });
        return (createdTagIds: createdTagIds);
      },
      build: (linkId, proc) => LinkResultIds(
        linkId: linkId,
        tagIds: proc.createdTagIds,
      ),
    );
  }
}
