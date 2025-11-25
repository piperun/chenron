import "package:database/database.dart";
import "package:database/operations/tag/tag_create_vepr.dart";

extension TagExtensions on AppDatabase {
  Future<String> addTag(String tagName) async {
    final operation = TagCreateVEPR(this);
    final input = (tagName: tagName);

    final result = await operation.run(input);
    return result.tagId;
  }
}


