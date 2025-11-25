import "package:database/extensions/id.dart";
import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:database/database.dart";
import "package:database/models/created_ids.dart";
import "package:chenron/utils/str_sanitizer.dart";
import "package:drift/drift.dart";

extension InsertionExtensions on AppDatabase {
  Future<List<LinkResultIds>> insertLinks({
    required Batch batch,
    required List<String> urls,
  }) async {
    final List<LinkResultIds> results = <LinkResultIds>[];
    if (urls.isEmpty) return results;

    final List<String> sanitizedUrls =
        urls.map((url) => removeTrailingSlash(url)).toList();
    final List<Link> existingLinks = await (select(links)
          ..where((tbl) => tbl.path.isIn(sanitizedUrls)))
        .get();

    final Map<String, String> existingLinkMap = {
      for (final Link link in existingLinks) link.path: link.id
    };

    for (final String url in sanitizedUrls) {
      final String linkId;

      if (existingLinkMap.containsKey(url)) {
        linkId = existingLinkMap[url]!;
      } else {
        linkId = generateId();
        batch.insert(
          links,
          LinksCompanion.insert(id: linkId, path: url),
          mode: InsertMode.insertOrIgnore,
        );
      }

      results.add(LinkResultIds(linkId: linkId));
    }

    return results;
  }

  List<DocumentResultIds> insertDocuments({
    required Batch batch,
    required List<Map<String, String>> docs,
  }) {
    final List<DocumentResultIds> results = <DocumentResultIds>[];
    if (docs.isEmpty) return results;

    for (final Map<String, String> doc in docs) {
      final String documentId = generateId();
      batch.insert(
        documents,
        DocumentsCompanion.insert(
          id: documentId,
          title: doc["title"] ?? "",
          path: doc["body"] ?? "",
        ),
        mode: InsertMode.insertOrIgnore,
      );

      results.add(
          CreatedIds.document(documentId: documentId) as DocumentResultIds);
    }

    return results;
  }

  Future<List<TagResultIds>> insertTags({
    required Batch batch,
    required List<Metadata> tagMetadata,
  }) async {
    if (tagMetadata.isEmpty) return <TagResultIds>[];

    final Map<String, String> existingTagsMap =
        await _getExistingTags(tagMetadata);
    final List<TagResultIds> results = <TagResultIds>[];

    for (final Metadata metadata in tagMetadata) {
      final String tagId;

      if (existingTagsMap.containsKey(metadata.value)) {
        tagId = existingTagsMap[metadata.value]!;
      } else {
        tagId = generateId();
        batch.insert(
          tags,
          onConflict: DoNothing(),
          mode: InsertMode.insertOrIgnore,
          TagsCompanion.insert(id: tagId, name: metadata.value),
        );
      }

      results.add(TagResultIds(tagId: tagId));
    }

    return results;
  }

  ItemResultIds insertItemRelation({
    required Batch batch,
    required String entityId,
    required String folderId,
    required FolderItemType type,
  }) {
    final String id = generateId();

    batch.insert(
      items,
      ItemsCompanion.insert(
        id: id,
        folderId: folderId,
        itemId: entityId,
        typeId: type.index,
      ),
      mode: InsertMode.insertOrIgnore,
    );

    return CreatedIds.item(
      itemId: id,
      folderId: folderId,
      linkId: type == FolderItemType.link ? entityId : null,
      documentId: type == FolderItemType.document ? entityId : null,
    ) as ItemResultIds;
  }

  MetadataResultIds insertMetadataRelation({
    required Batch batch,
    required String itemId,
    required String metadataId,
    required MetadataTypeEnum type,
    String? value,
  }) {
    final String id = generateId();

    batch.insert(
      metadataRecords,
      MetadataRecordsCompanion.insert(
        id: id,
        typeId: type.index,
        itemId: itemId,
        metadataId: metadataId,
        value: Value(value),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    return CreatedIds.metadata(
      metadataId: id,
      itemId: itemId,
    ) as MetadataResultIds;
  }

  Future<Map<String, String>> _getExistingTags(
      List<Metadata> tagInserts) async {
    if (tagInserts.isEmpty) return <String, String>{};

    final Set<String> tagNames =
        tagInserts.map((Metadata t) => t.value).toSet();

    const int maxQuerySize = 500;
    if (tagNames.length > maxQuerySize) {
      final Map<String, String> result = <String, String>{};
      final List<List<String>> chunks =
          _chunkList<String>(tagNames.toList(), maxQuerySize);

      for (final List<String> chunk in chunks) {
        final List<Tag> chunkResults =
            await (select(tags)..where((t) => t.name.isIn(chunk))).get();
        result.addAll({for (final Tag tag in chunkResults) tag.name: tag.id});
      }

      return result;
    }

    final List<Tag> existingTags =
        await (select(tags)..where((t) => t.name.isIn(tagNames))).get();
    return {for (final Tag tag in existingTags) tag.name: tag.id};
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final List<List<T>> chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      final int end =
          (i + chunkSize < list.length) ? i + chunkSize : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }
}

extension ConfigDatabaseInserts on ConfigDatabase {
  Future<List<UserThemeResultIds>> insertUserThemes({
    required Batch batch,
    required List<UserTheme> themes,
    required String userConfigId,
  }) async {
    final List<UserThemeResultIds> results = <UserThemeResultIds>[];
    if (themes.isEmpty) return results;

    for (final UserTheme theme in themes) {
      final String themeId = generateId();
      batch.insert(
        userThemes,
        UserThemesCompanion.insert(
          id: themeId,
          userConfigId: userConfigId,
          name: theme.name,
          primaryColor: theme.primaryColor,
          secondaryColor: theme.secondaryColor,
          tertiaryColor: Value(theme.tertiaryColor),
          seedType: Value(theme.seedType),
        ),
      );

      results.add(
          CreatedIds.userTheme(userThemeId: themeId, userConfigId: userConfigId)
              as UserThemeResultIds);
    }

    return results;
  }
}


