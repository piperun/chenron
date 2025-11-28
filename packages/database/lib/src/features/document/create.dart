import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/models/document_file_type.dart";
import "package:database/models/metadata.dart";
import "package:database/src/features/document/handlers/document_create_vepr.dart";

extension DocumentCreateExtensions on AppDatabase {
  /// Creates a new document along with its optional tags using the VEPR pattern.
  Future<DocumentResultIds> createDocument({
    required String title,
    required String filePath,
    required DocumentFileType fileType,
    int? fileSize,
    String? checksum,
    List<Metadata>? tags,
  }) async {
    // Public API method acts as the RUNNER

    // 1. Instantiate the specific VEPR implementation
    final operation = DocumentCreateVEPR(this);

    final DocumentCreateInput input = (
      title: title,
      filePath: filePath,
      fileType: fileType,
      fileSize: fileSize,
      checksum: checksum,
      tags: tags,
    );

    // 2. Use the run macro
    return operation.run(input);
  }
}
