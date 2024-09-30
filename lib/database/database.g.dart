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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
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
  List<GeneratedColumn> get $columns => [id, createdAt, title, description];
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
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
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
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
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
  final DateTime createdAt;
  final String title;
  final String description;
  const Folder(
      {required this.id,
      required this.createdAt,
      required this.title,
      required this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      title: Value(title),
      description: Value(description),
    );
  }

  factory Folder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
    };
  }

  Folder copyWith(
          {String? id,
          DateTime? createdAt,
          String? title,
          String? description}) =>
      Folder(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        title: title ?? this.title,
        description: description ?? this.description,
      );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('title: $title, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, title, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.title == this.title &&
          other.description == this.description);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> title;
  final Value<String> description;
  final Value<int> rowid;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoldersCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    required String title,
    required String description,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description);
  static Insertable<Folder> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoldersCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<String>? title,
      Value<String>? description,
      Value<int>? rowid}) {
    return FoldersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
          ..write('createdAt: $createdAt, ')
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 10, maxTextLength: 2048),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _archiveOrgUrlMeta =
      const VerificationMeta('archiveOrgUrl');
  @override
  late final GeneratedColumn<String> archiveOrgUrl = GeneratedColumn<String>(
      'archive_org_url', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 10, maxTextLength: 2048),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _archiveIsUrlMeta =
      const VerificationMeta('archiveIsUrl');
  @override
  late final GeneratedColumn<String> archiveIsUrl = GeneratedColumn<String>(
      'archive_is_url', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 10, maxTextLength: 2048),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _localArchivePathMeta =
      const VerificationMeta('localArchivePath');
  @override
  late final GeneratedColumn<String> localArchivePath = GeneratedColumn<String>(
      'local_archive_path', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 10, maxTextLength: 2048),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, content, archiveOrgUrl, archiveIsUrl, localArchivePath];
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
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('archive_org_url')) {
      context.handle(
          _archiveOrgUrlMeta,
          archiveOrgUrl.isAcceptableOrUnknown(
              data['archive_org_url']!, _archiveOrgUrlMeta));
    }
    if (data.containsKey('archive_is_url')) {
      context.handle(
          _archiveIsUrlMeta,
          archiveIsUrl.isAcceptableOrUnknown(
              data['archive_is_url']!, _archiveIsUrlMeta));
    }
    if (data.containsKey('local_archive_path')) {
      context.handle(
          _localArchivePathMeta,
          localArchivePath.isAcceptableOrUnknown(
              data['local_archive_path']!, _localArchivePathMeta));
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
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      archiveOrgUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}archive_org_url']),
      archiveIsUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}archive_is_url']),
      localArchivePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_archive_path']),
    );
  }

  @override
  $LinksTable createAlias(String alias) {
    return $LinksTable(attachedDatabase, alias);
  }
}

class Link extends DataClass implements Insertable<Link> {
  final String id;
  final DateTime createdAt;
  final String content;
  final String? archiveOrgUrl;
  final String? archiveIsUrl;
  final String? localArchivePath;
  const Link(
      {required this.id,
      required this.createdAt,
      required this.content,
      this.archiveOrgUrl,
      this.archiveIsUrl,
      this.localArchivePath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || archiveOrgUrl != null) {
      map['archive_org_url'] = Variable<String>(archiveOrgUrl);
    }
    if (!nullToAbsent || archiveIsUrl != null) {
      map['archive_is_url'] = Variable<String>(archiveIsUrl);
    }
    if (!nullToAbsent || localArchivePath != null) {
      map['local_archive_path'] = Variable<String>(localArchivePath);
    }
    return map;
  }

