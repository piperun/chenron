import "package:drift/drift.dart";
import "package:cuid2/cuid2.dart";

extension GlobalIdGenerator on GeneratedDatabase {
  String generateId({int length = 30}) {
    return cuidSecure(length);
  }
}
