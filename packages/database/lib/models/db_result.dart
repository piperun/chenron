import "package:database/database.dart";
import "package:freezed_annotation/freezed_annotation.dart";
part "db_result.freezed.dart";

@freezed
abstract class DbResult with _$DbResult {
  const factory DbResult.folder({
    required Folder data,
    required List<Tag> tags,
    required List<FolderItem> items,
  }) = FolderResult;

  const factory DbResult.link({
    required Link data,
    required List<Tag> tags,
  }) = LinkResult;

  const factory DbResult.document({
    required String title,
    required String filePath,
    required DocumentFileType fileType,
    List<Tag>? tags,
  }) = DocumentResult;

  const factory DbResult.tag({
    required String name,
    int? color,
    List<String>? relatedFolderIds,
    List<String>? relatedLinkIds,
    List<String>? relatedDocumentIds,
  }) = TagResult;

  const factory DbResult.userConfig({
    required UserConfig data,
    List<UserTheme>? userThemes,
    BackupSetting? backupSettings,
  }) = UserConfigResult;

  const factory DbResult.userTheme({
    required UserTheme data,
    //NOTE: This will most likely be remove in the future when we implement users
    String? userConfigId,
    List<String>? sharedUserIds,
  }) = UserThemeResult;
}
