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
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
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
      [id, createdAt, path, archiveOrgUrl, archiveIsUrl, localArchivePath];
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
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
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
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
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
  final String path;
  final String? archiveOrgUrl;
  final String? archiveIsUrl;
  final String? localArchivePath;
  const Link(
      {required this.id,
      required this.createdAt,
      required this.path,
      this.archiveOrgUrl,
      this.archiveIsUrl,
      this.localArchivePath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['path'] = Variable<String>(path);
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
      path: Value(path),
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
      path: serializer.fromJson<String>(json['path']),
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
      'path': serializer.toJson<String>(path),
      'archiveOrgUrl': serializer.toJson<String?>(archiveOrgUrl),
      'archiveIsUrl': serializer.toJson<String?>(archiveIsUrl),
      'localArchivePath': serializer.toJson<String?>(localArchivePath),
    };
  }

  Link copyWith(
          {String? id,
          DateTime? createdAt,
          String? path,
          Value<String?> archiveOrgUrl = const Value.absent(),
          Value<String?> archiveIsUrl = const Value.absent(),
          Value<String?> localArchivePath = const Value.absent()}) =>
      Link(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        path: path ?? this.path,
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
      path: data.path.present ? data.path.value : this.path,
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
          ..write('path: $path, ')
          ..write('archiveOrgUrl: $archiveOrgUrl, ')
          ..write('archiveIsUrl: $archiveIsUrl, ')
          ..write('localArchivePath: $localArchivePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, createdAt, path, archiveOrgUrl, archiveIsUrl, localArchivePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Link &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.path == this.path &&
          other.archiveOrgUrl == this.archiveOrgUrl &&
          other.archiveIsUrl == this.archiveIsUrl &&
          other.localArchivePath == this.localArchivePath);
}

