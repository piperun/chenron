import "package:chenron/database/database.dart";
import "package:cuid2/cuid2.dart";

extension IdGeneratorExtension on AppDatabase {
  String generateId() {
    return cuidSecure(AppDatabase.idLength);
  }
}
