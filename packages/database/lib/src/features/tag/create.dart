import "package:database/main.dart";
import "package:database/src/features/tag/handlers/tag_create_vepr.dart";

extension TagExtensions on AppDatabase {
  Future<String> addTag(String tagName, {int? color}) async {
    final operation = TagCreateVEPR(this);
    final input = (tagName: tagName, color: color);

    final result = await operation.run(input);
    return result.tagId;
  }
}
