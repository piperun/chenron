import "package:freezed_annotation/freezed_annotation.dart";

part "created_ids.freezed.dart";

@freezed
class CreatedIds with _$CreatedIds {
  const factory CreatedIds.folder({
    required String folderId,
    List<ItemResultIds>? itemIds,
    List<TagResultIds>? tagIds,
  }) = FolderResultIds;

  const factory CreatedIds.link({
    required String linkId,
    List<TagResultIds>? tagIds,
  }) = LinkResultIds;

  const factory CreatedIds.document({
    required String documentId,
    List<String>? tagIds,
  }) = DocumentResultIds;

  const factory CreatedIds.tag({
    required String tagId,
    List<String>? itemIds,
    @Default(false) bool wasCreated,
  }) = TagResultIds;

  const factory CreatedIds.item({
    required String itemId,
    required String folderId,
    String? linkId,
    String? documentId,
  }) = ItemResultIds;

  const factory CreatedIds.metadata({
    required String metadataId,
    required String itemId,
  }) = MetadataResultIds;

  const factory CreatedIds.userConfig({
    required String userConfigId,
    List<UserThemeResultIds>? userThemesIds,
  }) = UserConfigResultIds;
  const factory CreatedIds.userTheme({
    required String userThemeId,
    required String userConfigId,
  }) = UserThemeResultIds;

  const factory CreatedIds.backupSettings({
    required String backupSettingsId,
    required String userConfigId,
  }) = BackupSettingsResultIds;
}