  LinksCompanion toCompanion(bool nullToAbsent) {
    return LinksCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      content: Value(content),
      archiveOrgUrl: archiveOrgUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(archiveOrgUrl),
      archiveIsUrl: archiveIsUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(archiveIsUrl),
      localArchivePath: localArchivePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localArchivePath),
    );
  }

  factory Link.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Link(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      content: serializer.fromJson<String>(json['content']),
      archiveOrgUrl: serializer.fromJson<String?>(json['archiveOrgUrl']),
      archiveIsUrl: serializer.fromJson<String?>(json['archiveIsUrl']),
      localArchivePath: serializer.fromJson<String?>(json['localArchivePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'content': serializer.toJson<String>(content),
      'archiveOrgUrl': serializer.toJson<String?>(archiveOrgUrl),
      'archiveIsUrl': serializer.toJson<String?>(archiveIsUrl),
      'localArchivePath': serializer.toJson<String?>(localArchivePath),
    };
  }

  Link copyWith(
          {String? id,
          DateTime? createdAt,
          String? content,
          Value<String?> archiveOrgUrl = const Value.absent(),
          Value<String?> archiveIsUrl = const Value.absent(),
          Value<String?> localArchivePath = const Value.absent()}) =>
      Link(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        content: content ?? this.content,
        archiveOrgUrl:
            archiveOrgUrl.present ? archiveOrgUrl.value : this.archiveOrgUrl,
        archiveIsUrl:
            archiveIsUrl.present ? archiveIsUrl.value : this.archiveIsUrl,
        localArchivePath: localArchivePath.present
            ? localArchivePath.value
            : this.localArchivePath,
      );
  Link copyWithCompanion(LinksCompanion data) {
    return Link(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      content: data.content.present ? data.content.value : this.content,
      archiveOrgUrl: data.archiveOrgUrl.present
          ? data.archiveOrgUrl.value
          : this.archiveOrgUrl,
      archiveIsUrl: data.archiveIsUrl.present
          ? data.archiveIsUrl.value
          : this.archiveIsUrl,
      localArchivePath: data.localArchivePath.present
          ? data.localArchivePath.value
          : this.localArchivePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Link(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('content: $content, ')
          ..write('archiveOrgUrl: $archiveOrgUrl, ')
          ..write('archiveIsUrl: $archiveIsUrl, ')
          ..write('localArchivePath: $localArchivePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, createdAt, content, archiveOrgUrl, archiveIsUrl, localArchivePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Link &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.content == this.content &&
          other.archiveOrgUrl == this.archiveOrgUrl &&
          other.archiveIsUrl == this.archiveIsUrl &&
          other.localArchivePath == this.localArchivePath);
}

class LinksCompanion extends UpdateCompanion<Link> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> content;
  final Value<String?> archiveOrgUrl;
  final Value<String?> archiveIsUrl;
  final Value<String?> localArchivePath;
  final Value<int> rowid;
  const LinksCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.content = const Value.absent(),
    this.archiveOrgUrl = const Value.absent(),
    this.archiveIsUrl = const Value.absent(),
    this.localArchivePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinksCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    required String content,
    this.archiveOrgUrl = const Value.absent(),
    this.archiveIsUrl = const Value.absent(),
    this.localArchivePath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        content = Value(content);
  static Insertable<Link> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? content,
    Expression<String>? archiveOrgUrl,
    Expression<String>? archiveIsUrl,
    Expression<String>? localArchivePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (content != null) 'content': content,
      if (archiveOrgUrl != null) 'archive_org_url': archiveOrgUrl,
      if (archiveIsUrl != null) 'archive_is_url': archiveIsUrl,
      if (localArchivePath != null) 'local_archive_path': localArchivePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinksCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<String>? content,
      Value<String?>? archiveOrgUrl,
      Value<String?>? archiveIsUrl,
      Value<String?>? localArchivePath,
      Value<int>? rowid}) {
    return LinksCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      archiveOrgUrl: archiveOrgUrl ?? this.archiveOrgUrl,
      archiveIsUrl: archiveIsUrl ?? this.archiveIsUrl,
      localArchivePath: localArchivePath ?? this.localArchivePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (archiveOrgUrl.present) {
      map['archive_org_url'] = Variable<String>(archiveOrgUrl.value);
    }
    if (archiveIsUrl.present) {
      map['archive_is_url'] = Variable<String>(archiveIsUrl.value);
    }
    if (localArchivePath.present) {
      map['local_archive_path'] = Variable<String>(localArchivePath.value);
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
          ..write('createdAt: $createdAt, ')
          ..write('content: $content, ')
          ..write('archiveOrgUrl: $archiveOrgUrl, ')
          ..write('archiveIsUrl: $archiveIsUrl, ')
          ..write('localArchivePath: $localArchivePath, ')
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
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
  List<GeneratedColumn> get $columns => [id, createdAt, title, content];
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
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
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
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
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
  final DateTime createdAt;
  final String title;
  final Uint8List content;
  const Document(
      {required this.id,
      required this.createdAt,
      required this.title,
      required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<Uint8List>(content);
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      title: Value(title),
      content: Value(content),
    );
  }

  factory Document.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Document(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<Uint8List>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<Uint8List>(content),
    };
  }

  Document copyWith(
          {String? id,
          DateTime? createdAt,
          String? title,
          Uint8List? content}) =>
      Document(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        title: title ?? this.title,
        content: content ?? this.content,
      );
  Document copyWithCompanion(DocumentsCompanion data) {
    return Document(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Document(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('title: $title, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, title, $driftBlobEquality.hash(content));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Document &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.title == this.title &&
          $driftBlobEquality.equals(other.content, this.content));
}

class DocumentsCompanion extends UpdateCompanion<Document> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> title;
  final Value<Uint8List> content;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    required String title,
    required Uint8List content,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        content = Value(content);
  static Insertable<Document> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? title,
    Expression<Uint8List>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<String>? title,
      Value<Uint8List>? content,
      Value<int>? rowid}) {
    return DocumentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
          ..write('createdAt: $createdAt, ')
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
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
  List<GeneratedColumn> get $columns => [id, createdAt, name];
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
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
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
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
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
  final DateTime createdAt;
  final String name;
  const Tag({required this.id, required this.createdAt, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      name: Value(name),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'name': serializer.toJson<String>(name),
    };
  }

  Tag copyWith({String? id, DateTime? createdAt, String? name}) => Tag(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> name;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<String>? name,
      Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemTypesTable extends ItemTypes
    with TableInfo<$ItemTypesTable, ItemType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_types';
  @override
  VerificationContext validateIntegrity(Insertable<ItemType> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
  ItemType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemType(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $ItemTypesTable createAlias(String alias) {
    return $ItemTypesTable(attachedDatabase, alias);
  }
}

class ItemType extends DataClass implements Insertable<ItemType> {
  final int id;
  final String name;
  const ItemType({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ItemTypesCompanion toCompanion(bool nullToAbsent) {
    return ItemTypesCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory ItemType.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  ItemType copyWith({int? id, String? name}) => ItemType(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  ItemType copyWithCompanion(ItemTypesCompanion data) {
    return ItemType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemType(')
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
      (other is ItemType && other.id == this.id && other.name == this.name);
}

class ItemTypesCompanion extends UpdateCompanion<ItemType> {
  final Value<int> id;
  final Value<String> name;
  const ItemTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  ItemTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<ItemType> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  ItemTypesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return ItemTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 30, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
      'folder_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES folders (id)'));
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<int> typeId = GeneratedColumn<int>(
      'type_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES item_types (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, folderId, itemId, typeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(Insertable<Item> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('type_id')) {
      context.handle(_typeIdMeta,
          typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta));
    } else if (isInserting) {
      context.missing(_typeIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}folder_id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      typeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type_id'])!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final String id;
  final DateTime createdAt;
  final String folderId;
  final String itemId;
  final int typeId;
  const Item(
      {required this.id,
      required this.createdAt,
      required this.folderId,
      required this.itemId,
      required this.typeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['folder_id'] = Variable<String>(folderId);
    map['item_id'] = Variable<String>(itemId);
    map['type_id'] = Variable<int>(typeId);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      folderId: Value(folderId),
      itemId: Value(itemId),
      typeId: Value(typeId),
    );
  }

  factory Item.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      folderId: serializer.fromJson<String>(json['folderId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      typeId: serializer.fromJson<int>(json['typeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'folderId': serializer.toJson<String>(folderId),
      'itemId': serializer.toJson<String>(itemId),
      'typeId': serializer.toJson<int>(typeId),
    };
  }

  Item copyWith(
          {String? id,
          DateTime? createdAt,
          String? folderId,
          String? itemId,
          int? typeId}) =>
      Item(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        folderId: folderId ?? this.folderId,
        itemId: itemId ?? this.itemId,
        typeId: typeId ?? this.typeId,
      );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      typeId: data.typeId.present ? data.typeId.value : this.typeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('folderId: $folderId, ')
          ..write('itemId: $itemId, ')
          ..write('typeId: $typeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, folderId, itemId, typeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.folderId == this.folderId &&
          other.itemId == this.itemId &&
          other.typeId == this.typeId);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> folderId;
  final Value<String> itemId;
  final Value<int> typeId;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.folderId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.typeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    required String folderId,
    required String itemId,
    required int typeId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        folderId = Value(folderId),
        itemId = Value(itemId),
        typeId = Value(typeId);
  static Insertable<Item> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? folderId,
    Expression<String>? itemId,
    Expression<int>? typeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (folderId != null) 'folder_id': folderId,
      if (itemId != null) 'item_id': itemId,
      if (typeId != null) 'type_id': typeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<String>? folderId,
      Value<String>? itemId,
      Value<int>? typeId,
      Value<int>? rowid}) {
    return ItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      folderId: folderId ?? this.folderId,
      itemId: itemId ?? this.itemId,
      typeId: typeId ?? this.typeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (typeId.present) {
      map['type_id'] = Variable<int>(typeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('folderId: $folderId, ')
          ..write('itemId: $itemId, ')
          ..write('typeId: $typeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetadataTypesTable extends MetadataTypes
    with TableInfo<$MetadataTypesTable, MetadataType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetadataTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metadata_types';
  @override
  VerificationContext validateIntegrity(Insertable<MetadataType> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
  MetadataType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetadataType(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $MetadataTypesTable createAlias(String alias) {
    return $MetadataTypesTable(attachedDatabase, alias);
  }
}

class MetadataType extends DataClass implements Insertable<MetadataType> {
  final int id;
  final String name;
  const MetadataType({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  MetadataTypesCompanion toCompanion(bool nullToAbsent) {
    return MetadataTypesCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory MetadataType.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetadataType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  MetadataType copyWith({int? id, String? name}) => MetadataType(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  MetadataType copyWithCompanion(MetadataTypesCompanion data) {
    return MetadataType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetadataType(')
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
      (other is MetadataType && other.id == this.id && other.name == this.name);
}

class MetadataTypesCompanion extends UpdateCompanion<MetadataType> {
  final Value<int> id;
  final Value<String> name;
  const MetadataTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  MetadataTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<MetadataType> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  MetadataTypesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return MetadataTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetadataTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $MetadataRecordsTable extends MetadataRecords
    with TableInfo<$MetadataRecordsTable, MetadataRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetadataRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 30, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<int> typeId = GeneratedColumn<int>(
      'type_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES metadata_types (id)'));
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metadataIdMeta =
      const VerificationMeta('metadataId');
  @override
  late final GeneratedColumn<String> metadataId = GeneratedColumn<String>(
      'metadata_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, typeId, itemId, metadataId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metadata_records';
  @override
  VerificationContext validateIntegrity(Insertable<MetadataRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('type_id')) {
      context.handle(_typeIdMeta,
          typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta));
    } else if (isInserting) {
      context.missing(_typeIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('metadata_id')) {
      context.handle(
          _metadataIdMeta,
          metadataId.isAcceptableOrUnknown(
              data['metadata_id']!, _metadataIdMeta));
    } else if (isInserting) {
      context.missing(_metadataIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetadataRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetadataRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      typeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type_id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      metadataId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_id'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value']),
    );
  }

  @override
  $MetadataRecordsTable createAlias(String alias) {
    return $MetadataRecordsTable(attachedDatabase, alias);
  }
}

class MetadataRecord extends DataClass implements Insertable<MetadataRecord> {
  final String id;
  final DateTime createdAt;
  final int typeId;
  final String itemId;
  final String metadataId;
  final String? value;
  const MetadataRecord(
      {required this.id,
      required this.createdAt,
      required this.typeId,
      required this.itemId,
      required this.metadataId,
      this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['type_id'] = Variable<int>(typeId);
    map['item_id'] = Variable<String>(itemId);
    map['metadata_id'] = Variable<String>(metadataId);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  MetadataRecordsCompanion toCompanion(bool nullToAbsent) {
    return MetadataRecordsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      typeId: Value(typeId),
      itemId: Value(itemId),
      metadataId: Value(metadataId),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
    );
  }

  factory MetadataRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetadataRecord(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      typeId: serializer.fromJson<int>(json['typeId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      metadataId: serializer.fromJson<String>(json['metadataId']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'typeId': serializer.toJson<int>(typeId),
      'itemId': serializer.toJson<String>(itemId),
      'metadataId': serializer.toJson<String>(metadataId),
      'value': serializer.toJson<String?>(value),
    };
  }

  MetadataRecord copyWith(
          {String? id,
          DateTime? createdAt,
          int? typeId,
          String? itemId,
          String? metadataId,
          Value<String?> value = const Value.absent()}) =>
      MetadataRecord(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        typeId: typeId ?? this.typeId,
        itemId: itemId ?? this.itemId,
        metadataId: metadataId ?? this.metadataId,
        value: value.present ? value.value : this.value,
      );
  MetadataRecord copyWithCompanion(MetadataRecordsCompanion data) {
    return MetadataRecord(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      typeId: data.typeId.present ? data.typeId.value : this.typeId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      metadataId:
          data.metadataId.present ? data.metadataId.value : this.metadataId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetadataRecord(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('typeId: $typeId, ')
          ..write('itemId: $itemId, ')
          ..write('metadataId: $metadataId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, typeId, itemId, metadataId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetadataRecord &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.typeId == this.typeId &&
          other.itemId == this.itemId &&
          other.metadataId == this.metadataId &&
          other.value == this.value);
}

class MetadataRecordsCompanion extends UpdateCompanion<MetadataRecord> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<int> typeId;
  final Value<String> itemId;
  final Value<String> metadataId;
  final Value<String?> value;
  final Value<int> rowid;
  const MetadataRecordsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.typeId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.metadataId = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetadataRecordsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    required int typeId,
    required String itemId,
    required String metadataId,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        typeId = Value(typeId),
        itemId = Value(itemId),
        metadataId = Value(metadataId);
  static Insertable<MetadataRecord> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<int>? typeId,
    Expression<String>? itemId,
    Expression<String>? metadataId,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (typeId != null) 'type_id': typeId,
      if (itemId != null) 'item_id': itemId,
      if (metadataId != null) 'metadata_id': metadataId,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetadataRecordsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<int>? typeId,
      Value<String>? itemId,
      Value<String>? metadataId,
      Value<String?>? value,
      Value<int>? rowid}) {
    return MetadataRecordsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      typeId: typeId ?? this.typeId,
      itemId: itemId ?? this.itemId,
      metadataId: metadataId ?? this.metadataId,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (typeId.present) {
      map['type_id'] = Variable<int>(typeId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (metadataId.present) {
      map['metadata_id'] = Variable<String>(metadataId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetadataRecordsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('typeId: $typeId, ')
          ..write('itemId: $itemId, ')
          ..write('metadataId: $metadataId, ')
          ..write('value: $value, ')
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
  late final $ItemTypesTable itemTypes = $ItemTypesTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $MetadataTypesTable metadataTypes = $MetadataTypesTable(this);
  late final $MetadataRecordsTable metadataRecords =
      $MetadataRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        folders,
        links,
        documents,
        tags,
        itemTypes,
        items,
        metadataTypes,
        metadataRecords
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$FoldersTableCreateCompanionBuilder = FoldersCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  required String title,
  required String description,
  Value<int> rowid,
});
typedef $$FoldersTableUpdateCompanionBuilder = FoldersCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<String> title,
  Value<String> description,
  Value<int> rowid,
});

final class $$FoldersTableReferences
    extends BaseReferences<_$AppDatabase, $FoldersTable, Folder> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemsTable, List<Item>> _itemsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.items,
          aliasName: $_aliasNameGenerator(db.folders.id, db.items.folderId));

  $$ItemsTableProcessedTableManager get itemsRefs {
    final manager = $$ItemsTableTableManager($_db, $_db.items)
        .filter((f) => f.folderId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_itemsRefsTable($_db));
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

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
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

  ComposableFilter itemsRefs(
      ComposableFilter Function($$ItemsTableFilterComposer f) f) {
    final $$ItemsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.items,
        getReferencedColumn: (t) => t.folderId,
        builder: (joinBuilder, parentComposers) => $$ItemsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.items, joinBuilder, parentComposers)));
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

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
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
    PrefetchHooks Function({bool itemsRefs})> {
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FoldersCompanion(
            id: id,
            createdAt: createdAt,
            title: title,
            description: description,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            required String title,
            required String description,
            Value<int> rowid = const Value.absent(),
          }) =>
              FoldersCompanion.insert(
            id: id,
            createdAt: createdAt,
            title: title,
            description: description,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$FoldersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({itemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemsRefs) db.items],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$FoldersTableReferences._itemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FoldersTableReferences(db, table, p0).itemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.folderId == item.id),
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
    PrefetchHooks Function({bool itemsRefs})>;
typedef $$LinksTableCreateCompanionBuilder = LinksCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  required String content,
  Value<String?> archiveOrgUrl,
  Value<String?> archiveIsUrl,
  Value<String?> localArchivePath,
  Value<int> rowid,
});
typedef $$LinksTableUpdateCompanionBuilder = LinksCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<String> content,
  Value<String?> archiveOrgUrl,
  Value<String?> archiveIsUrl,
  Value<String?> localArchivePath,
  Value<int> rowid,
});

class $$LinksTableFilterComposer
    extends FilterComposer<_$AppDatabase, $LinksTable> {
  $$LinksTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get archiveOrgUrl => $state.composableBuilder(
      column: $state.table.archiveOrgUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get archiveIsUrl => $state.composableBuilder(
      column: $state.table.archiveIsUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get localArchivePath => $state.composableBuilder(
      column: $state.table.localArchivePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$LinksTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $LinksTable> {
  $$LinksTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get archiveOrgUrl => $state.composableBuilder(
      column: $state.table.archiveOrgUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get archiveIsUrl => $state.composableBuilder(
      column: $state.table.archiveIsUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get localArchivePath => $state.composableBuilder(
      column: $state.table.localArchivePath,
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
    (Link, BaseReferences<_$AppDatabase, $LinksTable, Link>),
    Link,
    PrefetchHooks Function()> {
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> archiveOrgUrl = const Value.absent(),
            Value<String?> archiveIsUrl = const Value.absent(),
            Value<String?> localArchivePath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LinksCompanion(
            id: id,
            createdAt: createdAt,
            content: content,
            archiveOrgUrl: archiveOrgUrl,
            archiveIsUrl: archiveIsUrl,
            localArchivePath: localArchivePath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            required String content,
            Value<String?> archiveOrgUrl = const Value.absent(),
            Value<String?> archiveIsUrl = const Value.absent(),
            Value<String?> localArchivePath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LinksCompanion.insert(
            id: id,
            createdAt: createdAt,
            content: content,
            archiveOrgUrl: archiveOrgUrl,
            archiveIsUrl: archiveIsUrl,
            localArchivePath: localArchivePath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
    (Link, BaseReferences<_$AppDatabase, $LinksTable, Link>),
    Link,
    PrefetchHooks Function()>;
typedef $$DocumentsTableCreateCompanionBuilder = DocumentsCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  required String title,
  required Uint8List content,
  Value<int> rowid,
});
typedef $$DocumentsTableUpdateCompanionBuilder = DocumentsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<String> title,
  Value<Uint8List> content,
  Value<int> rowid,
});

class $$DocumentsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
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
}

class $$DocumentsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
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
    (Document, BaseReferences<_$AppDatabase, $DocumentsTable, Document>),
    Document,
    PrefetchHooks Function()> {
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<Uint8List> content = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentsCompanion(
            id: id,
            createdAt: createdAt,
            title: title,
            content: content,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            required String title,
            required Uint8List content,
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentsCompanion.insert(
            id: id,
            createdAt: createdAt,
            title: title,
            content: content,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
    (Document, BaseReferences<_$AppDatabase, $DocumentsTable, Document>),
    Document,
    PrefetchHooks Function()>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  required String name,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<String> name,
  Value<int> rowid,
});

class $$TagsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$TagsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
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
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()> {
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            createdAt: createdAt,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            createdAt: createdAt,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()>;
typedef $$ItemTypesTableCreateCompanionBuilder = ItemTypesCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$ItemTypesTableUpdateCompanionBuilder = ItemTypesCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$ItemTypesTableReferences
    extends BaseReferences<_$AppDatabase, $ItemTypesTable, ItemType> {
  $$ItemTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemsTable, List<Item>> _itemsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.items,
          aliasName: $_aliasNameGenerator(db.itemTypes.id, db.items.typeId));

  $$ItemsTableProcessedTableManager get itemsRefs {
    final manager = $$ItemsTableTableManager($_db, $_db.items)
        .filter((f) => f.typeId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_itemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ItemTypesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ItemTypesTable> {
  $$ItemTypesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter itemsRefs(
      ComposableFilter Function($$ItemsTableFilterComposer f) f) {
    final $$ItemsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.items,
        getReferencedColumn: (t) => t.typeId,
        builder: (joinBuilder, parentComposers) => $$ItemsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.items, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ItemTypesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ItemTypesTable> {
  $$ItemTypesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$ItemTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemTypesTable,
    ItemType,
    $$ItemTypesTableFilterComposer,
    $$ItemTypesTableOrderingComposer,
    $$ItemTypesTableCreateCompanionBuilder,
    $$ItemTypesTableUpdateCompanionBuilder,
    (ItemType, $$ItemTypesTableReferences),
    ItemType,
    PrefetchHooks Function({bool itemsRefs})> {
  $$ItemTypesTableTableManager(_$AppDatabase db, $ItemTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ItemTypesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ItemTypesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              ItemTypesCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              ItemTypesCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ItemTypesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({itemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemsRefs) db.items],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ItemTypesTableReferences._itemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ItemTypesTableReferences(db, table, p0).itemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.typeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ItemTypesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemTypesTable,
    ItemType,
    $$ItemTypesTableFilterComposer,
    $$ItemTypesTableOrderingComposer,
    $$ItemTypesTableCreateCompanionBuilder,
    $$ItemTypesTableUpdateCompanionBuilder,
    (ItemType, $$ItemTypesTableReferences),
    ItemType,
    PrefetchHooks Function({bool itemsRefs})>;
typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  required String folderId,
  required String itemId,
  required int typeId,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<String> folderId,
  Value<String> itemId,
  Value<int> typeId,
  Value<int> rowid,
});

final class $$ItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemsTable, Item> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) => db.folders
      .createAlias($_aliasNameGenerator(db.items.folderId, db.folders.id));

  $$FoldersTableProcessedTableManager? get folderId {
    if ($_item.folderId == null) return null;
    final manager = $$FoldersTableTableManager($_db, $_db.folders)
        .filter((f) => f.id($_item.folderId!));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ItemTypesTable _typeIdTable(_$AppDatabase db) => db.itemTypes
      .createAlias($_aliasNameGenerator(db.items.typeId, db.itemTypes.id));

  $$ItemTypesTableProcessedTableManager? get typeId {
    if ($_item.typeId == null) return null;
    final manager = $$ItemTypesTableTableManager($_db, $_db.itemTypes)
        .filter((f) => f.id($_item.typeId!));
    final item = $_typedResult.readTableOrNull(_typeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get itemId => $state.composableBuilder(
      column: $state.table.itemId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

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

  $$ItemTypesTableFilterComposer get typeId {
    final $$ItemTypesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeId,
        referencedTable: $state.db.itemTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ItemTypesTableFilterComposer(ComposerState(
                $state.db, $state.db.itemTypes, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get itemId => $state.composableBuilder(
      column: $state.table.itemId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

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

  $$ItemTypesTableOrderingComposer get typeId {
    final $$ItemTypesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeId,
        referencedTable: $state.db.itemTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ItemTypesTableOrderingComposer(ComposerState(
                $state.db, $state.db.itemTypes, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (Item, $$ItemsTableReferences),
    Item,
    PrefetchHooks Function({bool folderId, bool typeId})> {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> folderId = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<int> typeId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion(
            id: id,
            createdAt: createdAt,
            folderId: folderId,
            itemId: itemId,
            typeId: typeId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            required String folderId,
            required String itemId,
            required int typeId,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion.insert(
            id: id,
            createdAt: createdAt,
            folderId: folderId,
            itemId: itemId,
            typeId: typeId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ItemsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({folderId = false, typeId = false}) {
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
                    referencedTable: $$ItemsTableReferences._folderIdTable(db),
                    referencedColumn:
                        $$ItemsTableReferences._folderIdTable(db).id,
                  ) as T;
                }
                if (typeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.typeId,
                    referencedTable: $$ItemsTableReferences._typeIdTable(db),
                    referencedColumn:
                        $$ItemsTableReferences._typeIdTable(db).id,
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

typedef $$ItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (Item, $$ItemsTableReferences),
    Item,
    PrefetchHooks Function({bool folderId, bool typeId})>;
typedef $$MetadataTypesTableCreateCompanionBuilder = MetadataTypesCompanion
    Function({
  Value<int> id,
  required String name,
});
typedef $$MetadataTypesTableUpdateCompanionBuilder = MetadataTypesCompanion
    Function({
  Value<int> id,
  Value<String> name,
});

final class $$MetadataTypesTableReferences
    extends BaseReferences<_$AppDatabase, $MetadataTypesTable, MetadataType> {
  $$MetadataTypesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MetadataRecordsTable, List<MetadataRecord>>
      _metadataRecordsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.metadataRecords,
              aliasName: $_aliasNameGenerator(
                  db.metadataTypes.id, db.metadataRecords.typeId));

  $$MetadataRecordsTableProcessedTableManager get metadataRecordsRefs {
    final manager =
        $$MetadataRecordsTableTableManager($_db, $_db.metadataRecords)
            .filter((f) => f.typeId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_metadataRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MetadataTypesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MetadataTypesTable> {
  $$MetadataTypesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter metadataRecordsRefs(
      ComposableFilter Function($$MetadataRecordsTableFilterComposer f) f) {
    final $$MetadataRecordsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.metadataRecords,
            getReferencedColumn: (t) => t.typeId,
            builder: (joinBuilder, parentComposers) =>
                $$MetadataRecordsTableFilterComposer(ComposerState($state.db,
                    $state.db.metadataRecords, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$MetadataTypesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MetadataTypesTable> {
  $$MetadataTypesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$MetadataTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MetadataTypesTable,
    MetadataType,
    $$MetadataTypesTableFilterComposer,
    $$MetadataTypesTableOrderingComposer,
    $$MetadataTypesTableCreateCompanionBuilder,
    $$MetadataTypesTableUpdateCompanionBuilder,
    (MetadataType, $$MetadataTypesTableReferences),
    MetadataType,
    PrefetchHooks Function({bool metadataRecordsRefs})> {
  $$MetadataTypesTableTableManager(_$AppDatabase db, $MetadataTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MetadataTypesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MetadataTypesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              MetadataTypesCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              MetadataTypesCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MetadataTypesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({metadataRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (metadataRecordsRefs) db.metadataRecords
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (metadataRecordsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$MetadataTypesTableReferences
                            ._metadataRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MetadataTypesTableReferences(db, table, p0)
                                .metadataRecordsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.typeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MetadataTypesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MetadataTypesTable,
    MetadataType,
    $$MetadataTypesTableFilterComposer,
    $$MetadataTypesTableOrderingComposer,
    $$MetadataTypesTableCreateCompanionBuilder,
    $$MetadataTypesTableUpdateCompanionBuilder,
    (MetadataType, $$MetadataTypesTableReferences),
    MetadataType,
    PrefetchHooks Function({bool metadataRecordsRefs})>;
typedef $$MetadataRecordsTableCreateCompanionBuilder = MetadataRecordsCompanion
    Function({
  required String id,
  Value<DateTime> createdAt,
  required int typeId,
  required String itemId,
  required String metadataId,
  Value<String?> value,
  Value<int> rowid,
});
typedef $$MetadataRecordsTableUpdateCompanionBuilder = MetadataRecordsCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<int> typeId,
  Value<String> itemId,
  Value<String> metadataId,
  Value<String?> value,
  Value<int> rowid,
});

final class $$MetadataRecordsTableReferences extends BaseReferences<
    _$AppDatabase, $MetadataRecordsTable, MetadataRecord> {
  $$MetadataRecordsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MetadataTypesTable _typeIdTable(_$AppDatabase db) =>
      db.metadataTypes.createAlias(
          $_aliasNameGenerator(db.metadataRecords.typeId, db.metadataTypes.id));

  $$MetadataTypesTableProcessedTableManager? get typeId {
    if ($_item.typeId == null) return null;
    final manager = $$MetadataTypesTableTableManager($_db, $_db.metadataTypes)
        .filter((f) => f.id($_item.typeId!));
    final item = $_typedResult.readTableOrNull(_typeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MetadataRecordsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MetadataRecordsTable> {
  $$MetadataRecordsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get itemId => $state.composableBuilder(
      column: $state.table.itemId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get metadataId => $state.composableBuilder(
      column: $state.table.metadataId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$MetadataTypesTableFilterComposer get typeId {
    final $$MetadataTypesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeId,
        referencedTable: $state.db.metadataTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$MetadataTypesTableFilterComposer(ComposerState($state.db,
                $state.db.metadataTypes, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$MetadataRecordsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MetadataRecordsTable> {
  $$MetadataRecordsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get itemId => $state.composableBuilder(
      column: $state.table.itemId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get metadataId => $state.composableBuilder(
      column: $state.table.metadataId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$MetadataTypesTableOrderingComposer get typeId {
    final $$MetadataTypesTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.typeId,
            referencedTable: $state.db.metadataTypes,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$MetadataTypesTableOrderingComposer(ComposerState($state.db,
                    $state.db.metadataTypes, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$MetadataRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MetadataRecordsTable,
    MetadataRecord,
    $$MetadataRecordsTableFilterComposer,
    $$MetadataRecordsTableOrderingComposer,
    $$MetadataRecordsTableCreateCompanionBuilder,
    $$MetadataRecordsTableUpdateCompanionBuilder,
    (MetadataRecord, $$MetadataRecordsTableReferences),
    MetadataRecord,
    PrefetchHooks Function({bool typeId})> {
  $$MetadataRecordsTableTableManager(
      _$AppDatabase db, $MetadataRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MetadataRecordsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MetadataRecordsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> typeId = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> metadataId = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MetadataRecordsCompanion(
            id: id,
            createdAt: createdAt,
            typeId: typeId,
            itemId: itemId,
            metadataId: metadataId,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            required int typeId,
            required String itemId,
            required String metadataId,
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MetadataRecordsCompanion.insert(
            id: id,
            createdAt: createdAt,
            typeId: typeId,
            itemId: itemId,
            metadataId: metadataId,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MetadataRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({typeId = false}) {
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
                if (typeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.typeId,
                    referencedTable:
                        $$MetadataRecordsTableReferences._typeIdTable(db),
                    referencedColumn:
                        $$MetadataRecordsTableReferences._typeIdTable(db).id,
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

typedef $$MetadataRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MetadataRecordsTable,
    MetadataRecord,
    $$MetadataRecordsTableFilterComposer,
    $$MetadataRecordsTableOrderingComposer,
    $$MetadataRecordsTableCreateCompanionBuilder,
    $$MetadataRecordsTableUpdateCompanionBuilder,
    (MetadataRecord, $$MetadataRecordsTableReferences),
    MetadataRecord,
    PrefetchHooks Function({bool typeId})>;

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
  $$ItemTypesTableTableManager get itemTypes =>
      $$ItemTypesTableTableManager(_db, _db.itemTypes);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$MetadataTypesTableTableManager get metadataTypes =>
      $$MetadataTypesTableTableManager(_db, _db.metadataTypes);
  $$MetadataRecordsTableTableManager get metadataRecords =>
      $$MetadataRecordsTableTableManager(_db, _db.metadataRecords);
}

class $UserConfigsTable extends UserConfigs
    with TableInfo<$UserConfigsTable, UserConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 30, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _darkModeMeta =
      const VerificationMeta('darkMode');
  @override
  late final GeneratedColumn<bool> darkMode = GeneratedColumn<bool>(
      'dark_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dark_mode" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _colorSchemeMeta =
      const VerificationMeta('colorScheme');
  @override
  late final GeneratedColumn<String> colorScheme = GeneratedColumn<String>(
      'color_scheme', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _archiveOrgS3AccessKeyMeta =
      const VerificationMeta('archiveOrgS3AccessKey');
  @override
  late final GeneratedColumn<String> archiveOrgS3AccessKey =
      GeneratedColumn<String>('archive_org_s3_access_key', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _archiveOrgS3SecretKeyMeta =
      const VerificationMeta('archiveOrgS3SecretKey');
  @override
  late final GeneratedColumn<String> archiveOrgS3SecretKey =
      GeneratedColumn<String>('archive_org_s3_secret_key', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, darkMode, colorScheme, archiveOrgS3AccessKey, archiveOrgS3SecretKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_configs';
  @override
  VerificationContext validateIntegrity(Insertable<UserConfig> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dark_mode')) {
      context.handle(_darkModeMeta,
          darkMode.isAcceptableOrUnknown(data['dark_mode']!, _darkModeMeta));
    }
    if (data.containsKey('color_scheme')) {
      context.handle(
          _colorSchemeMeta,
          colorScheme.isAcceptableOrUnknown(
              data['color_scheme']!, _colorSchemeMeta));
    }
    if (data.containsKey('archive_org_s3_access_key')) {
      context.handle(
          _archiveOrgS3AccessKeyMeta,
          archiveOrgS3AccessKey.isAcceptableOrUnknown(
              data['archive_org_s3_access_key']!, _archiveOrgS3AccessKeyMeta));
    }
    if (data.containsKey('archive_org_s3_secret_key')) {
      context.handle(
          _archiveOrgS3SecretKeyMeta,
          archiveOrgS3SecretKey.isAcceptableOrUnknown(
              data['archive_org_s3_secret_key']!, _archiveOrgS3SecretKeyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  UserConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserConfig(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      darkMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dark_mode'])!,
      colorScheme: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_scheme']),
      archiveOrgS3AccessKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}archive_org_s3_access_key']),
      archiveOrgS3SecretKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}archive_org_s3_secret_key']),
    );
  }

  @override
  $UserConfigsTable createAlias(String alias) {
    return $UserConfigsTable(attachedDatabase, alias);
  }
}

class UserConfig extends DataClass implements Insertable<UserConfig> {
  final String id;
  final bool darkMode;
  final String? colorScheme;
  final String? archiveOrgS3AccessKey;
  final String? archiveOrgS3SecretKey;
  const UserConfig(
      {required this.id,
      required this.darkMode,
      this.colorScheme,
      this.archiveOrgS3AccessKey,
      this.archiveOrgS3SecretKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dark_mode'] = Variable<bool>(darkMode);
    if (!nullToAbsent || colorScheme != null) {
      map['color_scheme'] = Variable<String>(colorScheme);
    }
    if (!nullToAbsent || archiveOrgS3AccessKey != null) {
      map['archive_org_s3_access_key'] =
          Variable<String>(archiveOrgS3AccessKey);
    }
    if (!nullToAbsent || archiveOrgS3SecretKey != null) {
      map['archive_org_s3_secret_key'] =
          Variable<String>(archiveOrgS3SecretKey);
    }
    return map;
  }

  UserConfigsCompanion toCompanion(bool nullToAbsent) {
    return UserConfigsCompanion(
      id: Value(id),
      darkMode: Value(darkMode),
      colorScheme: colorScheme == null && nullToAbsent
          ? const Value.absent()
          : Value(colorScheme),
      archiveOrgS3AccessKey: archiveOrgS3AccessKey == null && nullToAbsent
          ? const Value.absent()
          : Value(archiveOrgS3AccessKey),
      archiveOrgS3SecretKey: archiveOrgS3SecretKey == null && nullToAbsent
          ? const Value.absent()
          : Value(archiveOrgS3SecretKey),
    );
  }

  factory UserConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserConfig(
      id: serializer.fromJson<String>(json['id']),
      darkMode: serializer.fromJson<bool>(json['darkMode']),
      colorScheme: serializer.fromJson<String?>(json['colorScheme']),
      archiveOrgS3AccessKey:
          serializer.fromJson<String?>(json['archiveOrgS3AccessKey']),
      archiveOrgS3SecretKey:
          serializer.fromJson<String?>(json['archiveOrgS3SecretKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'darkMode': serializer.toJson<bool>(darkMode),
      'colorScheme': serializer.toJson<String?>(colorScheme),
      'archiveOrgS3AccessKey':
          serializer.toJson<String?>(archiveOrgS3AccessKey),
      'archiveOrgS3SecretKey':
          serializer.toJson<String?>(archiveOrgS3SecretKey),
    };
  }

  UserConfig copyWith(
          {String? id,
          bool? darkMode,
          Value<String?> colorScheme = const Value.absent(),
          Value<String?> archiveOrgS3AccessKey = const Value.absent(),
          Value<String?> archiveOrgS3SecretKey = const Value.absent()}) =>
      UserConfig(
        id: id ?? this.id,
        darkMode: darkMode ?? this.darkMode,
        colorScheme: colorScheme.present ? colorScheme.value : this.colorScheme,
        archiveOrgS3AccessKey: archiveOrgS3AccessKey.present
            ? archiveOrgS3AccessKey.value
            : this.archiveOrgS3AccessKey,
        archiveOrgS3SecretKey: archiveOrgS3SecretKey.present
            ? archiveOrgS3SecretKey.value
            : this.archiveOrgS3SecretKey,
      );
  UserConfig copyWithCompanion(UserConfigsCompanion data) {
    return UserConfig(
      id: data.id.present ? data.id.value : this.id,
      darkMode: data.darkMode.present ? data.darkMode.value : this.darkMode,
      colorScheme:
          data.colorScheme.present ? data.colorScheme.value : this.colorScheme,
      archiveOrgS3AccessKey: data.archiveOrgS3AccessKey.present
          ? data.archiveOrgS3AccessKey.value
          : this.archiveOrgS3AccessKey,
      archiveOrgS3SecretKey: data.archiveOrgS3SecretKey.present
          ? data.archiveOrgS3SecretKey.value
          : this.archiveOrgS3SecretKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserConfig(')
          ..write('id: $id, ')
          ..write('darkMode: $darkMode, ')
          ..write('colorScheme: $colorScheme, ')
          ..write('archiveOrgS3AccessKey: $archiveOrgS3AccessKey, ')
          ..write('archiveOrgS3SecretKey: $archiveOrgS3SecretKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, darkMode, colorScheme, archiveOrgS3AccessKey, archiveOrgS3SecretKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserConfig &&
          other.id == this.id &&
          other.darkMode == this.darkMode &&
          other.colorScheme == this.colorScheme &&
          other.archiveOrgS3AccessKey == this.archiveOrgS3AccessKey &&
          other.archiveOrgS3SecretKey == this.archiveOrgS3SecretKey);
}

class UserConfigsCompanion extends UpdateCompanion<UserConfig> {
  final Value<String> id;
  final Value<bool> darkMode;
  final Value<String?> colorScheme;
  final Value<String?> archiveOrgS3AccessKey;
  final Value<String?> archiveOrgS3SecretKey;
  final Value<int> rowid;
  const UserConfigsCompanion({
    this.id = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.colorScheme = const Value.absent(),
    this.archiveOrgS3AccessKey = const Value.absent(),
    this.archiveOrgS3SecretKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserConfigsCompanion.insert({
    required String id,
    this.darkMode = const Value.absent(),
    this.colorScheme = const Value.absent(),
    this.archiveOrgS3AccessKey = const Value.absent(),
    this.archiveOrgS3SecretKey = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<UserConfig> custom({
    Expression<String>? id,
    Expression<bool>? darkMode,
    Expression<String>? colorScheme,
    Expression<String>? archiveOrgS3AccessKey,
    Expression<String>? archiveOrgS3SecretKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (darkMode != null) 'dark_mode': darkMode,
      if (colorScheme != null) 'color_scheme': colorScheme,
      if (archiveOrgS3AccessKey != null)
        'archive_org_s3_access_key': archiveOrgS3AccessKey,
      if (archiveOrgS3SecretKey != null)
        'archive_org_s3_secret_key': archiveOrgS3SecretKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserConfigsCompanion copyWith(
      {Value<String>? id,
      Value<bool>? darkMode,
      Value<String?>? colorScheme,
      Value<String?>? archiveOrgS3AccessKey,
      Value<String?>? archiveOrgS3SecretKey,
      Value<int>? rowid}) {
    return UserConfigsCompanion(
      id: id ?? this.id,
      darkMode: darkMode ?? this.darkMode,
      colorScheme: colorScheme ?? this.colorScheme,
      archiveOrgS3AccessKey:
          archiveOrgS3AccessKey ?? this.archiveOrgS3AccessKey,
      archiveOrgS3SecretKey:
          archiveOrgS3SecretKey ?? this.archiveOrgS3SecretKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (darkMode.present) {
      map['dark_mode'] = Variable<bool>(darkMode.value);
    }
    if (colorScheme.present) {
      map['color_scheme'] = Variable<String>(colorScheme.value);
    }
    if (archiveOrgS3AccessKey.present) {
      map['archive_org_s3_access_key'] =
          Variable<String>(archiveOrgS3AccessKey.value);
    }
    if (archiveOrgS3SecretKey.present) {
      map['archive_org_s3_secret_key'] =
          Variable<String>(archiveOrgS3SecretKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserConfigsCompanion(')
          ..write('id: $id, ')
          ..write('darkMode: $darkMode, ')
          ..write('colorScheme: $colorScheme, ')
          ..write('archiveOrgS3AccessKey: $archiveOrgS3AccessKey, ')
          ..write('archiveOrgS3SecretKey: $archiveOrgS3SecretKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ConfigDatabase extends GeneratedDatabase {
  _$ConfigDatabase(QueryExecutor e) : super(e);
  $ConfigDatabaseManager get managers => $ConfigDatabaseManager(this);
  late final $UserConfigsTable userConfigs = $UserConfigsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [userConfigs];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$UserConfigsTableCreateCompanionBuilder = UserConfigsCompanion
    Function({
  required String id,
  Value<bool> darkMode,
  Value<String?> colorScheme,
  Value<String?> archiveOrgS3AccessKey,
  Value<String?> archiveOrgS3SecretKey,
  Value<int> rowid,
});
typedef $$UserConfigsTableUpdateCompanionBuilder = UserConfigsCompanion
    Function({
  Value<String> id,
  Value<bool> darkMode,
  Value<String?> colorScheme,
  Value<String?> archiveOrgS3AccessKey,
  Value<String?> archiveOrgS3SecretKey,
  Value<int> rowid,
});

class $$UserConfigsTableFilterComposer
    extends FilterComposer<_$ConfigDatabase, $UserConfigsTable> {
  $$UserConfigsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get darkMode => $state.composableBuilder(
      column: $state.table.darkMode,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get colorScheme => $state.composableBuilder(
      column: $state.table.colorScheme,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get archiveOrgS3AccessKey => $state.composableBuilder(
      column: $state.table.archiveOrgS3AccessKey,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get archiveOrgS3SecretKey => $state.composableBuilder(
      column: $state.table.archiveOrgS3SecretKey,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$UserConfigsTableOrderingComposer
    extends OrderingComposer<_$ConfigDatabase, $UserConfigsTable> {
  $$UserConfigsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get darkMode => $state.composableBuilder(
      column: $state.table.darkMode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get colorScheme => $state.composableBuilder(
      column: $state.table.colorScheme,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get archiveOrgS3AccessKey => $state.composableBuilder(
      column: $state.table.archiveOrgS3AccessKey,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get archiveOrgS3SecretKey => $state.composableBuilder(
      column: $state.table.archiveOrgS3SecretKey,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$UserConfigsTableTableManager extends RootTableManager<
    _$ConfigDatabase,
    $UserConfigsTable,
    UserConfig,
    $$UserConfigsTableFilterComposer,
    $$UserConfigsTableOrderingComposer,
    $$UserConfigsTableCreateCompanionBuilder,
    $$UserConfigsTableUpdateCompanionBuilder,
    (
      UserConfig,
      BaseReferences<_$ConfigDatabase, $UserConfigsTable, UserConfig>
    ),
    UserConfig,
    PrefetchHooks Function()> {
  $$UserConfigsTableTableManager(_$ConfigDatabase db, $UserConfigsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UserConfigsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UserConfigsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<bool> darkMode = const Value.absent(),
            Value<String?> colorScheme = const Value.absent(),
            Value<String?> archiveOrgS3AccessKey = const Value.absent(),
            Value<String?> archiveOrgS3SecretKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserConfigsCompanion(
            id: id,
            darkMode: darkMode,
            colorScheme: colorScheme,
            archiveOrgS3AccessKey: archiveOrgS3AccessKey,
            archiveOrgS3SecretKey: archiveOrgS3SecretKey,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<bool> darkMode = const Value.absent(),
            Value<String?> colorScheme = const Value.absent(),
            Value<String?> archiveOrgS3AccessKey = const Value.absent(),
            Value<String?> archiveOrgS3SecretKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserConfigsCompanion.insert(
            id: id,
            darkMode: darkMode,
            colorScheme: colorScheme,
            archiveOrgS3AccessKey: archiveOrgS3AccessKey,
            archiveOrgS3SecretKey: archiveOrgS3SecretKey,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserConfigsTableProcessedTableManager = ProcessedTableManager<
    _$ConfigDatabase,
    $UserConfigsTable,
    UserConfig,
    $$UserConfigsTableFilterComposer,
    $$UserConfigsTableOrderingComposer,
    $$UserConfigsTableCreateCompanionBuilder,
    $$UserConfigsTableUpdateCompanionBuilder,
    (
      UserConfig,
      BaseReferences<_$ConfigDatabase, $UserConfigsTable, UserConfig>
    ),
    UserConfig,
    PrefetchHooks Function()>;

class $ConfigDatabaseManager {
  final _$ConfigDatabase _db;
  $ConfigDatabaseManager(this._db);
  $$UserConfigsTableTableManager get userConfigs =>
      $$UserConfigsTableTableManager(_db, _db.userConfigs);
}
