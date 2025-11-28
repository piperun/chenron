import "package:database/database.dart";
import "package:database/operations/link/link_create_vepr.dart";

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


