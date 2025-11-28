import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/models/metadata.dart";
import "package:database/src/features/link/handlers/link_create_vepr.dart";

extension LinkCreateExtensions on AppDatabase {
  /// Creates a new link along with its optional tags using the VEPR pattern.
  Future<LinkResultIds> createLink({
    required String link,
    List<Metadata>? tags,
  }) async {
    // Public API method acts as the RUNNER

    // 1. Instantiate the specific VEPR implementation
    final operation = LinkCreateVEPR(this);

    final LinkCreateInput input = (
      url: link,
      tags: tags,
    );

    // 2. Use the run macro
    return operation.run(input);
  }
}
