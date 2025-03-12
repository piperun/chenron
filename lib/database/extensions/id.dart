import "package:chenron/database/database.dart";
import "package:cuid2/cuid2.dart";

//TODO: Generalize this to all databases

extension IdGeneratorExtension on AppDatabase {
  String generateId() {
    return cuidSecure(AppDatabase.idLength);
  }
}

extension ConfigIdGeneratorExtension on ConfigDatabase {
  String generateId() {
    return cuidSecure(AppDatabase.idLength);
  }
}
