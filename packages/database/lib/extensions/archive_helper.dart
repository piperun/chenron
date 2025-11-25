import "package:database/database.dart";
import "package:database/extensions/link/archive.dart";
import "package:database/extensions/link/read.dart";
import "package:web_archiver/web_archiver.dart";

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
