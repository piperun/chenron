// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 30, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 6, maxTextLength: 30),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0, maxTextLength: 1000),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, title, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(Insertable<Folder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final String id;
  final String title;
  final String description;
  const Folder(
      {required this.id, required this.title, required this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
    );
  }

  factory Folder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
    };
  }

  Folder copyWith({String? id, String? title, String? description}) => Folder(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
      );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int> rowid;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoldersCompanion.insert({
    required String id,
    required String title,
    required String description,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description);
  static Insertable<Folder> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoldersCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<int>? rowid}) {
    return FoldersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LinksTable extends Links with TableInfo<$LinksTable, Link> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 30, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, url];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'links';
  @override
  VerificationContext validateIntegrity(Insertable<Link> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Link map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Link(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
    );
  }

  @override
  $LinksTable createAlias(String alias) {
    return $LinksTable(attachedDatabase, alias);
  }
}

class Link extends DataClass implements Insertable<Link> {
  final String id;
  final String url;
  const Link({required this.id, required this.url});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    return map;
  }

  LinksCompanion toCompanion(bool nullToAbsent) {
    return LinksCompanion(
      id: Value(id),
      url: Value(url),
    );
  }

  factory Link.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Link(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
    };
  }

  Link copyWith({String? id, String? url}) => Link(
        id: id ?? this.id,
        url: url ?? this.url,
      );
  Link copyWithCompanion(LinksCompanion data) {
    return Link(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Link(')
          ..write('id: $id, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, url);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Link && other.id == this.id && other.url == this.url);
}

class LinksCompanion extends UpdateCompanion<Link> {
  final Value<String> id;
  final Value<String> url;
  final Value<int> rowid;
  const LinksCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinksCompanion.insert({
    required String id,
    required String url,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        url = Value(url);
  static Insertable<Link> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinksCompanion copyWith(
      {Value<String>? id, Value<String>? url, Value<int>? rowid}) {
    return LinksCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinksCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, Document> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 30, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 6, maxTextLength: 30),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<Uint8List> content = GeneratedColumn<Uint8List>(
      'content', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, title, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(Insertable<Document> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Document map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Document(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}content'])!,
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class Document extends DataClass implements Insertable<Document> {
  final String id;
  final String title;
  final Uint8List content;
  const Document(
      {required this.id, required this.title, required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<Uint8List>(content);
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
    );
  }

  factory Document.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Document(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<Uint8List>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<Uint8List>(content),
    };
  }

  Document copyWith({String? id, String? title, Uint8List? content}) =>
      Document(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
      );
  Document copyWithCompanion(DocumentsCompanion data) {
    return Document(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Document(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, $driftBlobEquality.hash(content));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Document &&
          other.id == this.id &&
          other.title == this.title &&
          $driftBlobEquality.equals(other.content, this.content));
}

class DocumentsCompanion extends UpdateCompanion<Document> {
  final Value<String> id;
  final Value<String> title;
  final Value<Uint8List> content;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    required String title,
    required Uint8List content,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        content = Value(content);
  static Insertable<Document> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<Uint8List>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<Uint8List>? content,
      Value<int>? rowid}) {
    return DocumentsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<Uint8List>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 30, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 12),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  const Tag({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Tag copyWith({String? id, String? name}) => Tag(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag && other.id == this.id && other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id, Value<String>? name, Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FolderTagsTable extends FolderTags
    with TableInfo<$FolderTagsTable, FolderTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FolderTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
      'folder_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES folders (id)'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tags (id)'));
  @override
  List<GeneratedColumn> get $columns => [folderId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folder_tags';
  @override
  VerificationContext validateIntegrity(Insertable<FolderTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {folderId, tagId};
  @override
  FolderTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FolderTag(
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}folder_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $FolderTagsTable createAlias(String alias) {
    return $FolderTagsTable(attachedDatabase, alias);
  }
}

class FolderTag extends DataClass implements Insertable<FolderTag> {
  final String folderId;
  final String tagId;
  const FolderTag({required this.folderId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['folder_id'] = Variable<String>(folderId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  FolderTagsCompanion toCompanion(bool nullToAbsent) {
    return FolderTagsCompanion(
      folderId: Value(folderId),
      tagId: Value(tagId),
    );
  }

  factory FolderTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FolderTag(
      folderId: serializer.fromJson<String>(json['folderId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'folderId': serializer.toJson<String>(folderId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  FolderTag copyWith({String? folderId, String? tagId}) => FolderTag(
        folderId: folderId ?? this.folderId,
        tagId: tagId ?? this.tagId,
      );
  FolderTag copyWithCompanion(FolderTagsCompanion data) {
    return FolderTag(
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FolderTag(')
          ..write('folderId: $folderId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(folderId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FolderTag &&
          other.folderId == this.folderId &&
          other.tagId == this.tagId);
}

class FolderTagsCompanion extends UpdateCompanion<FolderTag> {
  final Value<String> folderId;
  final Value<String> tagId;
  final Value<int> rowid;
  const FolderTagsCompanion({
    this.folderId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FolderTagsCompanion.insert({
    required String folderId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : folderId = Value(folderId),
        tagId = Value(tagId);
  static Insertable<FolderTag> custom({
    Expression<String>? folderId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (folderId != null) 'folder_id': folderId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FolderTagsCompanion copyWith(
      {Value<String>? folderId, Value<String>? tagId, Value<int>? rowid}) {
    return FolderTagsCompanion(
      folderId: folderId ?? this.folderId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FolderTagsCompanion(')
          ..write('folderId: $folderId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FolderDocumentsTable extends FolderDocuments
    with TableInfo<$FolderDocumentsTable, FolderDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FolderDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
      'folder_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES folders (id)'));
  static const VerificationMeta _documentIdMeta =
      const VerificationMeta('documentId');
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
      'document_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES documents (id)'));
  @override
  List<GeneratedColumn> get $columns => [folderId, documentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folder_documents';
  @override
  VerificationContext validateIntegrity(Insertable<FolderDocument> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
          _documentIdMeta,
          documentId.isAcceptableOrUnknown(
              data['document_id']!, _documentIdMeta));
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {folderId, documentId};
  @override
  FolderDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FolderDocument(
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}folder_id'])!,
      documentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_id'])!,
    );
  }

  @override
  $FolderDocumentsTable createAlias(String alias) {
    return $FolderDocumentsTable(attachedDatabase, alias);
  }
}

class FolderDocument extends DataClass implements Insertable<FolderDocument> {
  final String folderId;
  final String documentId;
  const FolderDocument({required this.folderId, required this.documentId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['folder_id'] = Variable<String>(folderId);
    map['document_id'] = Variable<String>(documentId);
    return map;
  }

  FolderDocumentsCompanion toCompanion(bool nullToAbsent) {
    return FolderDocumentsCompanion(
      folderId: Value(folderId),
      documentId: Value(documentId),
    );
  }

  factory FolderDocument.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FolderDocument(
      folderId: serializer.fromJson<String>(json['folderId']),
      documentId: serializer.fromJson<String>(json['documentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'folderId': serializer.toJson<String>(folderId),
      'documentId': serializer.toJson<String>(documentId),
    };
  }

  FolderDocument copyWith({String? folderId, String? documentId}) =>
      FolderDocument(
        folderId: folderId ?? this.folderId,
        documentId: documentId ?? this.documentId,
      );
  FolderDocument copyWithCompanion(FolderDocumentsCompanion data) {
    return FolderDocument(
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      documentId:
          data.documentId.present ? data.documentId.value : this.documentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FolderDocument(')
          ..write('folderId: $folderId, ')
          ..write('documentId: $documentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(folderId, documentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FolderDocument &&
          other.folderId == this.folderId &&
          other.documentId == this.documentId);
}

class FolderDocumentsCompanion extends UpdateCompanion<FolderDocument> {
  final Value<String> folderId;
  final Value<String> documentId;
  final Value<int> rowid;
  const FolderDocumentsCompanion({
    this.folderId = const Value.absent(),
    this.documentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FolderDocumentsCompanion.insert({
    required String folderId,
    required String documentId,
    this.rowid = const Value.absent(),
  })  : folderId = Value(folderId),
        documentId = Value(documentId);
  static Insertable<FolderDocument> custom({
    Expression<String>? folderId,
    Expression<String>? documentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (folderId != null) 'folder_id': folderId,
      if (documentId != null) 'document_id': documentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FolderDocumentsCompanion copyWith(
      {Value<String>? folderId, Value<String>? documentId, Value<int>? rowid}) {
    return FolderDocumentsCompanion(
      folderId: folderId ?? this.folderId,
      documentId: documentId ?? this.documentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FolderDocumentsCompanion(')
          ..write('folderId: $folderId, ')
          ..write('documentId: $documentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FolderLinksTable extends FolderLinks
    with TableInfo<$FolderLinksTable, FolderLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FolderLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
      'folder_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES folders (id)'));
  static const VerificationMeta _linkIdMeta = const VerificationMeta('linkId');
  @override
  late final GeneratedColumn<String> linkId = GeneratedColumn<String>(
      'link_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES links (id)'));
  @override
  List<GeneratedColumn> get $columns => [folderId, linkId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folder_links';
  @override
  VerificationContext validateIntegrity(Insertable<FolderLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('link_id')) {
      context.handle(_linkIdMeta,
          linkId.isAcceptableOrUnknown(data['link_id']!, _linkIdMeta));
    } else if (isInserting) {
      context.missing(_linkIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {folderId, linkId};
  @override
  FolderLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FolderLink(
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}folder_id'])!,
      linkId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}link_id'])!,
    );
  }

  @override
  $FolderLinksTable createAlias(String alias) {
    return $FolderLinksTable(attachedDatabase, alias);
  }
}

class FolderLink extends DataClass implements Insertable<FolderLink> {
  final String folderId;
  final String linkId;
  const FolderLink({required this.folderId, required this.linkId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['folder_id'] = Variable<String>(folderId);
    map['link_id'] = Variable<String>(linkId);
    return map;
  }

  FolderLinksCompanion toCompanion(bool nullToAbsent) {
    return FolderLinksCompanion(
      folderId: Value(folderId),
      linkId: Value(linkId),
    );
  }

  factory FolderLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FolderLink(
      folderId: serializer.fromJson<String>(json['folderId']),
      linkId: serializer.fromJson<String>(json['linkId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'folderId': serializer.toJson<String>(folderId),
      'linkId': serializer.toJson<String>(linkId),
    };
  }

  FolderLink copyWith({String? folderId, String? linkId}) => FolderLink(
        folderId: folderId ?? this.folderId,
        linkId: linkId ?? this.linkId,
      );
  FolderLink copyWithCompanion(FolderLinksCompanion data) {
    return FolderLink(
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      linkId: data.linkId.present ? data.linkId.value : this.linkId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FolderLink(')
          ..write('folderId: $folderId, ')
          ..write('linkId: $linkId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(folderId, linkId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FolderLink &&
          other.folderId == this.folderId &&
          other.linkId == this.linkId);
}

class FolderLinksCompanion extends UpdateCompanion<FolderLink> {
  final Value<String> folderId;
  final Value<String> linkId;
  final Value<int> rowid;
  const FolderLinksCompanion({
    this.folderId = const Value.absent(),
    this.linkId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FolderLinksCompanion.insert({
    required String folderId,
    required String linkId,
    this.rowid = const Value.absent(),
  })  : folderId = Value(folderId),
        linkId = Value(linkId);
  static Insertable<FolderLink> custom({
    Expression<String>? folderId,
    Expression<String>? linkId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (folderId != null) 'folder_id': folderId,
      if (linkId != null) 'link_id': linkId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FolderLinksCompanion copyWith(
      {Value<String>? folderId, Value<String>? linkId, Value<int>? rowid}) {
    return FolderLinksCompanion(
      folderId: folderId ?? this.folderId,
      linkId: linkId ?? this.linkId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (linkId.present) {
      map['link_id'] = Variable<String>(linkId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FolderLinksCompanion(')
          ..write('folderId: $folderId, ')
          ..write('linkId: $linkId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FolderTreesTable extends FolderTrees
    with TableInfo<$FolderTreesTable, FolderTree> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FolderTreesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES folders (id)'));
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
      'child_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES folders (id)'));
  @override
  List<GeneratedColumn> get $columns => [parentId, childId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folder_trees';
  @override
  VerificationContext validateIntegrity(Insertable<FolderTree> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    } else if (isInserting) {
      context.missing(_parentIdMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {parentId, childId};
  @override
  FolderTree map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FolderTree(
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
    );
  }

  @override
  $FolderTreesTable createAlias(String alias) {
    return $FolderTreesTable(attachedDatabase, alias);
  }
}

class FolderTree extends DataClass implements Insertable<FolderTree> {
  final String parentId;
  final String childId;
  const FolderTree({required this.parentId, required this.childId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['parent_id'] = Variable<String>(parentId);
    map['child_id'] = Variable<String>(childId);
    return map;
  }

  FolderTreesCompanion toCompanion(bool nullToAbsent) {
    return FolderTreesCompanion(
      parentId: Value(parentId),
      childId: Value(childId),
    );
  }

  factory FolderTree.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FolderTree(
      parentId: serializer.fromJson<String>(json['parentId']),
      childId: serializer.fromJson<String>(json['childId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'parentId': serializer.toJson<String>(parentId),
      'childId': serializer.toJson<String>(childId),
    };
  }

  FolderTree copyWith({String? parentId, String? childId}) => FolderTree(
        parentId: parentId ?? this.parentId,
        childId: childId ?? this.childId,
      );
  FolderTree copyWithCompanion(FolderTreesCompanion data) {
    return FolderTree(
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      childId: data.childId.present ? data.childId.value : this.childId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FolderTree(')
          ..write('parentId: $parentId, ')
          ..write('childId: $childId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(parentId, childId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FolderTree &&
          other.parentId == this.parentId &&
          other.childId == this.childId);
}

class FolderTreesCompanion extends UpdateCompanion<FolderTree> {
  final Value<String> parentId;
  final Value<String> childId;
  final Value<int> rowid;
  const FolderTreesCompanion({
    this.parentId = const Value.absent(),
    this.childId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FolderTreesCompanion.insert({
    required String parentId,
    required String childId,
    this.rowid = const Value.absent(),
  })  : parentId = Value(parentId),
        childId = Value(childId);
  static Insertable<FolderTree> custom({
    Expression<String>? parentId,
    Expression<String>? childId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (parentId != null) 'parent_id': parentId,
      if (childId != null) 'child_id': childId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FolderTreesCompanion copyWith(
      {Value<String>? parentId, Value<String>? childId, Value<int>? rowid}) {
    return FolderTreesCompanion(
      parentId: parentId ?? this.parentId,
      childId: childId ?? this.childId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FolderTreesCompanion(')
          ..write('parentId: $parentId, ')
          ..write('childId: $childId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $LinksTable links = $LinksTable(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $FolderTagsTable folderTags = $FolderTagsTable(this);
  late final $FolderDocumentsTable folderDocuments =
      $FolderDocumentsTable(this);
  late final $FolderLinksTable folderLinks = $FolderLinksTable(this);
  late final $FolderTreesTable folderTrees = $FolderTreesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        folders,
        links,
        documents,
        tags,
        folderTags,
        folderDocuments,
        folderLinks,
        folderTrees
      ];
}

typedef $$FoldersTableCreateCompanionBuilder = FoldersCompanion Function({
  required String id,
  required String title,
  required String description,
  Value<int> rowid,
});
typedef $$FoldersTableUpdateCompanionBuilder = FoldersCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<int> rowid,
});

final class $$FoldersTableReferences
    extends BaseReferences<_$AppDatabase, $FoldersTable, Folder> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FolderTagsTable, List<FolderTag>>
      _folderTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.folderTags,
              aliasName:
                  $_aliasNameGenerator(db.folders.id, db.folderTags.folderId));

  $$FolderTagsTableProcessedTableManager get folderTagsRefs {
    final manager = $$FolderTagsTableTableManager($_db, $_db.folderTags)
        .filter((f) => f.folderId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_folderTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FolderDocumentsTable, List<FolderDocument>>
      _folderDocumentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.folderDocuments,
              aliasName: $_aliasNameGenerator(
                  db.folders.id, db.folderDocuments.folderId));

  $$FolderDocumentsTableProcessedTableManager get folderDocumentsRefs {
    final manager =
        $$FolderDocumentsTableTableManager($_db, $_db.folderDocuments)
            .filter((f) => f.folderId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_folderDocumentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FolderLinksTable, List<FolderLink>>
      _folderLinksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.folderLinks,
              aliasName:
                  $_aliasNameGenerator(db.folders.id, db.folderLinks.folderId));

  $$FolderLinksTableProcessedTableManager get folderLinksRefs {
    final manager = $$FolderLinksTableTableManager($_db, $_db.folderLinks)
        .filter((f) => f.folderId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_folderLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FolderTreesTable, List<FolderTree>>
      _parentFolderTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.folderTrees,
              aliasName:
                  $_aliasNameGenerator(db.folders.id, db.folderTrees.parentId));

  $$FolderTreesTableProcessedTableManager get parentFolder {
    final manager = $$FolderTreesTableTableManager($_db, $_db.folderTrees)
        .filter((f) => f.parentId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_parentFolderTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FolderTreesTable, List<FolderTree>>
      _childFolderTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.folderTrees,
              aliasName:
                  $_aliasNameGenerator(db.folders.id, db.folderTrees.childId));

  $$FolderTreesTableProcessedTableManager get childFolder {
    final manager = $$FolderTreesTableTableManager($_db, $_db.folderTrees)
        .filter((f) => f.childId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_childFolderTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$FoldersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter folderTagsRefs(
      ComposableFilter Function($$FolderTagsTableFilterComposer f) f) {
    final $$FolderTagsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.folderTags,
        getReferencedColumn: (t) => t.folderId,
        builder: (joinBuilder, parentComposers) =>
            $$FolderTagsTableFilterComposer(ComposerState($state.db,
                $state.db.folderTags, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter folderDocumentsRefs(
      ComposableFilter Function($$FolderDocumentsTableFilterComposer f) f) {
    final $$FolderDocumentsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.folderDocuments,
            getReferencedColumn: (t) => t.folderId,
            builder: (joinBuilder, parentComposers) =>
                $$FolderDocumentsTableFilterComposer(ComposerState($state.db,
                    $state.db.folderDocuments, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter folderLinksRefs(
      ComposableFilter Function($$FolderLinksTableFilterComposer f) f) {
    final $$FolderLinksTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.folderLinks,
        getReferencedColumn: (t) => t.folderId,
        builder: (joinBuilder, parentComposers) =>
            $$FolderLinksTableFilterComposer(ComposerState($state.db,
                $state.db.folderLinks, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter parentFolder(
      ComposableFilter Function($$FolderTreesTableFilterComposer f) f) {
    final $$FolderTreesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.folderTrees,
        getReferencedColumn: (t) => t.parentId,
        builder: (joinBuilder, parentComposers) =>
            $$FolderTreesTableFilterComposer(ComposerState($state.db,
                $state.db.folderTrees, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter childFolder(
      ComposableFilter Function($$FolderTreesTableFilterComposer f) f) {
    final $$FolderTreesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.folderTrees,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder, parentComposers) =>
            $$FolderTreesTableFilterComposer(ComposerState($state.db,
                $state.db.folderTrees, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$FoldersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$FoldersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FoldersTable,
    Folder,
    $$FoldersTableFilterComposer,
    $$FoldersTableOrderingComposer,
    $$FoldersTableCreateCompanionBuilder,
    $$FoldersTableUpdateCompanionBuilder,
    (Folder, $$FoldersTableReferences),
    Folder,
    PrefetchHooks Function(
        {bool folderTagsRefs,
        bool folderDocumentsRefs,
        bool folderLinksRefs,
        bool parentFolder,
        bool childFolder})> {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FoldersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FoldersTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FoldersCompanion(
            id: id,
            title: title,
            description: description,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String description,
            Value<int> rowid = const Value.absent(),
          }) =>
              FoldersCompanion.insert(
            id: id,
            title: title,
            description: description,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$FoldersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {folderTagsRefs = false,
              folderDocumentsRefs = false,
              folderLinksRefs = false,
              parentFolder = false,
              childFolder = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (folderTagsRefs) db.folderTags,
                if (folderDocumentsRefs) db.folderDocuments,
                if (folderLinksRefs) db.folderLinks,
                if (parentFolder) db.folderTrees,
                if (childFolder) db.folderTrees
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (folderTagsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$FoldersTableReferences._folderTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FoldersTableReferences(db, table, p0)
                                .folderTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.folderId == item.id),
                        typedResults: items),
                  if (folderDocumentsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$FoldersTableReferences
                            ._folderDocumentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FoldersTableReferences(db, table, p0)
                                .folderDocumentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.folderId == item.id),
                        typedResults: items),
                  if (folderLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$FoldersTableReferences._folderLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FoldersTableReferences(db, table, p0)
                                .folderLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.folderId == item.id),
                        typedResults: items),
                  if (parentFolder)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$FoldersTableReferences._parentFolderTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FoldersTableReferences(db, table, p0)
                                .parentFolder,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.parentId == item.id),
                        typedResults: items),
                  if (childFolder)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$FoldersTableReferences._childFolderTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FoldersTableReferences(db, table, p0).childFolder,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.childId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$FoldersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FoldersTable,
    Folder,
    $$FoldersTableFilterComposer,
    $$FoldersTableOrderingComposer,
    $$FoldersTableCreateCompanionBuilder,
    $$FoldersTableUpdateCompanionBuilder,
    (Folder, $$FoldersTableReferences),
    Folder,
    PrefetchHooks Function(
        {bool folderTagsRefs,
        bool folderDocumentsRefs,
        bool folderLinksRefs,
        bool parentFolder,
        bool childFolder})>;
typedef $$LinksTableCreateCompanionBuilder = LinksCompanion Function({
  required String id,
  required String url,
  Value<int> rowid,
});
typedef $$LinksTableUpdateCompanionBuilder = LinksCompanion Function({
  Value<String> id,
  Value<String> url,
  Value<int> rowid,
});

final class $$LinksTableReferences
    extends BaseReferences<_$AppDatabase, $LinksTable, Link> {
  $$LinksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FolderLinksTable, List<FolderLink>>
      _folderLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.folderLinks,
          aliasName: $_aliasNameGenerator(db.links.id, db.folderLinks.linkId));

  $$FolderLinksTableProcessedTableManager get folderLinksRefs {
    final manager = $$FolderLinksTableTableManager($_db, $_db.folderLinks)
        .filter((f) => f.linkId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_folderLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LinksTableFilterComposer
    extends FilterComposer<_$AppDatabase, $LinksTable> {
  $$LinksTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter folderLinksRefs(
      ComposableFilter Function($$FolderLinksTableFilterComposer f) f) {
    final $$FolderLinksTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.folderLinks,
        getReferencedColumn: (t) => t.linkId,
        builder: (joinBuilder, parentComposers) =>
            $$FolderLinksTableFilterComposer(ComposerState($state.db,
                $state.db.folderLinks, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$LinksTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $LinksTable> {
  $$LinksTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$LinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LinksTable,
    Link,
    $$LinksTableFilterComposer,
    $$LinksTableOrderingComposer,
    $$LinksTableCreateCompanionBuilder,
    $$LinksTableUpdateCompanionBuilder,
    (Link, $$LinksTableReferences),
    Link,
    PrefetchHooks Function({bool folderLinksRefs})> {
  $$LinksTableTableManager(_$AppDatabase db, $LinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$LinksTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$LinksTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LinksCompanion(
            id: id,
            url: url,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String url,
            Value<int> rowid = const Value.absent(),
          }) =>
              LinksCompanion.insert(
            id: id,
            url: url,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$LinksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({folderLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (folderLinksRefs) db.folderLinks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (folderLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$LinksTableReferences._folderLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LinksTableReferences(db, table, p0)
                                .folderLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.linkId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LinksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LinksTable,
    Link,
    $$LinksTableFilterComposer,
    $$LinksTableOrderingComposer,
    $$LinksTableCreateCompanionBuilder,
    $$LinksTableUpdateCompanionBuilder,
    (Link, $$LinksTableReferences),
    Link,
    PrefetchHooks Function({bool folderLinksRefs})>;
typedef $$DocumentsTableCreateCompanionBuilder = DocumentsCompanion Function({
  required String id,
  required String title,
  required Uint8List content,
  Value<int> rowid,
});
typedef $$DocumentsTableUpdateCompanionBuilder = DocumentsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<Uint8List> content,
  Value<int> rowid,
});

final class $$DocumentsTableReferences
    extends BaseReferences<_$AppDatabase, $DocumentsTable, Document> {
  $$DocumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FolderDocumentsTable, List<FolderDocument>>
      _folderDocumentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.folderDocuments,
              aliasName: $_aliasNameGenerator(
                  db.documents.id, db.folderDocuments.documentId));

  $$FolderDocumentsTableProcessedTableManager get folderDocumentsRefs {
    final manager =
        $$FolderDocumentsTableTableManager($_db, $_db.folderDocuments)
            .filter((f) => f.documentId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_folderDocumentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DocumentsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<Uint8List> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter folderDocumentsRefs(
      ComposableFilter Function($$FolderDocumentsTableFilterComposer f) f) {
    final $$FolderDocumentsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.folderDocuments,
            getReferencedColumn: (t) => t.documentId,
            builder: (joinBuilder, parentComposers) =>
                $$FolderDocumentsTableFilterComposer(ComposerState($state.db,
                    $state.db.folderDocuments, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$DocumentsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<Uint8List> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$DocumentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DocumentsTable,
    Document,
    $$DocumentsTableFilterComposer,
    $$DocumentsTableOrderingComposer,
    $$DocumentsTableCreateCompanionBuilder,
    $$DocumentsTableUpdateCompanionBuilder,
    (Document, $$DocumentsTableReferences),
    Document,
    PrefetchHooks Function({bool folderDocumentsRefs})> {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DocumentsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DocumentsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<Uint8List> content = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentsCompanion(
            id: id,
            title: title,
            content: content,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required Uint8List content,
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentsCompanion.insert(
            id: id,
            title: title,
            content: content,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DocumentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({folderDocumentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (folderDocumentsRefs) db.folderDocuments
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (folderDocumentsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$DocumentsTableReferences
                            ._folderDocumentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DocumentsTableReferences(db, table, p0)
                                .folderDocumentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.documentId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DocumentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DocumentsTable,
    Document,
    $$DocumentsTableFilterComposer,
    $$DocumentsTableOrderingComposer,
    $$DocumentsTableCreateCompanionBuilder,
    $$DocumentsTableUpdateCompanionBuilder,
    (Document, $$DocumentsTableReferences),
    Document,
    PrefetchHooks Function({bool folderDocumentsRefs})>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> rowid,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FolderTagsTable, List<FolderTag>>
      _folderTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.folderTags,
              aliasName: $_aliasNameGenerator(db.tags.id, db.folderTags.tagId));

  $$FolderTagsTableProcessedTableManager get folderTagsRefs {
    final manager = $$FolderTagsTableTableManager($_db, $_db.folderTags)
        .filter((f) => f.tagId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_folderTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter folderTagsRefs(
      ComposableFilter Function($$FolderTagsTableFilterComposer f) f) {
    final $$FolderTagsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.folderTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder, parentComposers) =>
            $$FolderTagsTableFilterComposer(ComposerState($state.db,
                $state.db.folderTags, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$TagsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool folderTagsRefs})> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TagsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TagsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({folderTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (folderTagsRefs) db.folderTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (folderTagsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TagsTableReferences._folderTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TagsTableReferences(db, table, p0).folderTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tagId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool folderTagsRefs})>;
typedef $$FolderTagsTableCreateCompanionBuilder = FolderTagsCompanion Function({
  required String folderId,
  required String tagId,
  Value<int> rowid,
});
typedef $$FolderTagsTableUpdateCompanionBuilder = FolderTagsCompanion Function({
  Value<String> folderId,
  Value<String> tagId,
  Value<int> rowid,
});

final class $$FolderTagsTableReferences
    extends BaseReferences<_$AppDatabase, $FolderTagsTable, FolderTag> {
  $$FolderTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) => db.folders
      .createAlias($_aliasNameGenerator(db.folderTags.folderId, db.folders.id));

  $$FoldersTableProcessedTableManager? get folderId {
    if ($_item.folderId == null) return null;
    final manager = $$FoldersTableTableManager($_db, $_db.folders)
        .filter((f) => f.id($_item.folderId!));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags
      .createAlias($_aliasNameGenerator(db.folderTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager? get tagId {
    if ($_item.tagId == null) return null;
    final manager = $$TagsTableTableManager($_db, $_db.tags)
        .filter((f) => f.id($_item.tagId!));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FolderTagsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $FolderTagsTable> {
  $$FolderTagsTableFilterComposer(super.$state);
  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.folderId,
        referencedTable: $state.db.folders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$FoldersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.folders, joinBuilder, parentComposers)));
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $state.db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$TagsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.tags, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$FolderTagsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $FolderTagsTable> {
  $$FolderTagsTableOrderingComposer(super.$state);
  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.folderId,
        referencedTable: $state.db.folders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$FoldersTableOrderingComposer(ComposerState(
                $state.db, $state.db.folders, joinBuilder, parentComposers)));
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $state.db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$TagsTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.tags, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$FolderTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FolderTagsTable,
    FolderTag,
    $$FolderTagsTableFilterComposer,
    $$FolderTagsTableOrderingComposer,
    $$FolderTagsTableCreateCompanionBuilder,
    $$FolderTagsTableUpdateCompanionBuilder,
    (FolderTag, $$FolderTagsTableReferences),
    FolderTag,
    PrefetchHooks Function({bool folderId, bool tagId})> {
  $$FolderTagsTableTableManager(_$AppDatabase db, $FolderTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FolderTagsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FolderTagsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> folderId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FolderTagsCompanion(
            folderId: folderId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String folderId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              FolderTagsCompanion.insert(
            folderId: folderId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FolderTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({folderId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (folderId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.folderId,
                    referencedTable:
                        $$FolderTagsTableReferences._folderIdTable(db),
                    referencedColumn:
                        $$FolderTagsTableReferences._folderIdTable(db).id,
                  ) as T;
                }
                if (tagId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagId,
                    referencedTable:
                        $$FolderTagsTableReferences._tagIdTable(db),
                    referencedColumn:
                        $$FolderTagsTableReferences._tagIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FolderTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FolderTagsTable,
    FolderTag,
    $$FolderTagsTableFilterComposer,
    $$FolderTagsTableOrderingComposer,
    $$FolderTagsTableCreateCompanionBuilder,
    $$FolderTagsTableUpdateCompanionBuilder,
    (FolderTag, $$FolderTagsTableReferences),
    FolderTag,
    PrefetchHooks Function({bool folderId, bool tagId})>;
typedef $$FolderDocumentsTableCreateCompanionBuilder = FolderDocumentsCompanion
    Function({
  required String folderId,
  required String documentId,
  Value<int> rowid,
});
typedef $$FolderDocumentsTableUpdateCompanionBuilder = FolderDocumentsCompanion
    Function({
  Value<String> folderId,
  Value<String> documentId,
  Value<int> rowid,
});

final class $$FolderDocumentsTableReferences extends BaseReferences<
    _$AppDatabase, $FolderDocumentsTable, FolderDocument> {
  $$FolderDocumentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) =>
      db.folders.createAlias(
          $_aliasNameGenerator(db.folderDocuments.folderId, db.folders.id));

  $$FoldersTableProcessedTableManager? get folderId {
    if ($_item.folderId == null) return null;
    final manager = $$FoldersTableTableManager($_db, $_db.folders)
        .filter((f) => f.id($_item.folderId!));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias(
          $_aliasNameGenerator(db.folderDocuments.documentId, db.documents.id));

  $$DocumentsTableProcessedTableManager? get documentId {
    if ($_item.documentId == null) return null;
    final manager = $$DocumentsTableTableManager($_db, $_db.documents)
        .filter((f) => f.id($_item.documentId!));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FolderDocumentsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $FolderDocumentsTable> {
  $$FolderDocumentsTableFilterComposer(super.$state);
  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.folderId,
        referencedTable: $state.db.folders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$FoldersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.folders, joinBuilder, parentComposers)));
    return composer;
  }

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.documentId,
        referencedTable: $state.db.documents,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$DocumentsTableFilterComposer(ComposerState(
                $state.db, $state.db.documents, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$FolderDocumentsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $FolderDocumentsTable> {
  $$FolderDocumentsTableOrderingComposer(super.$state);
  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.folderId,
        referencedTable: $state.db.folders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$FoldersTableOrderingComposer(ComposerState(
                $state.db, $state.db.folders, joinBuilder, parentComposers)));
    return composer;
  }

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.documentId,
        referencedTable: $state.db.documents,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$DocumentsTableOrderingComposer(ComposerState(
                $state.db, $state.db.documents, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$FolderDocumentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FolderDocumentsTable,
    FolderDocument,
    $$FolderDocumentsTableFilterComposer,
    $$FolderDocumentsTableOrderingComposer,
    $$FolderDocumentsTableCreateCompanionBuilder,
    $$FolderDocumentsTableUpdateCompanionBuilder,
    (FolderDocument, $$FolderDocumentsTableReferences),
    FolderDocument,
    PrefetchHooks Function({bool folderId, bool documentId})> {
  $$FolderDocumentsTableTableManager(
      _$AppDatabase db, $FolderDocumentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FolderDocumentsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FolderDocumentsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> folderId = const Value.absent(),
            Value<String> documentId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FolderDocumentsCompanion(
            folderId: folderId,
            documentId: documentId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String folderId,
            required String documentId,
            Value<int> rowid = const Value.absent(),
          }) =>
              FolderDocumentsCompanion.insert(
            folderId: folderId,
            documentId: documentId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FolderDocumentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({folderId = false, documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (folderId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.folderId,
                    referencedTable:
                        $$FolderDocumentsTableReferences._folderIdTable(db),
                    referencedColumn:
                        $$FolderDocumentsTableReferences._folderIdTable(db).id,
                  ) as T;
                }
                if (documentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.documentId,
                    referencedTable:
                        $$FolderDocumentsTableReferences._documentIdTable(db),
                    referencedColumn: $$FolderDocumentsTableReferences
                        ._documentIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FolderDocumentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FolderDocumentsTable,
    FolderDocument,
    $$FolderDocumentsTableFilterComposer,
    $$FolderDocumentsTableOrderingComposer,
    $$FolderDocumentsTableCreateCompanionBuilder,
    $$FolderDocumentsTableUpdateCompanionBuilder,
    (FolderDocument, $$FolderDocumentsTableReferences),
    FolderDocument,
    PrefetchHooks Function({bool folderId, bool documentId})>;
typedef $$FolderLinksTableCreateCompanionBuilder = FolderLinksCompanion
    Function({
  required String folderId,
  required String linkId,
  Value<int> rowid,
});
typedef $$FolderLinksTableUpdateCompanionBuilder = FolderLinksCompanion
    Function({
  Value<String> folderId,
  Value<String> linkId,
  Value<int> rowid,
});

final class $$FolderLinksTableReferences
    extends BaseReferences<_$AppDatabase, $FolderLinksTable, FolderLink> {
  $$FolderLinksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) =>
      db.folders.createAlias(
          $_aliasNameGenerator(db.folderLinks.folderId, db.folders.id));

  $$FoldersTableProcessedTableManager? get folderId {
    if ($_item.folderId == null) return null;
    final manager = $$FoldersTableTableManager($_db, $_db.folders)
        .filter((f) => f.id($_item.folderId!));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LinksTable _linkIdTable(_$AppDatabase db) => db.links
      .createAlias($_aliasNameGenerator(db.folderLinks.linkId, db.links.id));

  $$LinksTableProcessedTableManager? get linkId {
    if ($_item.linkId == null) return null;
    final manager = $$LinksTableTableManager($_db, $_db.links)
        .filter((f) => f.id($_item.linkId!));
    final item = $_typedResult.readTableOrNull(_linkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FolderLinksTableFilterComposer
    extends FilterComposer<_$AppDatabase, $FolderLinksTable> {
  $$FolderLinksTableFilterComposer(super.$state);
  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.folderId,
        referencedTable: $state.db.folders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$FoldersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.folders, joinBuilder, parentComposers)));
    return composer;
  }

  $$LinksTableFilterComposer get linkId {
    final $$LinksTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkId,
        referencedTable: $state.db.links,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$LinksTableFilterComposer(
            ComposerState(
                $state.db, $state.db.links, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$FolderLinksTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $FolderLinksTable> {
  $$FolderLinksTableOrderingComposer(super.$state);
  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.folderId,
        referencedTable: $state.db.folders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$FoldersTableOrderingComposer(ComposerState(
                $state.db, $state.db.folders, joinBuilder, parentComposers)));
    return composer;
  }

  $$LinksTableOrderingComposer get linkId {
    final $$LinksTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkId,
        referencedTable: $state.db.links,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$LinksTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.links, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$FolderLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FolderLinksTable,
    FolderLink,
    $$FolderLinksTableFilterComposer,
    $$FolderLinksTableOrderingComposer,
    $$FolderLinksTableCreateCompanionBuilder,
    $$FolderLinksTableUpdateCompanionBuilder,
    (FolderLink, $$FolderLinksTableReferences),
    FolderLink,
    PrefetchHooks Function({bool folderId, bool linkId})> {
  $$FolderLinksTableTableManager(_$AppDatabase db, $FolderLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FolderLinksTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FolderLinksTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> folderId = const Value.absent(),
            Value<String> linkId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FolderLinksCompanion(
            folderId: folderId,
            linkId: linkId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String folderId,
            required String linkId,
            Value<int> rowid = const Value.absent(),
          }) =>
              FolderLinksCompanion.insert(
            folderId: folderId,
            linkId: linkId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FolderLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({folderId = false, linkId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (folderId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.folderId,
                    referencedTable:
                        $$FolderLinksTableReferences._folderIdTable(db),
                    referencedColumn:
                        $$FolderLinksTableReferences._folderIdTable(db).id,
                  ) as T;
                }
                if (linkId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.linkId,
                    referencedTable:
                        $$FolderLinksTableReferences._linkIdTable(db),
                    referencedColumn:
                        $$FolderLinksTableReferences._linkIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FolderLinksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FolderLinksTable,
    FolderLink,
    $$FolderLinksTableFilterComposer,
    $$FolderLinksTableOrderingComposer,
    $$FolderLinksTableCreateCompanionBuilder,
    $$FolderLinksTableUpdateCompanionBuilder,
    (FolderLink, $$FolderLinksTableReferences),
    FolderLink,
    PrefetchHooks Function({bool folderId, bool linkId})>;
typedef $$FolderTreesTableCreateCompanionBuilder = FolderTreesCompanion
    Function({
  required String parentId,
  required String childId,
  Value<int> rowid,
});
typedef $$FolderTreesTableUpdateCompanionBuilder = FolderTreesCompanion
    Function({
  Value<String> parentId,
  Value<String> childId,
  Value<int> rowid,
});

final class $$FolderTreesTableReferences
    extends BaseReferences<_$AppDatabase, $FolderTreesTable, FolderTree> {
  $$FolderTreesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _parentIdTable(_$AppDatabase db) =>
      db.folders.createAlias(
          $_aliasNameGenerator(db.folderTrees.parentId, db.folders.id));

  $$FoldersTableProcessedTableManager? get parentId {
    if ($_item.parentId == null) return null;
    final manager = $$FoldersTableTableManager($_db, $_db.folders)
        .filter((f) => f.id($_item.parentId!));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $FoldersTable _childIdTable(_$AppDatabase db) => db.folders
      .createAlias($_aliasNameGenerator(db.folderTrees.childId, db.folders.id));

  $$FoldersTableProcessedTableManager? get childId {
    if ($_item.childId == null) return null;
    final manager = $$FoldersTableTableManager($_db, $_db.folders)
        .filter((f) => f.id($_item.childId!));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FolderTreesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $FolderTreesTable> {
  $$FolderTreesTableFilterComposer(super.$state);
  $$FoldersTableFilterComposer get parentId {
    final $$FoldersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $state.db.folders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$FoldersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.folders, joinBuilder, parentComposers)));
    return composer;
  }

  $$FoldersTableFilterComposer get childId {
    final $$FoldersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $state.db.folders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$FoldersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.folders, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$FolderTreesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $FolderTreesTable> {
  $$FolderTreesTableOrderingComposer(super.$state);
  $$FoldersTableOrderingComposer get parentId {
    final $$FoldersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $state.db.folders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$FoldersTableOrderingComposer(ComposerState(
                $state.db, $state.db.folders, joinBuilder, parentComposers)));
    return composer;
  }

  $$FoldersTableOrderingComposer get childId {
    final $$FoldersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $state.db.folders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$FoldersTableOrderingComposer(ComposerState(
                $state.db, $state.db.folders, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$FolderTreesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FolderTreesTable,
    FolderTree,
    $$FolderTreesTableFilterComposer,
    $$FolderTreesTableOrderingComposer,
    $$FolderTreesTableCreateCompanionBuilder,
    $$FolderTreesTableUpdateCompanionBuilder,
    (FolderTree, $$FolderTreesTableReferences),
    FolderTree,
    PrefetchHooks Function({bool parentId, bool childId})> {
  $$FolderTreesTableTableManager(_$AppDatabase db, $FolderTreesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FolderTreesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FolderTreesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> parentId = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FolderTreesCompanion(
            parentId: parentId,
            childId: childId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String parentId,
            required String childId,
            Value<int> rowid = const Value.absent(),
          }) =>
              FolderTreesCompanion.insert(
            parentId: parentId,
            childId: childId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FolderTreesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({parentId = false, childId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (parentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentId,
                    referencedTable:
                        $$FolderTreesTableReferences._parentIdTable(db),
                    referencedColumn:
                        $$FolderTreesTableReferences._parentIdTable(db).id,
                  ) as T;
                }
                if (childId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childId,
                    referencedTable:
                        $$FolderTreesTableReferences._childIdTable(db),
                    referencedColumn:
                        $$FolderTreesTableReferences._childIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FolderTreesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FolderTreesTable,
    FolderTree,
    $$FolderTreesTableFilterComposer,
    $$FolderTreesTableOrderingComposer,
    $$FolderTreesTableCreateCompanionBuilder,
    $$FolderTreesTableUpdateCompanionBuilder,
    (FolderTree, $$FolderTreesTableReferences),
    FolderTree,
    PrefetchHooks Function({bool parentId, bool childId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$LinksTableTableManager get links =>
      $$LinksTableTableManager(_db, _db.links);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$FolderTagsTableTableManager get folderTags =>
      $$FolderTagsTableTableManager(_db, _db.folderTags);
  $$FolderDocumentsTableTableManager get folderDocuments =>
      $$FolderDocumentsTableTableManager(_db, _db.folderDocuments);
  $$FolderLinksTableTableManager get folderLinks =>
      $$FolderLinksTableTableManager(_db, _db.folderLinks);
  $$FolderTreesTableTableManager get folderTrees =>
      $$FolderTreesTableTableManager(_db, _db.folderTrees);
}
