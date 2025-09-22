import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/link/archive.dart";
import "package:chenron/database/extensions/link/read.dart";
import "package:chenron/utils/web_archive/archive_org/archive_org_options.dart";
import "package:chenron/utils/web_archive/archive_org/parse_archive_date.dart";

extension ArchiveHelperExtension on AppDatabase {
  Future<void> archiveOrgLinks(
    List<String> linkIds,
    UserConfig userConfig, {
    int archiveDueDate = 7,
    ArchiveOrgOptions? archiveOptions,
  }) async {
    if (userConfig.archiveOrgS3AccessKey!.isNotEmpty &&
        userConfig.archiveOrgS3SecretKey!.isNotEmpty) {
      for (final linkId in linkIds) {
        final linkResult = await getLink(linkId: linkId);
        if (linkResult != null) {
          final url = linkResult.data.path;
          final archiveDate = parseArchiveDate(url);
          final now = DateTime.now();

          if (archiveDate == null ||
              now.difference(archiveDate).inDays > archiveDueDate) {
            await archiveLink(
              linkId,
              accessKey: userConfig.archiveOrgS3AccessKey!,
              secretKey: userConfig.archiveOrgS3SecretKey!,
              options: archiveOptions,
            );
          }
        }
      }
    }
  }
}
