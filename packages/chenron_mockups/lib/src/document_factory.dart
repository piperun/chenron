import 'package:cuid2/cuid2.dart';
import 'package:database/database.dart';
import 'package:database/main.dart';
import 'package:drift/drift.dart';

class DocumentFactory {
  static DocumentsCompanion createCompanion({
    String? id,
    String? title,
    String? filePath,
    DocumentFileType? fileType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentsCompanion(
      id: id != null ? Value(id) : const Value.absent(),
      title: title != null ? Value(title) : const Value.absent(),
      filePath: filePath != null ? Value(filePath) : const Value.absent(),
      fileType: fileType != null ? Value(fileType) : const Value.absent(),
      createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
      updatedAt: updatedAt != null ? Value(updatedAt) : const Value.absent(),
    );
  }

  static Document create({
    String? id,
    required String title,
    required String filePath,
    required DocumentFileType fileType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? cuid(30),
      title: title,
      filePath: filePath,
      fileType: fileType,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