class LinksCompanion extends UpdateCompanion<Link> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> path;
  final Value<String?> archiveOrgUrl;
  final Value<String?> archiveIsUrl;
  final Value<String?> localArchivePath;
  final Value<int> rowid;
  const LinksCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.path = const Value.absent(),
    this.archiveOrgUrl = const Value.absent(),
    this.archiveIsUrl = const Value.absent(),
    this.localArchivePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinksCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    required String path,
    this.archiveOrgUrl = const Value.absent(),
    this.archiveIsUrl = const Value.absent(),
    this.localArchivePath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        path = Value(path);
  static Insertable<Link> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? path,
    Expression<String>? archiveOrgUrl,
    Expression<String>? archiveIsUrl,
    Expression<String>? localArchivePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (path != null) 'path': path,
      if (archiveOrgUrl != null) 'archive_org_url': archiveOrgUrl,
      if (archiveIsUrl != null) 'archive_is_url': archiveIsUrl,
      if (localArchivePath != null) 'local_archive_path': localArchivePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinksCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<String>? path,
      Value<String?>? archiveOrgUrl,
      Value<String?>? archiveIsUrl,
      Value<String?>? localArchivePath,
      Value<int>? rowid}) {
    return LinksCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      path: path ?? this.path,
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
    if (path.present) {
      map['path'] = Variable<String>(path.value);
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
          ..write('path: $path, ')
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
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, title, path];
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
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
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
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
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
  final String path;
  const Document(
      {required this.id,
      required this.createdAt,
      required this.title,
      required this.path});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['title'] = Variable<String>(title);
    map['path'] = Variable<String>(path);
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      title: Value(title),
      path: Value(path),
    );
  }

  factory Document.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Document(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      title: serializer.fromJson<String>(json['title']),
      path: serializer.fromJson<String>(json['path']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'title': serializer.toJson<String>(title),
      'path': serializer.toJson<String>(path),
    };
  }

  Document copyWith(
          {String? id, DateTime? createdAt, String? title, String? path}) =>
      Document(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        title: title ?? this.title,
        path: path ?? this.path,
      );
  Document copyWithCompanion(DocumentsCompanion data) {
    return Document(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      title: data.title.present ? data.title.value : this.title,
      path: data.path.present ? data.path.value : this.path,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Document(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('title: $title, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, title, path);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Document &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.title == this.title &&
          other.path == this.path);
}

class DocumentsCompanion extends UpdateCompanion<Document> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> title;
  final Value<String> path;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.title = const Value.absent(),
    this.path = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    required String title,
    required String path,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        path = Value(path);
  static Insertable<Document> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? title,
    Expression<String>? path,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (title != null) 'title': title,
      if (path != null) 'path': path,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<String>? title,
      Value<String>? path,
      Value<int>? rowid}) {
    return DocumentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      path: path ?? this.path,
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
    if (path.present) {
      map['path'] = Variable<String>(path.value);
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
          ..write('path: $path, ')
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
  late final Index folderTitle =
      Index('folder_title', 'CREATE INDEX folder_title ON folders (title)');
  late final Index documentTitle = Index(
      'document_title', 'CREATE INDEX document_title ON documents (title)');
  late final Index itemsFolderItemIdx = Index('items_folder_item_idx',
      'CREATE INDEX items_folder_item_idx ON items (folder_id, item_id)');
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
        metadataRecords,
        folderTitle,
        documentTitle,
        itemsFolderItemIdx
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
        .filter((f) => f.folderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  Expression<bool> itemsRefs(
      Expression<bool> Function($$ItemsTableFilterComposer f) f) {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.folderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableFilterComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  Expression<T> itemsRefs<T extends Object>(
      Expression<T> Function($$ItemsTableAnnotationComposer a) f) {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.folderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FoldersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FoldersTable,
    Folder,
    $$FoldersTableFilterComposer,
    $$FoldersTableOrderingComposer,
    $$FoldersTableAnnotationComposer,
    $$FoldersTableCreateCompanionBuilder,
    $$FoldersTableUpdateCompanionBuilder,
    (Folder, $$FoldersTableReferences),
    Folder,
    PrefetchHooks Function({bool itemsRefs})> {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
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
                    await $_getPrefetchedData<Folder, $FoldersTable, Item>(
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
    $$FoldersTableAnnotationComposer,
    $$FoldersTableCreateCompanionBuilder,
    $$FoldersTableUpdateCompanionBuilder,
    (Folder, $$FoldersTableReferences),
    Folder,
    PrefetchHooks Function({bool itemsRefs})>;
typedef $$LinksTableCreateCompanionBuilder = LinksCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  required String path,
  Value<String?> archiveOrgUrl,
  Value<String?> archiveIsUrl,
  Value<String?> localArchivePath,
  Value<int> rowid,
});
typedef $$LinksTableUpdateCompanionBuilder = LinksCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<String> path,
  Value<String?> archiveOrgUrl,
  Value<String?> archiveIsUrl,
  Value<String?> localArchivePath,
  Value<int> rowid,
});

class $$LinksTableFilterComposer extends Composer<_$AppDatabase, $LinksTable> {
  $$LinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get archiveOrgUrl => $composableBuilder(
      column: $table.archiveOrgUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get archiveIsUrl => $composableBuilder(
      column: $table.archiveIsUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localArchivePath => $composableBuilder(
      column: $table.localArchivePath,
      builder: (column) => ColumnFilters(column));
}

class $$LinksTableOrderingComposer
    extends Composer<_$AppDatabase, $LinksTable> {
  $$LinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get archiveOrgUrl => $composableBuilder(
      column: $table.archiveOrgUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get archiveIsUrl => $composableBuilder(
      column: $table.archiveIsUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localArchivePath => $composableBuilder(
      column: $table.localArchivePath,
      builder: (column) => ColumnOrderings(column));
}

class $$LinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LinksTable> {
  $$LinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get archiveOrgUrl => $composableBuilder(
      column: $table.archiveOrgUrl, builder: (column) => column);

  GeneratedColumn<String> get archiveIsUrl => $composableBuilder(
      column: $table.archiveIsUrl, builder: (column) => column);

  GeneratedColumn<String> get localArchivePath => $composableBuilder(
      column: $table.localArchivePath, builder: (column) => column);
}

class $$LinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LinksTable,
    Link,
    $$LinksTableFilterComposer,
    $$LinksTableOrderingComposer,
    $$LinksTableAnnotationComposer,
    $$LinksTableCreateCompanionBuilder,
    $$LinksTableUpdateCompanionBuilder,
    (Link, BaseReferences<_$AppDatabase, $LinksTable, Link>),
    Link,
    PrefetchHooks Function()> {
  $$LinksTableTableManager(_$AppDatabase db, $LinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<String?> archiveOrgUrl = const Value.absent(),
            Value<String?> archiveIsUrl = const Value.absent(),
            Value<String?> localArchivePath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LinksCompanion(
            id: id,
            createdAt: createdAt,
            path: path,
            archiveOrgUrl: archiveOrgUrl,
            archiveIsUrl: archiveIsUrl,
            localArchivePath: localArchivePath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            required String path,
            Value<String?> archiveOrgUrl = const Value.absent(),
            Value<String?> archiveIsUrl = const Value.absent(),
            Value<String?> localArchivePath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LinksCompanion.insert(
            id: id,
            createdAt: createdAt,
            path: path,
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
    $$LinksTableAnnotationComposer,
    $$LinksTableCreateCompanionBuilder,
    $$LinksTableUpdateCompanionBuilder,
    (Link, BaseReferences<_$AppDatabase, $LinksTable, Link>),
    Link,
    PrefetchHooks Function()>;
typedef $$DocumentsTableCreateCompanionBuilder = DocumentsCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  required String title,
  required String path,
  Value<int> rowid,
});
typedef $$DocumentsTableUpdateCompanionBuilder = DocumentsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<String> title,
  Value<String> path,
  Value<int> rowid,
});

class $$DocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);
}

class $$DocumentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DocumentsTable,
    Document,
    $$DocumentsTableFilterComposer,
    $$DocumentsTableOrderingComposer,
    $$DocumentsTableAnnotationComposer,
    $$DocumentsTableCreateCompanionBuilder,
    $$DocumentsTableUpdateCompanionBuilder,
    (Document, BaseReferences<_$AppDatabase, $DocumentsTable, Document>),
    Document,
    PrefetchHooks Function()> {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentsCompanion(
            id: id,
            createdAt: createdAt,
            title: title,
            path: path,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            required String title,
            required String path,
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentsCompanion.insert(
            id: id,
            createdAt: createdAt,
            title: title,
            path: path,
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
    $$DocumentsTableAnnotationComposer,
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

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
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
    $$TagsTableAnnotationComposer,
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
        .filter((f) => f.typeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ItemTypesTableFilterComposer
    extends Composer<_$AppDatabase, $ItemTypesTable> {
  $$ItemTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> itemsRefs(
      Expression<bool> Function($$ItemsTableFilterComposer f) f) {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.typeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableFilterComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ItemTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemTypesTable> {
  $$ItemTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$ItemTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemTypesTable> {
  $$ItemTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> itemsRefs<T extends Object>(
      Expression<T> Function($$ItemsTableAnnotationComposer a) f) {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.typeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ItemTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemTypesTable,
    ItemType,
    $$ItemTypesTableFilterComposer,
    $$ItemTypesTableOrderingComposer,
    $$ItemTypesTableAnnotationComposer,
    $$ItemTypesTableCreateCompanionBuilder,
    $$ItemTypesTableUpdateCompanionBuilder,
    (ItemType, $$ItemTypesTableReferences),
    ItemType,
    PrefetchHooks Function({bool itemsRefs})> {
  $$ItemTypesTableTableManager(_$AppDatabase db, $ItemTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemTypesTableAnnotationComposer($db: db, $table: table),
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
                    await $_getPrefetchedData<ItemType, $ItemTypesTable, Item>(
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
    $$ItemTypesTableAnnotationComposer,
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

  $$FoldersTableProcessedTableManager get folderId {
    final $_column = $_itemColumn<String>('folder_id')!;

    final manager = $$FoldersTableTableManager($_db, $_db.folders)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ItemTypesTable _typeIdTable(_$AppDatabase db) => db.itemTypes
      .createAlias($_aliasNameGenerator(db.items.typeId, db.itemTypes.id));

  $$ItemTypesTableProcessedTableManager get typeId {
    final $_column = $_itemColumn<int>('type_id')!;

    final manager = $$ItemTypesTableTableManager($_db, $_db.itemTypes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_typeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.folderId,
        referencedTable: $db.folders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FoldersTableFilterComposer(
              $db: $db,
              $table: $db.folders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ItemTypesTableFilterComposer get typeId {
    final $$ItemTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeId,
        referencedTable: $db.itemTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemTypesTableFilterComposer(
              $db: $db,
              $table: $db.itemTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.folderId,
        referencedTable: $db.folders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FoldersTableOrderingComposer(
              $db: $db,
              $table: $db.folders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ItemTypesTableOrderingComposer get typeId {
    final $$ItemTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeId,
        referencedTable: $db.itemTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemTypesTableOrderingComposer(
              $db: $db,
              $table: $db.itemTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.folderId,
        referencedTable: $db.folders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FoldersTableAnnotationComposer(
              $db: $db,
              $table: $db.folders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ItemTypesTableAnnotationComposer get typeId {
    final $$ItemTypesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeId,
        referencedTable: $db.itemTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemTypesTableAnnotationComposer(
              $db: $db,
              $table: $db.itemTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableAnnotationComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (Item, $$ItemsTableReferences),
    Item,
    PrefetchHooks Function({bool folderId, bool typeId})> {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
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
    $$ItemsTableAnnotationComposer,
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
            .filter((f) => f.typeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_metadataRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MetadataTypesTableFilterComposer
    extends Composer<_$AppDatabase, $MetadataTypesTable> {
  $$MetadataTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> metadataRecordsRefs(
      Expression<bool> Function($$MetadataRecordsTableFilterComposer f) f) {
    final $$MetadataRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.metadataRecords,
        getReferencedColumn: (t) => t.typeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetadataRecordsTableFilterComposer(
              $db: $db,
              $table: $db.metadataRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MetadataTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $MetadataTypesTable> {
  $$MetadataTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$MetadataTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetadataTypesTable> {
  $$MetadataTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> metadataRecordsRefs<T extends Object>(
      Expression<T> Function($$MetadataRecordsTableAnnotationComposer a) f) {
    final $$MetadataRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.metadataRecords,
        getReferencedColumn: (t) => t.typeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetadataRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.metadataRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MetadataTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MetadataTypesTable,
    MetadataType,
    $$MetadataTypesTableFilterComposer,
    $$MetadataTypesTableOrderingComposer,
    $$MetadataTypesTableAnnotationComposer,
    $$MetadataTypesTableCreateCompanionBuilder,
    $$MetadataTypesTableUpdateCompanionBuilder,
    (MetadataType, $$MetadataTypesTableReferences),
    MetadataType,
    PrefetchHooks Function({bool metadataRecordsRefs})> {
  $$MetadataTypesTableTableManager(_$AppDatabase db, $MetadataTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetadataTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetadataTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetadataTypesTableAnnotationComposer($db: db, $table: table),
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
                    await $_getPrefetchedData<MetadataType, $MetadataTypesTable, MetadataRecord>(
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
    $$MetadataTypesTableAnnotationComposer,
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

  $$MetadataTypesTableProcessedTableManager get typeId {
    final $_column = $_itemColumn<int>('type_id')!;

    final manager = $$MetadataTypesTableTableManager($_db, $_db.metadataTypes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_typeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MetadataRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MetadataRecordsTable> {
  $$MetadataRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataId => $composableBuilder(
      column: $table.metadataId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  $$MetadataTypesTableFilterComposer get typeId {
    final $$MetadataTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeId,
        referencedTable: $db.metadataTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetadataTypesTableFilterComposer(
              $db: $db,
              $table: $db.metadataTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MetadataRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MetadataRecordsTable> {
  $$MetadataRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataId => $composableBuilder(
      column: $table.metadataId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  $$MetadataTypesTableOrderingComposer get typeId {
    final $$MetadataTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeId,
        referencedTable: $db.metadataTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetadataTypesTableOrderingComposer(
              $db: $db,
              $table: $db.metadataTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MetadataRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetadataRecordsTable> {
  $$MetadataRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get metadataId => $composableBuilder(
      column: $table.metadataId, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$MetadataTypesTableAnnotationComposer get typeId {
    final $$MetadataTypesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeId,
        referencedTable: $db.metadataTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetadataTypesTableAnnotationComposer(
              $db: $db,
              $table: $db.metadataTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MetadataRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MetadataRecordsTable,
    MetadataRecord,
    $$MetadataRecordsTableFilterComposer,
    $$MetadataRecordsTableOrderingComposer,
    $$MetadataRecordsTableAnnotationComposer,
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
          createFilteringComposer: () =>
              $$MetadataRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetadataRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetadataRecordsTableAnnotationComposer($db: db, $table: table),
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
    $$MetadataRecordsTableAnnotationComposer,
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
  static const VerificationMeta _copyOnImportMeta =
      const VerificationMeta('copyOnImport');
  @override
  late final GeneratedColumn<bool> copyOnImport = GeneratedColumn<bool>(
      'copy_on_import', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("copy_on_import" IN (0, 1))'),
      defaultValue: const Constant(true));
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
  static const VerificationMeta _archiveEnabledMeta =
      const VerificationMeta('archiveEnabled');
  @override
  late final GeneratedColumn<bool> archiveEnabled = GeneratedColumn<bool>(
      'archive_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("archive_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _colorSchemeMeta =
      const VerificationMeta('colorScheme');
  @override
  late final GeneratedColumn<String> colorScheme = GeneratedColumn<String>(
      'color_scheme', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        darkMode,
        copyOnImport,
        archiveOrgS3AccessKey,
        archiveOrgS3SecretKey,
        archiveEnabled,
        colorScheme
      ];
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
    if (data.containsKey('copy_on_import')) {
      context.handle(
          _copyOnImportMeta,
          copyOnImport.isAcceptableOrUnknown(
              data['copy_on_import']!, _copyOnImportMeta));
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
    if (data.containsKey('archive_enabled')) {
      context.handle(
          _archiveEnabledMeta,
          archiveEnabled.isAcceptableOrUnknown(
              data['archive_enabled']!, _archiveEnabledMeta));
    }
    if (data.containsKey('color_scheme')) {
      context.handle(
          _colorSchemeMeta,
          colorScheme.isAcceptableOrUnknown(
              data['color_scheme']!, _colorSchemeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserConfig(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      darkMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dark_mode'])!,
      copyOnImport: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}copy_on_import'])!,
      archiveOrgS3AccessKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}archive_org_s3_access_key']),
      archiveOrgS3SecretKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}archive_org_s3_secret_key']),
      archiveEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}archive_enabled'])!,
      colorScheme: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_scheme']),
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
  final bool copyOnImport;
  final String? archiveOrgS3AccessKey;
  final String? archiveOrgS3SecretKey;
  final bool archiveEnabled;
  final String? colorScheme;
  const UserConfig(
      {required this.id,
      required this.darkMode,
      required this.copyOnImport,
      this.archiveOrgS3AccessKey,
      this.archiveOrgS3SecretKey,
      required this.archiveEnabled,
      this.colorScheme});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dark_mode'] = Variable<bool>(darkMode);
    map['copy_on_import'] = Variable<bool>(copyOnImport);
    if (!nullToAbsent || archiveOrgS3AccessKey != null) {
      map['archive_org_s3_access_key'] =
          Variable<String>(archiveOrgS3AccessKey);
    }
    if (!nullToAbsent || archiveOrgS3SecretKey != null) {
      map['archive_org_s3_secret_key'] =
          Variable<String>(archiveOrgS3SecretKey);
    }
    map['archive_enabled'] = Variable<bool>(archiveEnabled);
    if (!nullToAbsent || colorScheme != null) {
      map['color_scheme'] = Variable<String>(colorScheme);
    }
    return map;
  }

  UserConfigsCompanion toCompanion(bool nullToAbsent) {
    return UserConfigsCompanion(
      id: Value(id),
      darkMode: Value(darkMode),
      copyOnImport: Value(copyOnImport),
      archiveOrgS3AccessKey: archiveOrgS3AccessKey == null && nullToAbsent
          ? const Value.absent()
          : Value(archiveOrgS3AccessKey),
      archiveOrgS3SecretKey: archiveOrgS3SecretKey == null && nullToAbsent
          ? const Value.absent()
          : Value(archiveOrgS3SecretKey),
      archiveEnabled: Value(archiveEnabled),
      colorScheme: colorScheme == null && nullToAbsent
          ? const Value.absent()
          : Value(colorScheme),
    );
  }

  factory UserConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserConfig(
      id: serializer.fromJson<String>(json['id']),
      darkMode: serializer.fromJson<bool>(json['darkMode']),
      copyOnImport: serializer.fromJson<bool>(json['copyOnImport']),
      archiveOrgS3AccessKey:
          serializer.fromJson<String?>(json['archiveOrgS3AccessKey']),
      archiveOrgS3SecretKey:
          serializer.fromJson<String?>(json['archiveOrgS3SecretKey']),
      archiveEnabled: serializer.fromJson<bool>(json['archiveEnabled']),
      colorScheme: serializer.fromJson<String?>(json['colorScheme']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'darkMode': serializer.toJson<bool>(darkMode),
      'copyOnImport': serializer.toJson<bool>(copyOnImport),
      'archiveOrgS3AccessKey':
          serializer.toJson<String?>(archiveOrgS3AccessKey),
      'archiveOrgS3SecretKey':
          serializer.toJson<String?>(archiveOrgS3SecretKey),
      'archiveEnabled': serializer.toJson<bool>(archiveEnabled),
      'colorScheme': serializer.toJson<String?>(colorScheme),
    };
  }

  UserConfig copyWith(
          {String? id,
          bool? darkMode,
          bool? copyOnImport,
          Value<String?> archiveOrgS3AccessKey = const Value.absent(),
          Value<String?> archiveOrgS3SecretKey = const Value.absent(),
          bool? archiveEnabled,
          Value<String?> colorScheme = const Value.absent()}) =>
      UserConfig(
        id: id ?? this.id,
        darkMode: darkMode ?? this.darkMode,
        copyOnImport: copyOnImport ?? this.copyOnImport,
        archiveOrgS3AccessKey: archiveOrgS3AccessKey.present
            ? archiveOrgS3AccessKey.value
            : this.archiveOrgS3AccessKey,
        archiveOrgS3SecretKey: archiveOrgS3SecretKey.present
            ? archiveOrgS3SecretKey.value
            : this.archiveOrgS3SecretKey,
        archiveEnabled: archiveEnabled ?? this.archiveEnabled,
        colorScheme: colorScheme.present ? colorScheme.value : this.colorScheme,
      );
  UserConfig copyWithCompanion(UserConfigsCompanion data) {
    return UserConfig(
      id: data.id.present ? data.id.value : this.id,
      darkMode: data.darkMode.present ? data.darkMode.value : this.darkMode,
      copyOnImport: data.copyOnImport.present
          ? data.copyOnImport.value
          : this.copyOnImport,
      archiveOrgS3AccessKey: data.archiveOrgS3AccessKey.present
          ? data.archiveOrgS3AccessKey.value
          : this.archiveOrgS3AccessKey,
      archiveOrgS3SecretKey: data.archiveOrgS3SecretKey.present
          ? data.archiveOrgS3SecretKey.value
          : this.archiveOrgS3SecretKey,
      archiveEnabled: data.archiveEnabled.present
          ? data.archiveEnabled.value
          : this.archiveEnabled,
      colorScheme:
          data.colorScheme.present ? data.colorScheme.value : this.colorScheme,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserConfig(')
          ..write('id: $id, ')
          ..write('darkMode: $darkMode, ')
          ..write('copyOnImport: $copyOnImport, ')
          ..write('archiveOrgS3AccessKey: $archiveOrgS3AccessKey, ')
          ..write('archiveOrgS3SecretKey: $archiveOrgS3SecretKey, ')
          ..write('archiveEnabled: $archiveEnabled, ')
          ..write('colorScheme: $colorScheme')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      darkMode,
      copyOnImport,
      archiveOrgS3AccessKey,
      archiveOrgS3SecretKey,
      archiveEnabled,
      colorScheme);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserConfig &&
          other.id == this.id &&
          other.darkMode == this.darkMode &&
          other.copyOnImport == this.copyOnImport &&
          other.archiveOrgS3AccessKey == this.archiveOrgS3AccessKey &&
          other.archiveOrgS3SecretKey == this.archiveOrgS3SecretKey &&
          other.archiveEnabled == this.archiveEnabled &&
          other.colorScheme == this.colorScheme);
}

class UserConfigsCompanion extends UpdateCompanion<UserConfig> {
  final Value<String> id;
  final Value<bool> darkMode;
  final Value<bool> copyOnImport;
  final Value<String?> archiveOrgS3AccessKey;
  final Value<String?> archiveOrgS3SecretKey;
  final Value<bool> archiveEnabled;
  final Value<String?> colorScheme;
  final Value<int> rowid;
  const UserConfigsCompanion({
    this.id = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.copyOnImport = const Value.absent(),
    this.archiveOrgS3AccessKey = const Value.absent(),
    this.archiveOrgS3SecretKey = const Value.absent(),
    this.archiveEnabled = const Value.absent(),
    this.colorScheme = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserConfigsCompanion.insert({
    required String id,
    this.darkMode = const Value.absent(),
    this.copyOnImport = const Value.absent(),
    this.archiveOrgS3AccessKey = const Value.absent(),
    this.archiveOrgS3SecretKey = const Value.absent(),
    this.archiveEnabled = const Value.absent(),
    this.colorScheme = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<UserConfig> custom({
    Expression<String>? id,
    Expression<bool>? darkMode,
    Expression<bool>? copyOnImport,
    Expression<String>? archiveOrgS3AccessKey,
    Expression<String>? archiveOrgS3SecretKey,
    Expression<bool>? archiveEnabled,
    Expression<String>? colorScheme,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (darkMode != null) 'dark_mode': darkMode,
      if (copyOnImport != null) 'copy_on_import': copyOnImport,
      if (archiveOrgS3AccessKey != null)
        'archive_org_s3_access_key': archiveOrgS3AccessKey,
      if (archiveOrgS3SecretKey != null)
        'archive_org_s3_secret_key': archiveOrgS3SecretKey,
      if (archiveEnabled != null) 'archive_enabled': archiveEnabled,
      if (colorScheme != null) 'color_scheme': colorScheme,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserConfigsCompanion copyWith(
      {Value<String>? id,
      Value<bool>? darkMode,
      Value<bool>? copyOnImport,
      Value<String?>? archiveOrgS3AccessKey,
      Value<String?>? archiveOrgS3SecretKey,
      Value<bool>? archiveEnabled,
      Value<String?>? colorScheme,
      Value<int>? rowid}) {
    return UserConfigsCompanion(
      id: id ?? this.id,
      darkMode: darkMode ?? this.darkMode,
      copyOnImport: copyOnImport ?? this.copyOnImport,
      archiveOrgS3AccessKey:
          archiveOrgS3AccessKey ?? this.archiveOrgS3AccessKey,
      archiveOrgS3SecretKey:
          archiveOrgS3SecretKey ?? this.archiveOrgS3SecretKey,
      archiveEnabled: archiveEnabled ?? this.archiveEnabled,
      colorScheme: colorScheme ?? this.colorScheme,
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
    if (copyOnImport.present) {
      map['copy_on_import'] = Variable<bool>(copyOnImport.value);
    }
    if (archiveOrgS3AccessKey.present) {
      map['archive_org_s3_access_key'] =
          Variable<String>(archiveOrgS3AccessKey.value);
    }
    if (archiveOrgS3SecretKey.present) {
      map['archive_org_s3_secret_key'] =
          Variable<String>(archiveOrgS3SecretKey.value);
    }
    if (archiveEnabled.present) {
      map['archive_enabled'] = Variable<bool>(archiveEnabled.value);
    }
    if (colorScheme.present) {
      map['color_scheme'] = Variable<String>(colorScheme.value);
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
          ..write('copyOnImport: $copyOnImport, ')
          ..write('archiveOrgS3AccessKey: $archiveOrgS3AccessKey, ')
          ..write('archiveOrgS3SecretKey: $archiveOrgS3SecretKey, ')
          ..write('archiveEnabled: $archiveEnabled, ')
          ..write('colorScheme: $colorScheme, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserThemesTable extends UserThemes
    with TableInfo<$UserThemesTable, UserTheme> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserThemesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 30, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _userConfigIdMeta =
      const VerificationMeta('userConfigId');
  @override
  late final GeneratedColumn<String> userConfigId = GeneratedColumn<String>(
      'user_config_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user_configs (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
      'theme', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, userConfigId, name, theme];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_themes';
  @override
  VerificationContext validateIntegrity(Insertable<UserTheme> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_config_id')) {
      context.handle(
          _userConfigIdMeta,
          userConfigId.isAcceptableOrUnknown(
              data['user_config_id']!, _userConfigIdMeta));
    } else if (isInserting) {
      context.missing(_userConfigIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('theme')) {
      context.handle(
          _themeMeta, theme.isAcceptableOrUnknown(data['theme']!, _themeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserTheme map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserTheme(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userConfigId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_config_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      theme: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme']),
    );
  }

  @override
  $UserThemesTable createAlias(String alias) {
    return $UserThemesTable(attachedDatabase, alias);
  }
}

class UserTheme extends DataClass implements Insertable<UserTheme> {
  final String id;
  final String userConfigId;
  final String name;
  final String? theme;
  const UserTheme(
      {required this.id,
      required this.userConfigId,
      required this.name,
      this.theme});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_config_id'] = Variable<String>(userConfigId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || theme != null) {
      map['theme'] = Variable<String>(theme);
    }
    return map;
  }

  UserThemesCompanion toCompanion(bool nullToAbsent) {
    return UserThemesCompanion(
      id: Value(id),
      userConfigId: Value(userConfigId),
      name: Value(name),
      theme:
          theme == null && nullToAbsent ? const Value.absent() : Value(theme),
    );
  }

  factory UserTheme.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserTheme(
      id: serializer.fromJson<String>(json['id']),
      userConfigId: serializer.fromJson<String>(json['userConfigId']),
      name: serializer.fromJson<String>(json['name']),
      theme: serializer.fromJson<String?>(json['theme']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userConfigId': serializer.toJson<String>(userConfigId),
      'name': serializer.toJson<String>(name),
      'theme': serializer.toJson<String?>(theme),
    };
  }

  UserTheme copyWith(
          {String? id,
          String? userConfigId,
          String? name,
          Value<String?> theme = const Value.absent()}) =>
      UserTheme(
        id: id ?? this.id,
        userConfigId: userConfigId ?? this.userConfigId,
        name: name ?? this.name,
        theme: theme.present ? theme.value : this.theme,
      );
  UserTheme copyWithCompanion(UserThemesCompanion data) {
    return UserTheme(
      id: data.id.present ? data.id.value : this.id,
      userConfigId: data.userConfigId.present
          ? data.userConfigId.value
          : this.userConfigId,
      name: data.name.present ? data.name.value : this.name,
      theme: data.theme.present ? data.theme.value : this.theme,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserTheme(')
          ..write('id: $id, ')
          ..write('userConfigId: $userConfigId, ')
          ..write('name: $name, ')
          ..write('theme: $theme')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userConfigId, name, theme);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserTheme &&
          other.id == this.id &&
          other.userConfigId == this.userConfigId &&
          other.name == this.name &&
          other.theme == this.theme);
}

class UserThemesCompanion extends UpdateCompanion<UserTheme> {
  final Value<String> id;
  final Value<String> userConfigId;
  final Value<String> name;
  final Value<String?> theme;
  final Value<int> rowid;
  const UserThemesCompanion({
    this.id = const Value.absent(),
    this.userConfigId = const Value.absent(),
    this.name = const Value.absent(),
    this.theme = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserThemesCompanion.insert({
    required String id,
    required String userConfigId,
    required String name,
    this.theme = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userConfigId = Value(userConfigId),
        name = Value(name);
  static Insertable<UserTheme> custom({
    Expression<String>? id,
    Expression<String>? userConfigId,
    Expression<String>? name,
    Expression<String>? theme,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userConfigId != null) 'user_config_id': userConfigId,
      if (name != null) 'name': name,
      if (theme != null) 'theme': theme,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserThemesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userConfigId,
      Value<String>? name,
      Value<String?>? theme,
      Value<int>? rowid}) {
    return UserThemesCompanion(
      id: id ?? this.id,
      userConfigId: userConfigId ?? this.userConfigId,
      name: name ?? this.name,
      theme: theme ?? this.theme,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userConfigId.present) {
      map['user_config_id'] = Variable<String>(userConfigId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserThemesCompanion(')
          ..write('id: $id, ')
          ..write('userConfigId: $userConfigId, ')
          ..write('name: $name, ')
          ..write('theme: $theme, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupSettingsTable extends BackupSettings
    with TableInfo<$BackupSettingsTable, BackupSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 30, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _userConfigIdMeta =
      const VerificationMeta('userConfigId');
  @override
  late final GeneratedColumn<String> userConfigId = GeneratedColumn<String>(
      'user_config_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user_configs (id)'));
  static const VerificationMeta _backupIntervalMeta =
      const VerificationMeta('backupInterval');
  @override
  late final GeneratedColumn<String> backupInterval = GeneratedColumn<String>(
      'backup_interval', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _backupFilenameMeta =
      const VerificationMeta('backupFilename');
  @override
  late final GeneratedColumn<String> backupFilename = GeneratedColumn<String>(
      'backup_filename', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _backupPathMeta =
      const VerificationMeta('backupPath');
  @override
  late final GeneratedColumn<String> backupPath = GeneratedColumn<String>(
      'backup_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastBackupTimestampMeta =
      const VerificationMeta('lastBackupTimestamp');
  @override
  late final GeneratedColumn<DateTime> lastBackupTimestamp =
      GeneratedColumn<DateTime>('last_backup_timestamp', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userConfigId,
        backupInterval,
        backupFilename,
        backupPath,
        lastBackupTimestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_settings';
  @override
  VerificationContext validateIntegrity(Insertable<BackupSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_config_id')) {
      context.handle(
          _userConfigIdMeta,
          userConfigId.isAcceptableOrUnknown(
              data['user_config_id']!, _userConfigIdMeta));
    } else if (isInserting) {
      context.missing(_userConfigIdMeta);
    }
    if (data.containsKey('backup_interval')) {
      context.handle(
          _backupIntervalMeta,
          backupInterval.isAcceptableOrUnknown(
              data['backup_interval']!, _backupIntervalMeta));
    }
    if (data.containsKey('backup_filename')) {
      context.handle(
          _backupFilenameMeta,
          backupFilename.isAcceptableOrUnknown(
              data['backup_filename']!, _backupFilenameMeta));
    }
    if (data.containsKey('backup_path')) {
      context.handle(
          _backupPathMeta,
          backupPath.isAcceptableOrUnknown(
              data['backup_path']!, _backupPathMeta));
    }
    if (data.containsKey('last_backup_timestamp')) {
      context.handle(
          _lastBackupTimestampMeta,
          lastBackupTimestamp.isAcceptableOrUnknown(
              data['last_backup_timestamp']!, _lastBackupTimestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userConfigId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_config_id'])!,
      backupInterval: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}backup_interval']),
      backupFilename: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}backup_filename']),
      backupPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}backup_path']),
      lastBackupTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}last_backup_timestamp']),
    );
  }

  @override
  $BackupSettingsTable createAlias(String alias) {
    return $BackupSettingsTable(attachedDatabase, alias);
  }
}

class BackupSetting extends DataClass implements Insertable<BackupSetting> {
  final String id;
  final String userConfigId;
  final String? backupInterval;
  final String? backupFilename;
  final String? backupPath;
  final DateTime? lastBackupTimestamp;
  const BackupSetting(
      {required this.id,
      required this.userConfigId,
      this.backupInterval,
      this.backupFilename,
      this.backupPath,
      this.lastBackupTimestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_config_id'] = Variable<String>(userConfigId);
    if (!nullToAbsent || backupInterval != null) {
      map['backup_interval'] = Variable<String>(backupInterval);
    }
    if (!nullToAbsent || backupFilename != null) {
      map['backup_filename'] = Variable<String>(backupFilename);
    }
    if (!nullToAbsent || backupPath != null) {
      map['backup_path'] = Variable<String>(backupPath);
    }
    if (!nullToAbsent || lastBackupTimestamp != null) {
      map['last_backup_timestamp'] = Variable<DateTime>(lastBackupTimestamp);
    }
    return map;
  }

  BackupSettingsCompanion toCompanion(bool nullToAbsent) {
    return BackupSettingsCompanion(
      id: Value(id),
      userConfigId: Value(userConfigId),
      backupInterval: backupInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(backupInterval),
      backupFilename: backupFilename == null && nullToAbsent
          ? const Value.absent()
          : Value(backupFilename),
      backupPath: backupPath == null && nullToAbsent
          ? const Value.absent()
          : Value(backupPath),
      lastBackupTimestamp: lastBackupTimestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBackupTimestamp),
    );
  }

  factory BackupSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupSetting(
      id: serializer.fromJson<String>(json['id']),
      userConfigId: serializer.fromJson<String>(json['userConfigId']),
      backupInterval: serializer.fromJson<String?>(json['backupInterval']),
      backupFilename: serializer.fromJson<String?>(json['backupFilename']),
      backupPath: serializer.fromJson<String?>(json['backupPath']),
      lastBackupTimestamp:
          serializer.fromJson<DateTime?>(json['lastBackupTimestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userConfigId': serializer.toJson<String>(userConfigId),
      'backupInterval': serializer.toJson<String?>(backupInterval),
      'backupFilename': serializer.toJson<String?>(backupFilename),
      'backupPath': serializer.toJson<String?>(backupPath),
      'lastBackupTimestamp': serializer.toJson<DateTime?>(lastBackupTimestamp),
    };
  }

  BackupSetting copyWith(
          {String? id,
          String? userConfigId,
          Value<String?> backupInterval = const Value.absent(),
          Value<String?> backupFilename = const Value.absent(),
          Value<String?> backupPath = const Value.absent(),
          Value<DateTime?> lastBackupTimestamp = const Value.absent()}) =>
      BackupSetting(
        id: id ?? this.id,
        userConfigId: userConfigId ?? this.userConfigId,
        backupInterval:
            backupInterval.present ? backupInterval.value : this.backupInterval,
        backupFilename:
            backupFilename.present ? backupFilename.value : this.backupFilename,
        backupPath: backupPath.present ? backupPath.value : this.backupPath,
        lastBackupTimestamp: lastBackupTimestamp.present
            ? lastBackupTimestamp.value
            : this.lastBackupTimestamp,
      );
  BackupSetting copyWithCompanion(BackupSettingsCompanion data) {
    return BackupSetting(
      id: data.id.present ? data.id.value : this.id,
      userConfigId: data.userConfigId.present
          ? data.userConfigId.value
          : this.userConfigId,
      backupInterval: data.backupInterval.present
          ? data.backupInterval.value
          : this.backupInterval,
      backupFilename: data.backupFilename.present
          ? data.backupFilename.value
          : this.backupFilename,
      backupPath:
          data.backupPath.present ? data.backupPath.value : this.backupPath,
      lastBackupTimestamp: data.lastBackupTimestamp.present
          ? data.lastBackupTimestamp.value
          : this.lastBackupTimestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupSetting(')
          ..write('id: $id, ')
          ..write('userConfigId: $userConfigId, ')
          ..write('backupInterval: $backupInterval, ')
          ..write('backupFilename: $backupFilename, ')
          ..write('backupPath: $backupPath, ')
          ..write('lastBackupTimestamp: $lastBackupTimestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userConfigId, backupInterval,
      backupFilename, backupPath, lastBackupTimestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupSetting &&
          other.id == this.id &&
          other.userConfigId == this.userConfigId &&
          other.backupInterval == this.backupInterval &&
          other.backupFilename == this.backupFilename &&
          other.backupPath == this.backupPath &&
          other.lastBackupTimestamp == this.lastBackupTimestamp);
}

class BackupSettingsCompanion extends UpdateCompanion<BackupSetting> {
  final Value<String> id;
  final Value<String> userConfigId;
  final Value<String?> backupInterval;
  final Value<String?> backupFilename;
  final Value<String?> backupPath;
  final Value<DateTime?> lastBackupTimestamp;
  final Value<int> rowid;
  const BackupSettingsCompanion({
    this.id = const Value.absent(),
    this.userConfigId = const Value.absent(),
    this.backupInterval = const Value.absent(),
    this.backupFilename = const Value.absent(),
    this.backupPath = const Value.absent(),
    this.lastBackupTimestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupSettingsCompanion.insert({
    required String id,
    required String userConfigId,
    this.backupInterval = const Value.absent(),
    this.backupFilename = const Value.absent(),
    this.backupPath = const Value.absent(),
    this.lastBackupTimestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userConfigId = Value(userConfigId);
  static Insertable<BackupSetting> custom({
    Expression<String>? id,
    Expression<String>? userConfigId,
    Expression<String>? backupInterval,
    Expression<String>? backupFilename,
    Expression<String>? backupPath,
    Expression<DateTime>? lastBackupTimestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userConfigId != null) 'user_config_id': userConfigId,
      if (backupInterval != null) 'backup_interval': backupInterval,
      if (backupFilename != null) 'backup_filename': backupFilename,
      if (backupPath != null) 'backup_path': backupPath,
      if (lastBackupTimestamp != null)
        'last_backup_timestamp': lastBackupTimestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupSettingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userConfigId,
      Value<String?>? backupInterval,
      Value<String?>? backupFilename,
      Value<String?>? backupPath,
      Value<DateTime?>? lastBackupTimestamp,
      Value<int>? rowid}) {
    return BackupSettingsCompanion(
      id: id ?? this.id,
      userConfigId: userConfigId ?? this.userConfigId,
      backupInterval: backupInterval ?? this.backupInterval,
      backupFilename: backupFilename ?? this.backupFilename,
      backupPath: backupPath ?? this.backupPath,
      lastBackupTimestamp: lastBackupTimestamp ?? this.lastBackupTimestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userConfigId.present) {
      map['user_config_id'] = Variable<String>(userConfigId.value);
    }
    if (backupInterval.present) {
      map['backup_interval'] = Variable<String>(backupInterval.value);
    }
    if (backupFilename.present) {
      map['backup_filename'] = Variable<String>(backupFilename.value);
    }
    if (backupPath.present) {
      map['backup_path'] = Variable<String>(backupPath.value);
    }
    if (lastBackupTimestamp.present) {
      map['last_backup_timestamp'] =
          Variable<DateTime>(lastBackupTimestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupSettingsCompanion(')
          ..write('id: $id, ')
          ..write('userConfigId: $userConfigId, ')
          ..write('backupInterval: $backupInterval, ')
          ..write('backupFilename: $backupFilename, ')
          ..write('backupPath: $backupPath, ')
          ..write('lastBackupTimestamp: $lastBackupTimestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArchiveSettingsTable extends ArchiveSettings
    with TableInfo<$ArchiveSettingsTable, ArchiveSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArchiveSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 30, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _userConfigIdMeta =
      const VerificationMeta('userConfigId');
  @override
  late final GeneratedColumn<String> userConfigId = GeneratedColumn<String>(
      'user_config_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user_configs (id)'));
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
      [id, userConfigId, archiveOrgS3AccessKey, archiveOrgS3SecretKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'archive_settings';
  @override
  VerificationContext validateIntegrity(Insertable<ArchiveSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_config_id')) {
      context.handle(
          _userConfigIdMeta,
          userConfigId.isAcceptableOrUnknown(
              data['user_config_id']!, _userConfigIdMeta));
    } else if (isInserting) {
      context.missing(_userConfigIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArchiveSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArchiveSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userConfigId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_config_id'])!,
      archiveOrgS3AccessKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}archive_org_s3_access_key']),
      archiveOrgS3SecretKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}archive_org_s3_secret_key']),
    );
  }

  @override
  $ArchiveSettingsTable createAlias(String alias) {
    return $ArchiveSettingsTable(attachedDatabase, alias);
  }
}

class ArchiveSetting extends DataClass implements Insertable<ArchiveSetting> {
  final String id;
  final String userConfigId;
  final String? archiveOrgS3AccessKey;
  final String? archiveOrgS3SecretKey;
  const ArchiveSetting(
      {required this.id,
      required this.userConfigId,
      this.archiveOrgS3AccessKey,
      this.archiveOrgS3SecretKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_config_id'] = Variable<String>(userConfigId);
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

  ArchiveSettingsCompanion toCompanion(bool nullToAbsent) {
    return ArchiveSettingsCompanion(
      id: Value(id),
      userConfigId: Value(userConfigId),
      archiveOrgS3AccessKey: archiveOrgS3AccessKey == null && nullToAbsent
          ? const Value.absent()
          : Value(archiveOrgS3AccessKey),
      archiveOrgS3SecretKey: archiveOrgS3SecretKey == null && nullToAbsent
          ? const Value.absent()
          : Value(archiveOrgS3SecretKey),
    );
  }

  factory ArchiveSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArchiveSetting(
      id: serializer.fromJson<String>(json['id']),
      userConfigId: serializer.fromJson<String>(json['userConfigId']),
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
      'userConfigId': serializer.toJson<String>(userConfigId),
      'archiveOrgS3AccessKey':
          serializer.toJson<String?>(archiveOrgS3AccessKey),
      'archiveOrgS3SecretKey':
          serializer.toJson<String?>(archiveOrgS3SecretKey),
    };
  }

  ArchiveSetting copyWith(
          {String? id,
          String? userConfigId,
          Value<String?> archiveOrgS3AccessKey = const Value.absent(),
          Value<String?> archiveOrgS3SecretKey = const Value.absent()}) =>
      ArchiveSetting(
        id: id ?? this.id,
        userConfigId: userConfigId ?? this.userConfigId,
        archiveOrgS3AccessKey: archiveOrgS3AccessKey.present
            ? archiveOrgS3AccessKey.value
            : this.archiveOrgS3AccessKey,
        archiveOrgS3SecretKey: archiveOrgS3SecretKey.present
            ? archiveOrgS3SecretKey.value
            : this.archiveOrgS3SecretKey,
      );
  ArchiveSetting copyWithCompanion(ArchiveSettingsCompanion data) {
    return ArchiveSetting(
      id: data.id.present ? data.id.value : this.id,
      userConfigId: data.userConfigId.present
          ? data.userConfigId.value
          : this.userConfigId,
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
    return (StringBuffer('ArchiveSetting(')
          ..write('id: $id, ')
          ..write('userConfigId: $userConfigId, ')
          ..write('archiveOrgS3AccessKey: $archiveOrgS3AccessKey, ')
          ..write('archiveOrgS3SecretKey: $archiveOrgS3SecretKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userConfigId, archiveOrgS3AccessKey, archiveOrgS3SecretKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArchiveSetting &&
          other.id == this.id &&
          other.userConfigId == this.userConfigId &&
          other.archiveOrgS3AccessKey == this.archiveOrgS3AccessKey &&
          other.archiveOrgS3SecretKey == this.archiveOrgS3SecretKey);
}

class ArchiveSettingsCompanion extends UpdateCompanion<ArchiveSetting> {
  final Value<String> id;
  final Value<String> userConfigId;
  final Value<String?> archiveOrgS3AccessKey;
  final Value<String?> archiveOrgS3SecretKey;
  final Value<int> rowid;
  const ArchiveSettingsCompanion({
    this.id = const Value.absent(),
    this.userConfigId = const Value.absent(),
    this.archiveOrgS3AccessKey = const Value.absent(),
    this.archiveOrgS3SecretKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArchiveSettingsCompanion.insert({
    required String id,
    required String userConfigId,
    this.archiveOrgS3AccessKey = const Value.absent(),
    this.archiveOrgS3SecretKey = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userConfigId = Value(userConfigId);
  static Insertable<ArchiveSetting> custom({
    Expression<String>? id,
    Expression<String>? userConfigId,
    Expression<String>? archiveOrgS3AccessKey,
    Expression<String>? archiveOrgS3SecretKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userConfigId != null) 'user_config_id': userConfigId,
      if (archiveOrgS3AccessKey != null)
        'archive_org_s3_access_key': archiveOrgS3AccessKey,
      if (archiveOrgS3SecretKey != null)
        'archive_org_s3_secret_key': archiveOrgS3SecretKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArchiveSettingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userConfigId,
      Value<String?>? archiveOrgS3AccessKey,
      Value<String?>? archiveOrgS3SecretKey,
      Value<int>? rowid}) {
    return ArchiveSettingsCompanion(
      id: id ?? this.id,
      userConfigId: userConfigId ?? this.userConfigId,
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
    if (userConfigId.present) {
      map['user_config_id'] = Variable<String>(userConfigId.value);
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
    return (StringBuffer('ArchiveSettingsCompanion(')
          ..write('id: $id, ')
          ..write('userConfigId: $userConfigId, ')
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
  late final $UserThemesTable userThemes = $UserThemesTable(this);
  late final $BackupSettingsTable backupSettings = $BackupSettingsTable(this);
  late final $ArchiveSettingsTable archiveSettings =
      $ArchiveSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [userConfigs, userThemes, backupSettings, archiveSettings];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$UserConfigsTableCreateCompanionBuilder = UserConfigsCompanion
    Function({
  required String id,
  Value<bool> darkMode,
  Value<bool> copyOnImport,
  Value<String?> archiveOrgS3AccessKey,
  Value<String?> archiveOrgS3SecretKey,
  Value<bool> archiveEnabled,
  Value<String?> colorScheme,
  Value<int> rowid,
});
typedef $$UserConfigsTableUpdateCompanionBuilder = UserConfigsCompanion
    Function({
  Value<String> id,
  Value<bool> darkMode,
  Value<bool> copyOnImport,
  Value<String?> archiveOrgS3AccessKey,
  Value<String?> archiveOrgS3SecretKey,
  Value<bool> archiveEnabled,
  Value<String?> colorScheme,
  Value<int> rowid,
});

final class $$UserConfigsTableReferences
    extends BaseReferences<_$ConfigDatabase, $UserConfigsTable, UserConfig> {
  $$UserConfigsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserThemesTable, List<UserTheme>>
      _userThemesRefsTable(_$ConfigDatabase db) =>
          MultiTypedResultKey.fromTable(db.userThemes,
              aliasName: $_aliasNameGenerator(
                  db.userConfigs.id, db.userThemes.userConfigId));

  $$UserThemesTableProcessedTableManager get userThemesRefs {
    final manager = $$UserThemesTableTableManager($_db, $_db.userThemes).filter(
        (f) => f.userConfigId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userThemesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BackupSettingsTable, List<BackupSetting>>
      _backupSettingsRefsTable(_$ConfigDatabase db) =>
          MultiTypedResultKey.fromTable(db.backupSettings,
              aliasName: $_aliasNameGenerator(
                  db.userConfigs.id, db.backupSettings.userConfigId));

  $$BackupSettingsTableProcessedTableManager get backupSettingsRefs {
    final manager = $$BackupSettingsTableTableManager($_db, $_db.backupSettings)
        .filter(
            (f) => f.userConfigId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_backupSettingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ArchiveSettingsTable, List<ArchiveSetting>>
      _archiveSettingsRefsTable(_$ConfigDatabase db) =>
          MultiTypedResultKey.fromTable(db.archiveSettings,
              aliasName: $_aliasNameGenerator(
                  db.userConfigs.id, db.archiveSettings.userConfigId));

  $$ArchiveSettingsTableProcessedTableManager get archiveSettingsRefs {
    final manager =
        $$ArchiveSettingsTableTableManager($_db, $_db.archiveSettings).filter(
            (f) => f.userConfigId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_archiveSettingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UserConfigsTableFilterComposer
    extends Composer<_$ConfigDatabase, $UserConfigsTable> {
  $$UserConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get darkMode => $composableBuilder(
      column: $table.darkMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get copyOnImport => $composableBuilder(
      column: $table.copyOnImport, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get archiveOrgS3AccessKey => $composableBuilder(
      column: $table.archiveOrgS3AccessKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get archiveOrgS3SecretKey => $composableBuilder(
      column: $table.archiveOrgS3SecretKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archiveEnabled => $composableBuilder(
      column: $table.archiveEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorScheme => $composableBuilder(
      column: $table.colorScheme, builder: (column) => ColumnFilters(column));

  Expression<bool> userThemesRefs(
      Expression<bool> Function($$UserThemesTableFilterComposer f) f) {
    final $$UserThemesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userThemes,
        getReferencedColumn: (t) => t.userConfigId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserThemesTableFilterComposer(
              $db: $db,
              $table: $db.userThemes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> backupSettingsRefs(
      Expression<bool> Function($$BackupSettingsTableFilterComposer f) f) {
    final $$BackupSettingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.backupSettings,
        getReferencedColumn: (t) => t.userConfigId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BackupSettingsTableFilterComposer(
              $db: $db,
              $table: $db.backupSettings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> archiveSettingsRefs(
      Expression<bool> Function($$ArchiveSettingsTableFilterComposer f) f) {
    final $$ArchiveSettingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.archiveSettings,
        getReferencedColumn: (t) => t.userConfigId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ArchiveSettingsTableFilterComposer(
              $db: $db,
              $table: $db.archiveSettings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UserConfigsTableOrderingComposer
    extends Composer<_$ConfigDatabase, $UserConfigsTable> {
  $$UserConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get darkMode => $composableBuilder(
      column: $table.darkMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get copyOnImport => $composableBuilder(
      column: $table.copyOnImport,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get archiveOrgS3AccessKey => $composableBuilder(
      column: $table.archiveOrgS3AccessKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get archiveOrgS3SecretKey => $composableBuilder(
      column: $table.archiveOrgS3SecretKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archiveEnabled => $composableBuilder(
      column: $table.archiveEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorScheme => $composableBuilder(
      column: $table.colorScheme, builder: (column) => ColumnOrderings(column));
}

class $$UserConfigsTableAnnotationComposer
    extends Composer<_$ConfigDatabase, $UserConfigsTable> {
  $$UserConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get darkMode =>
      $composableBuilder(column: $table.darkMode, builder: (column) => column);

  GeneratedColumn<bool> get copyOnImport => $composableBuilder(
      column: $table.copyOnImport, builder: (column) => column);

  GeneratedColumn<String> get archiveOrgS3AccessKey => $composableBuilder(
      column: $table.archiveOrgS3AccessKey, builder: (column) => column);

  GeneratedColumn<String> get archiveOrgS3SecretKey => $composableBuilder(
      column: $table.archiveOrgS3SecretKey, builder: (column) => column);

  GeneratedColumn<bool> get archiveEnabled => $composableBuilder(
      column: $table.archiveEnabled, builder: (column) => column);

  GeneratedColumn<String> get colorScheme => $composableBuilder(
      column: $table.colorScheme, builder: (column) => column);

  Expression<T> userThemesRefs<T extends Object>(
      Expression<T> Function($$UserThemesTableAnnotationComposer a) f) {
    final $$UserThemesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userThemes,
        getReferencedColumn: (t) => t.userConfigId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserThemesTableAnnotationComposer(
              $db: $db,
              $table: $db.userThemes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> backupSettingsRefs<T extends Object>(
      Expression<T> Function($$BackupSettingsTableAnnotationComposer a) f) {
    final $$BackupSettingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.backupSettings,
        getReferencedColumn: (t) => t.userConfigId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BackupSettingsTableAnnotationComposer(
              $db: $db,
              $table: $db.backupSettings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> archiveSettingsRefs<T extends Object>(
      Expression<T> Function($$ArchiveSettingsTableAnnotationComposer a) f) {
    final $$ArchiveSettingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.archiveSettings,
        getReferencedColumn: (t) => t.userConfigId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ArchiveSettingsTableAnnotationComposer(
              $db: $db,
              $table: $db.archiveSettings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UserConfigsTableTableManager extends RootTableManager<
    _$ConfigDatabase,
    $UserConfigsTable,
    UserConfig,
    $$UserConfigsTableFilterComposer,
    $$UserConfigsTableOrderingComposer,
    $$UserConfigsTableAnnotationComposer,
    $$UserConfigsTableCreateCompanionBuilder,
    $$UserConfigsTableUpdateCompanionBuilder,
    (UserConfig, $$UserConfigsTableReferences),
    UserConfig,
    PrefetchHooks Function(
        {bool userThemesRefs,
        bool backupSettingsRefs,
        bool archiveSettingsRefs})> {
  $$UserConfigsTableTableManager(_$ConfigDatabase db, $UserConfigsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<bool> darkMode = const Value.absent(),
            Value<bool> copyOnImport = const Value.absent(),
            Value<String?> archiveOrgS3AccessKey = const Value.absent(),
            Value<String?> archiveOrgS3SecretKey = const Value.absent(),
            Value<bool> archiveEnabled = const Value.absent(),
            Value<String?> colorScheme = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserConfigsCompanion(
            id: id,
            darkMode: darkMode,
            copyOnImport: copyOnImport,
            archiveOrgS3AccessKey: archiveOrgS3AccessKey,
            archiveOrgS3SecretKey: archiveOrgS3SecretKey,
            archiveEnabled: archiveEnabled,
            colorScheme: colorScheme,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<bool> darkMode = const Value.absent(),
            Value<bool> copyOnImport = const Value.absent(),
            Value<String?> archiveOrgS3AccessKey = const Value.absent(),
            Value<String?> archiveOrgS3SecretKey = const Value.absent(),
            Value<bool> archiveEnabled = const Value.absent(),
            Value<String?> colorScheme = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserConfigsCompanion.insert(
            id: id,
            darkMode: darkMode,
            copyOnImport: copyOnImport,
            archiveOrgS3AccessKey: archiveOrgS3AccessKey,
            archiveOrgS3SecretKey: archiveOrgS3SecretKey,
            archiveEnabled: archiveEnabled,
            colorScheme: colorScheme,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserConfigsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {userThemesRefs = false,
              backupSettingsRefs = false,
              archiveSettingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userThemesRefs) db.userThemes,
                if (backupSettingsRefs) db.backupSettings,
                if (archiveSettingsRefs) db.archiveSettings
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userThemesRefs)
                    await $_getPrefetchedData<UserConfig, $UserConfigsTable,
                            UserTheme>(
                        currentTable: table,
                        referencedTable: $$UserConfigsTableReferences
                            ._userThemesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UserConfigsTableReferences(db, table, p0)
                                .userThemesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.userConfigId == item.id),
                        typedResults: items),
                  if (backupSettingsRefs)
                    await $_getPrefetchedData<UserConfig, $UserConfigsTable,
                            BackupSetting>(
                        currentTable: table,
                        referencedTable: $$UserConfigsTableReferences
                            ._backupSettingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UserConfigsTableReferences(db, table, p0)
                                .backupSettingsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.userConfigId == item.id),
                        typedResults: items),
                  if (archiveSettingsRefs)
                    await $_getPrefetchedData<UserConfig, $UserConfigsTable,
                            ArchiveSetting>(
                        currentTable: table,
                        referencedTable: $$UserConfigsTableReferences
                            ._archiveSettingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UserConfigsTableReferences(db, table, p0)
                                .archiveSettingsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.userConfigId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UserConfigsTableProcessedTableManager = ProcessedTableManager<
    _$ConfigDatabase,
    $UserConfigsTable,
    UserConfig,
    $$UserConfigsTableFilterComposer,
    $$UserConfigsTableOrderingComposer,
    $$UserConfigsTableAnnotationComposer,
    $$UserConfigsTableCreateCompanionBuilder,
    $$UserConfigsTableUpdateCompanionBuilder,
    (UserConfig, $$UserConfigsTableReferences),
    UserConfig,
    PrefetchHooks Function(
        {bool userThemesRefs,
        bool backupSettingsRefs,
        bool archiveSettingsRefs})>;
typedef $$UserThemesTableCreateCompanionBuilder = UserThemesCompanion Function({
  required String id,
  required String userConfigId,
  required String name,
  Value<String?> theme,
  Value<int> rowid,
});
typedef $$UserThemesTableUpdateCompanionBuilder = UserThemesCompanion Function({
  Value<String> id,
  Value<String> userConfigId,
  Value<String> name,
  Value<String?> theme,
  Value<int> rowid,
});

final class $$UserThemesTableReferences
    extends BaseReferences<_$ConfigDatabase, $UserThemesTable, UserTheme> {
  $$UserThemesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserConfigsTable _userConfigIdTable(_$ConfigDatabase db) =>
      db.userConfigs.createAlias(
          $_aliasNameGenerator(db.userThemes.userConfigId, db.userConfigs.id));

  $$UserConfigsTableProcessedTableManager get userConfigId {
    final $_column = $_itemColumn<String>('user_config_id')!;

    final manager = $$UserConfigsTableTableManager($_db, $_db.userConfigs)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userConfigIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserThemesTableFilterComposer
    extends Composer<_$ConfigDatabase, $UserThemesTable> {
  $$UserThemesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get theme => $composableBuilder(
      column: $table.theme, builder: (column) => ColumnFilters(column));

  $$UserConfigsTableFilterComposer get userConfigId {
    final $$UserConfigsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userConfigId,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserConfigsTableFilterComposer(
              $db: $db,
              $table: $db.userConfigs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserThemesTableOrderingComposer
    extends Composer<_$ConfigDatabase, $UserThemesTable> {
  $$UserThemesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get theme => $composableBuilder(
      column: $table.theme, builder: (column) => ColumnOrderings(column));

  $$UserConfigsTableOrderingComposer get userConfigId {
    final $$UserConfigsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userConfigId,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserConfigsTableOrderingComposer(
              $db: $db,
              $table: $db.userConfigs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserThemesTableAnnotationComposer
    extends Composer<_$ConfigDatabase, $UserThemesTable> {
  $$UserThemesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  $$UserConfigsTableAnnotationComposer get userConfigId {
    final $$UserConfigsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userConfigId,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserConfigsTableAnnotationComposer(
              $db: $db,
              $table: $db.userConfigs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserThemesTableTableManager extends RootTableManager<
    _$ConfigDatabase,
    $UserThemesTable,
    UserTheme,
    $$UserThemesTableFilterComposer,
    $$UserThemesTableOrderingComposer,
    $$UserThemesTableAnnotationComposer,
    $$UserThemesTableCreateCompanionBuilder,
    $$UserThemesTableUpdateCompanionBuilder,
    (UserTheme, $$UserThemesTableReferences),
    UserTheme,
    PrefetchHooks Function({bool userConfigId})> {
  $$UserThemesTableTableManager(_$ConfigDatabase db, $UserThemesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserThemesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserThemesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserThemesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userConfigId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> theme = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserThemesCompanion(
            id: id,
            userConfigId: userConfigId,
            name: name,
            theme: theme,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userConfigId,
            required String name,
            Value<String?> theme = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserThemesCompanion.insert(
            id: id,
            userConfigId: userConfigId,
            name: name,
            theme: theme,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserThemesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userConfigId = false}) {
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
                      dynamic,
                      dynamic>>(state) {
                if (userConfigId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userConfigId,
                    referencedTable:
                        $$UserThemesTableReferences._userConfigIdTable(db),
                    referencedColumn:
                        $$UserThemesTableReferences._userConfigIdTable(db).id,
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

typedef $$UserThemesTableProcessedTableManager = ProcessedTableManager<
    _$ConfigDatabase,
    $UserThemesTable,
    UserTheme,
    $$UserThemesTableFilterComposer,
    $$UserThemesTableOrderingComposer,
    $$UserThemesTableAnnotationComposer,
    $$UserThemesTableCreateCompanionBuilder,
    $$UserThemesTableUpdateCompanionBuilder,
    (UserTheme, $$UserThemesTableReferences),
    UserTheme,
    PrefetchHooks Function({bool userConfigId})>;
typedef $$BackupSettingsTableCreateCompanionBuilder = BackupSettingsCompanion
    Function({
  required String id,
  required String userConfigId,
  Value<String?> backupInterval,
  Value<String?> backupFilename,
  Value<String?> backupPath,
  Value<DateTime?> lastBackupTimestamp,
  Value<int> rowid,
});
typedef $$BackupSettingsTableUpdateCompanionBuilder = BackupSettingsCompanion
    Function({
  Value<String> id,
  Value<String> userConfigId,
  Value<String?> backupInterval,
  Value<String?> backupFilename,
  Value<String?> backupPath,
  Value<DateTime?> lastBackupTimestamp,
  Value<int> rowid,
});

final class $$BackupSettingsTableReferences extends BaseReferences<
    _$ConfigDatabase, $BackupSettingsTable, BackupSetting> {
  $$BackupSettingsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UserConfigsTable _userConfigIdTable(_$ConfigDatabase db) =>
      db.userConfigs.createAlias($_aliasNameGenerator(
          db.backupSettings.userConfigId, db.userConfigs.id));

  $$UserConfigsTableProcessedTableManager get userConfigId {
    final $_column = $_itemColumn<String>('user_config_id')!;

    final manager = $$UserConfigsTableTableManager($_db, $_db.userConfigs)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userConfigIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BackupSettingsTableFilterComposer
    extends Composer<_$ConfigDatabase, $BackupSettingsTable> {
  $$BackupSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backupInterval => $composableBuilder(
      column: $table.backupInterval,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backupFilename => $composableBuilder(
      column: $table.backupFilename,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backupPath => $composableBuilder(
      column: $table.backupPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastBackupTimestamp => $composableBuilder(
      column: $table.lastBackupTimestamp,
      builder: (column) => ColumnFilters(column));

  $$UserConfigsTableFilterComposer get userConfigId {
    final $$UserConfigsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userConfigId,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserConfigsTableFilterComposer(
              $db: $db,
              $table: $db.userConfigs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BackupSettingsTableOrderingComposer
    extends Composer<_$ConfigDatabase, $BackupSettingsTable> {
  $$BackupSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backupInterval => $composableBuilder(
      column: $table.backupInterval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backupFilename => $composableBuilder(
      column: $table.backupFilename,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backupPath => $composableBuilder(
      column: $table.backupPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastBackupTimestamp => $composableBuilder(
      column: $table.lastBackupTimestamp,
      builder: (column) => ColumnOrderings(column));

  $$UserConfigsTableOrderingComposer get userConfigId {
    final $$UserConfigsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userConfigId,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserConfigsTableOrderingComposer(
              $db: $db,
              $table: $db.userConfigs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BackupSettingsTableAnnotationComposer
    extends Composer<_$ConfigDatabase, $BackupSettingsTable> {
  $$BackupSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get backupInterval => $composableBuilder(
      column: $table.backupInterval, builder: (column) => column);

  GeneratedColumn<String> get backupFilename => $composableBuilder(
      column: $table.backupFilename, builder: (column) => column);

  GeneratedColumn<String> get backupPath => $composableBuilder(
      column: $table.backupPath, builder: (column) => column);

  GeneratedColumn<DateTime> get lastBackupTimestamp => $composableBuilder(
      column: $table.lastBackupTimestamp, builder: (column) => column);

  $$UserConfigsTableAnnotationComposer get userConfigId {
    final $$UserConfigsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userConfigId,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserConfigsTableAnnotationComposer(
              $db: $db,
              $table: $db.userConfigs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BackupSettingsTableTableManager extends RootTableManager<
    _$ConfigDatabase,
    $BackupSettingsTable,
    BackupSetting,
    $$BackupSettingsTableFilterComposer,
    $$BackupSettingsTableOrderingComposer,
    $$BackupSettingsTableAnnotationComposer,
    $$BackupSettingsTableCreateCompanionBuilder,
    $$BackupSettingsTableUpdateCompanionBuilder,
    (BackupSetting, $$BackupSettingsTableReferences),
    BackupSetting,
    PrefetchHooks Function({bool userConfigId})> {
  $$BackupSettingsTableTableManager(
      _$ConfigDatabase db, $BackupSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userConfigId = const Value.absent(),
            Value<String?> backupInterval = const Value.absent(),
            Value<String?> backupFilename = const Value.absent(),
            Value<String?> backupPath = const Value.absent(),
            Value<DateTime?> lastBackupTimestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BackupSettingsCompanion(
            id: id,
            userConfigId: userConfigId,
            backupInterval: backupInterval,
            backupFilename: backupFilename,
            backupPath: backupPath,
            lastBackupTimestamp: lastBackupTimestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userConfigId,
            Value<String?> backupInterval = const Value.absent(),
            Value<String?> backupFilename = const Value.absent(),
            Value<String?> backupPath = const Value.absent(),
            Value<DateTime?> lastBackupTimestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BackupSettingsCompanion.insert(
            id: id,
            userConfigId: userConfigId,
            backupInterval: backupInterval,
            backupFilename: backupFilename,
            backupPath: backupPath,
            lastBackupTimestamp: lastBackupTimestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BackupSettingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userConfigId = false}) {
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
                      dynamic,
                      dynamic>>(state) {
                if (userConfigId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userConfigId,
                    referencedTable:
                        $$BackupSettingsTableReferences._userConfigIdTable(db),
                    referencedColumn: $$BackupSettingsTableReferences
                        ._userConfigIdTable(db)
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

typedef $$BackupSettingsTableProcessedTableManager = ProcessedTableManager<
    _$ConfigDatabase,
    $BackupSettingsTable,
    BackupSetting,
    $$BackupSettingsTableFilterComposer,
    $$BackupSettingsTableOrderingComposer,
    $$BackupSettingsTableAnnotationComposer,
    $$BackupSettingsTableCreateCompanionBuilder,
    $$BackupSettingsTableUpdateCompanionBuilder,
    (BackupSetting, $$BackupSettingsTableReferences),
    BackupSetting,
    PrefetchHooks Function({bool userConfigId})>;
typedef $$ArchiveSettingsTableCreateCompanionBuilder = ArchiveSettingsCompanion
    Function({
  required String id,
  required String userConfigId,
  Value<String?> archiveOrgS3AccessKey,
  Value<String?> archiveOrgS3SecretKey,
  Value<int> rowid,
});
typedef $$ArchiveSettingsTableUpdateCompanionBuilder = ArchiveSettingsCompanion
    Function({
  Value<String> id,
  Value<String> userConfigId,
  Value<String?> archiveOrgS3AccessKey,
  Value<String?> archiveOrgS3SecretKey,
  Value<int> rowid,
});

final class $$ArchiveSettingsTableReferences extends BaseReferences<
    _$ConfigDatabase, $ArchiveSettingsTable, ArchiveSetting> {
  $$ArchiveSettingsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UserConfigsTable _userConfigIdTable(_$ConfigDatabase db) =>
      db.userConfigs.createAlias($_aliasNameGenerator(
          db.archiveSettings.userConfigId, db.userConfigs.id));

  $$UserConfigsTableProcessedTableManager get userConfigId {
    final $_column = $_itemColumn<String>('user_config_id')!;

    final manager = $$UserConfigsTableTableManager($_db, $_db.userConfigs)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userConfigIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ArchiveSettingsTableFilterComposer
    extends Composer<_$ConfigDatabase, $ArchiveSettingsTable> {
  $$ArchiveSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get archiveOrgS3AccessKey => $composableBuilder(
      column: $table.archiveOrgS3AccessKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get archiveOrgS3SecretKey => $composableBuilder(
      column: $table.archiveOrgS3SecretKey,
      builder: (column) => ColumnFilters(column));

  $$UserConfigsTableFilterComposer get userConfigId {
    final $$UserConfigsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userConfigId,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserConfigsTableFilterComposer(
              $db: $db,
              $table: $db.userConfigs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ArchiveSettingsTableOrderingComposer
    extends Composer<_$ConfigDatabase, $ArchiveSettingsTable> {
  $$ArchiveSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get archiveOrgS3AccessKey => $composableBuilder(
      column: $table.archiveOrgS3AccessKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get archiveOrgS3SecretKey => $composableBuilder(
      column: $table.archiveOrgS3SecretKey,
      builder: (column) => ColumnOrderings(column));

  $$UserConfigsTableOrderingComposer get userConfigId {
    final $$UserConfigsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userConfigId,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserConfigsTableOrderingComposer(
              $db: $db,
              $table: $db.userConfigs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ArchiveSettingsTableAnnotationComposer
    extends Composer<_$ConfigDatabase, $ArchiveSettingsTable> {
  $$ArchiveSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get archiveOrgS3AccessKey => $composableBuilder(
      column: $table.archiveOrgS3AccessKey, builder: (column) => column);

  GeneratedColumn<String> get archiveOrgS3SecretKey => $composableBuilder(
      column: $table.archiveOrgS3SecretKey, builder: (column) => column);

  $$UserConfigsTableAnnotationComposer get userConfigId {
    final $$UserConfigsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userConfigId,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserConfigsTableAnnotationComposer(
              $db: $db,
              $table: $db.userConfigs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ArchiveSettingsTableTableManager extends RootTableManager<
    _$ConfigDatabase,
    $ArchiveSettingsTable,
    ArchiveSetting,
    $$ArchiveSettingsTableFilterComposer,
    $$ArchiveSettingsTableOrderingComposer,
    $$ArchiveSettingsTableAnnotationComposer,
    $$ArchiveSettingsTableCreateCompanionBuilder,
    $$ArchiveSettingsTableUpdateCompanionBuilder,
    (ArchiveSetting, $$ArchiveSettingsTableReferences),
    ArchiveSetting,
    PrefetchHooks Function({bool userConfigId})> {
  $$ArchiveSettingsTableTableManager(
      _$ConfigDatabase db, $ArchiveSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArchiveSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArchiveSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArchiveSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userConfigId = const Value.absent(),
            Value<String?> archiveOrgS3AccessKey = const Value.absent(),
            Value<String?> archiveOrgS3SecretKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ArchiveSettingsCompanion(
            id: id,
            userConfigId: userConfigId,
            archiveOrgS3AccessKey: archiveOrgS3AccessKey,
            archiveOrgS3SecretKey: archiveOrgS3SecretKey,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userConfigId,
            Value<String?> archiveOrgS3AccessKey = const Value.absent(),
            Value<String?> archiveOrgS3SecretKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ArchiveSettingsCompanion.insert(
            id: id,
            userConfigId: userConfigId,
            archiveOrgS3AccessKey: archiveOrgS3AccessKey,
            archiveOrgS3SecretKey: archiveOrgS3SecretKey,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ArchiveSettingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userConfigId = false}) {
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
                      dynamic,
                      dynamic>>(state) {
                if (userConfigId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userConfigId,
                    referencedTable:
                        $$ArchiveSettingsTableReferences._userConfigIdTable(db),
                    referencedColumn: $$ArchiveSettingsTableReferences
                        ._userConfigIdTable(db)
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

typedef $$ArchiveSettingsTableProcessedTableManager = ProcessedTableManager<
    _$ConfigDatabase,
    $ArchiveSettingsTable,
    ArchiveSetting,
    $$ArchiveSettingsTableFilterComposer,
    $$ArchiveSettingsTableOrderingComposer,
    $$ArchiveSettingsTableAnnotationComposer,
    $$ArchiveSettingsTableCreateCompanionBuilder,
    $$ArchiveSettingsTableUpdateCompanionBuilder,
    (ArchiveSetting, $$ArchiveSettingsTableReferences),
    ArchiveSetting,
    PrefetchHooks Function({bool userConfigId})>;

class $ConfigDatabaseManager {
  final _$ConfigDatabase _db;
  $ConfigDatabaseManager(this._db);
  $$UserConfigsTableTableManager get userConfigs =>
      $$UserConfigsTableTableManager(_db, _db.userConfigs);
  $$UserThemesTableTableManager get userThemes =>
      $$UserThemesTableTableManager(_db, _db.userThemes);
  $$BackupSettingsTableTableManager get backupSettings =>
      $$BackupSettingsTableTableManager(_db, _db.backupSettings);
  $$ArchiveSettingsTableTableManager get archiveSettings =>
      $$ArchiveSettingsTableTableManager(_db, _db.archiveSettings);
}
