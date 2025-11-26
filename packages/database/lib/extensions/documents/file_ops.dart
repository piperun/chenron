import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:database/database.dart';
import 'package:database/extensions/id.dart';
import 'package:basedir/directory.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';

extension DocumentFileOperations on AppDatabase {
  /// Creates a document with file-based storage
  Future<String> createDocumentFile({
    required String title,
    required String content,
    String mimeType = 'text/markdown',
  }) async {
    final docId = generateId();
    final extension = _getFileExtension(mimeType);
    final relativePath = 'documents/$docId$extension';
    final file = await _getDocFile(relativePath);

    // Write content to file
    await file.writeAsString(content);
    final size = await file.length();
    final hash = sha256.convert(utf8.encode(content)).toString();

    // Insert metadata
    await into(documents).insert(
      DocumentsCompanion.insert(
        id: docId,
        title: title,
        filePath: relativePath,
        mimeType: mimeType,
        fileSize: Value(size),
        checksum: Value(hash),
      ),
    );

    return docId;
  }

  /// Reads document content from file
  Future<String> readDocumentContent(String docId) async {
    final doc = await (select(documents)..where((t) => t.id.equals(docId)))
        .getSingleOrNull();

    if (doc == null) throw Exception('Document not found: $docId');

    final file = await _getDocFile(doc.filePath);
    if (!await file.exists()) {
      throw Exception('Document file not found: ${doc.filePath}');
    }

    return await file.readAsString();
  }

  /// Updates document content and/or metadata
  Future<void> updateDocumentFile({
    required String docId,
    String? title,
    String? content,
  }) async {
    if (content != null) {
      final doc = await (select(documents)..where((t) => t.id.equals(docId)))
          .getSingleOrNull();
      if (doc == null) return;

      final file = await _getDocFile(doc.filePath);
      await file.writeAsString(content);
      final size = await file.length();
      final hash = sha256.convert(utf8.encode(content)).toString();

      await (update(documents)..where((t) => t.id.equals(docId))).write(
        DocumentsCompanion(
          title: title != null ? Value(title) : Value.absent(),
          fileSize: Value(size),
          checksum: Value(hash),
        ),
      );
    } else if (title != null) {
      await (update(documents)..where((t) => t.id.equals(docId)))
          .write(DocumentsCompanion(title: Value(title)));
    }
  }

  /// Deletes document and its file
  Future<void> deleteDocumentFile(String docId) async {
    final doc = await (select(documents)..where((t) => t.id.equals(docId)))
        .getSingleOrNull();
    if (doc == null) return;

    // Delete file
    final file = await _getDocFile(doc.filePath);
    if (await file.exists()) {
      await file.delete();
    }

    // Delete database entry
    await (delete(documents)..where((t) => t.id.equals(docId))).go();
  }

  /// Helper to get document file path
  Future<File> _getDocFile(String relativePath) async {
    final baseDir = await getDefaultApplicationDirectory();
    final fullPath = path.join(baseDir.path, 'data', relativePath);
    final file = File(fullPath);
    await file.parent.create(recursive: true);
    return file;
  }

  /// Get file extension from MIME type
  String _getFileExtension(String mimeType) {
    switch (mimeType) {
      case 'text/markdown':
        return '.md';
      case 'text/typst':
        return '.typ';
      default:
        return '.md'; // Default to Markdown
    }
  }
}
