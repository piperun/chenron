import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:chenron/database/database.dart';
import 'package:cuid2/cuid2.dart';
import 'package:logging/logging.dart';

enum RelationType {
  folder,
  tag,
  link,
  document,
  // Add more types as needed
}

abstract class DataBaseObject {
  String get id;
  String get type;
  UpdateCompanion toInsertable() {
    throw UnimplementedError('toInsertable must be implemented by subclasses');
  }
}

class CUD<D> {
  final List<DataBaseObject> create;
  final List<Insertable<D>> remove;
  final List<Insertable<D>> update;
  final _logger = Logger('CUD');

  CUD({
    List<DataBaseObject>? create,
    List<Insertable<D>>? remove,
    List<Insertable<D>>? update,
  })  : create = create ?? [],
        remove = remove ?? [],
        update = update ?? [],
        assert(
          create?.isNotEmpty == true ||
              remove?.isNotEmpty == true ||
              update?.isNotEmpty == true,
          'At least one operation (create, remove, or update) must be provided',
        );

  void addCreate(DataBaseObject object) {
    create.add(object);
  }

  void addRemove(Insertable<D> insertRemove) {
    remove.add(insertRemove);
    _logger.info('Added ID to remove list: $insertRemove');
  }

  void addUpdate(Insertable<D> insertUpdate) {
    update.add(insertUpdate);
  }

  bool get hasOperations =>
      create.isNotEmpty || remove.isNotEmpty || update.isNotEmpty;

  int get totalOperations => create.length + remove.length + update.length;
}

@immutable
class FolderDataType extends DataBaseObject {
  @override
  final String id;
  @override
  final String type = 'folders';
  final String title;
  final String description;

  FolderDataType._({
    String? id,
    int? idLength,
    required this.title,
    required this.description,
  }) : id = id ?? cuidSecure(idLength ?? 30);

  factory FolderDataType({
    required String title,
    required String description,
  }) {
    return FolderDataType._(
      title: title,
      description: description,
    );
  }

  @override
  FoldersCompanion toInsertable() {
    return FoldersCompanion.insert(
        id: id, title: title, description: description);
  }

  FolderDataType copyWith({
    String? parentId,
    String? title,
    String? description,
  }) {
    return FolderDataType._(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}

@immutable
class TagDataType extends DataBaseObject {
  final String id;
  final String name;
  @override
  final String type = "tags";

  TagDataType._({
    String? id,
    int? idLength,
    required this.name,
  }) : id = id ?? cuidSecure(idLength ?? 30);

  factory TagDataType({required String name}) {
    return TagDataType._(name: name);
  }

  @override
  TagsCompanion toInsertable() {
    return TagsCompanion.insert(id: id, name: name);
  }

  TagDataType copyWith({String? name}) {
    return TagDataType._(
      id: this.id,
      name: name ?? this.name,
    );
  }
}

@immutable
class LinkDataType extends DataBaseObject {
  final String id;
  final String url;
  @override
  final String type = 'links';

  LinkDataType._({
    String? id,
    required this.url,
  }) : id = id ?? cuidSecure(30);

  factory LinkDataType({required String url}) {
    return LinkDataType._(url: url);
  }

  @override
  LinksCompanion toInsertable() {
    return LinksCompanion.insert(id: id, url: url);
  }

  LinkDataType copyWith({String? url}) {
    return LinkDataType._(
      id: this.id,
      url: url ?? this.url,
    );
  }
}

@immutable
class DocumentDataType extends DataBaseObject {
  final String id;
  final String title;
  final String content;
  @override
  final String type = 'links';

  DocumentDataType._({
    String? id,
    int? idLength,
    required this.title,
    required this.content,
  }) : id = id ?? cuidSecure(idLength ?? 30);

  @override
  DocumentsCompanion toInsertable() {
    return DocumentsCompanion.insert(
        id: id, title: title, content: utf8.encode(content));
  }

  factory DocumentDataType({
    required String title,
    required String content,
  }) {
    return DocumentDataType._(
      title: title,
      content: content,
    );
  }

  DocumentDataType copyWith({
    String? title,
    List<int>? data,
  }) {
    return DocumentDataType._(
      id: this.id,
      title: title ?? this.title,
      content: content,
    );
  }
}

class InvalidIdLengthException implements Exception {
  final String message;
  InvalidIdLengthException(this.message);
}

class InvalidIdFormatException implements Exception {
  final String message;
  InvalidIdFormatException(this.message);
}
