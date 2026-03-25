// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

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
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
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
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, updatedAt, title, description, color];
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
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
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
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
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
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color']),
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
  final DateTime updatedAt;
  final String title;
  final String description;
  final int? color;
  const Folder(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.title,
      required this.description,
      this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      title: Value(title),
      description: Value(description),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
    );
  }

  factory Folder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      color: serializer.fromJson<int?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'color': serializer.toJson<int?>(color),
    };
  }

  Folder copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? title,
          String? description,
          Value<int?> color = const Value.absent()}) =>
      Folder(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        title: title ?? this.title,
        description: description ?? this.description,
        color: color.present ? color.value : this.color,
      );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, title, description, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.title == this.title &&
          other.description == this.description &&
          other.color == this.color);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> title;
  final Value<String> description;
  final Value<int?> color;
  final Value<int> rowid;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoldersCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String title,
    required String description,
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description);
  static Insertable<Folder> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoldersCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? title,
      Value<String>? description,
      Value<int?>? color,
      Value<int>? rowid}) {
    return FoldersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
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
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
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
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 6, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  late final GeneratedColumnWithTypeConverter<DocumentFileType, String>
      fileType = GeneratedColumn<String>('file_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DocumentFileType>($DocumentsTable.$converterfileType);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _checksumMeta =
      const VerificationMeta('checksum');
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
      'checksum', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, updatedAt, title, filePath, fileType, fileSize, checksum];
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
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    }
    if (data.containsKey('checksum')) {
      context.handle(_checksumMeta,
          checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta));
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
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      fileType: $DocumentsTable.$converterfileType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_type'])!),
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size']),
      checksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum']),
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DocumentFileType, String, String>
      $converterfileType =
      const EnumNameConverter<DocumentFileType>(DocumentFileType.values);
}

class Document extends DataClass implements Insertable<Document> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String filePath;
  final DocumentFileType fileType;
  final int? fileSize;
  final String? checksum;
  const Document(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.title,
      required this.filePath,
      required this.fileType,
      this.fileSize,
      this.checksum});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['title'] = Variable<String>(title);
    map['file_path'] = Variable<String>(filePath);
    {
      map['file_type'] =
          Variable<String>($DocumentsTable.$converterfileType.toSql(fileType));
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      title: Value(title),
      filePath: Value(filePath),
      fileType: Value(fileType),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
    );
  }

  factory Document.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Document(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      title: serializer.fromJson<String>(json['title']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileType: $DocumentsTable.$converterfileType
          .fromJson(serializer.fromJson<String>(json['fileType'])),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      checksum: serializer.fromJson<String?>(json['checksum']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'title': serializer.toJson<String>(title),
      'filePath': serializer.toJson<String>(filePath),
      'fileType': serializer
          .toJson<String>($DocumentsTable.$converterfileType.toJson(fileType)),
      'fileSize': serializer.toJson<int?>(fileSize),
      'checksum': serializer.toJson<String?>(checksum),
    };
  }

  Document copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? title,
          String? filePath,
          DocumentFileType? fileType,
          Value<int?> fileSize = const Value.absent(),
          Value<String?> checksum = const Value.absent()}) =>
      Document(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        title: title ?? this.title,
        filePath: filePath ?? this.filePath,
        fileType: fileType ?? this.fileType,
        fileSize: fileSize.present ? fileSize.value : this.fileSize,
        checksum: checksum.present ? checksum.value : this.checksum,
      );
  Document copyWithCompanion(DocumentsCompanion data) {
    return Document(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      title: data.title.present ? data.title.value : this.title,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Document(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('fileType: $fileType, ')
          ..write('fileSize: $fileSize, ')
          ..write('checksum: $checksum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, createdAt, updatedAt, title, filePath, fileType, fileSize, checksum);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Document &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.fileType == this.fileType &&
          other.fileSize == this.fileSize &&
          other.checksum == this.checksum);
}

class DocumentsCompanion extends UpdateCompanion<Document> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> title;
  final Value<String> filePath;
  final Value<DocumentFileType> fileType;
  final Value<int?> fileSize;
  final Value<String?> checksum;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.checksum = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String title,
    required String filePath,
    required DocumentFileType fileType,
    this.fileSize = const Value.absent(),
    this.checksum = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        filePath = Value(filePath),
        fileType = Value(fileType);
  static Insertable<Document> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<String>? fileType,
    Expression<int>? fileSize,
    Expression<String>? checksum,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (fileType != null) 'file_type': fileType,
      if (fileSize != null) 'file_size': fileSize,
      if (checksum != null) 'checksum': checksum,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? title,
      Value<String>? filePath,
      Value<DocumentFileType>? fileType,
      Value<int?>? fileSize,
      Value<String?>? checksum,
      Value<int>? rowid}) {
    return DocumentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      checksum: checksum ?? this.checksum,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(
          $DocumentsTable.$converterfileType.toSql(fileType.value));
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
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
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('fileType: $fileType, ')
          ..write('fileSize: $fileSize, ')
          ..write('checksum: $checksum, ')
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
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, name, color];
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
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
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
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color']),
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
  final int? color;
  const Tag(
      {required this.id,
      required this.createdAt,
      required this.name,
      this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      name: Value(name),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int?>(color),
    };
  }

  Tag copyWith(
          {String? id,
          DateTime? createdAt,
          String? name,
          Value<int?> color = const Value.absent()}) =>
      Tag(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        color: color.present ? color.value : this.color,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.name == this.name &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> name;
  final Value<int?> color;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? name,
    Expression<int>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<String>? name,
      Value<int?>? color,
      Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      color: color ?? this.color,
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
    if (color.present) {
      map['color'] = Variable<int>(color.value);
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
          ..write('color: $color, ')
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

class $StatisticsTable extends Statistics
    with TableInfo<$StatisticsTable, Statistic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatisticsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 30, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _totalLinksMeta =
      const VerificationMeta('totalLinks');
  @override
  late final GeneratedColumn<int> totalLinks = GeneratedColumn<int>(
      'total_links', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalDocumentsMeta =
      const VerificationMeta('totalDocuments');
  @override
  late final GeneratedColumn<int> totalDocuments = GeneratedColumn<int>(
      'total_documents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalTagsMeta =
      const VerificationMeta('totalTags');
  @override
  late final GeneratedColumn<int> totalTags = GeneratedColumn<int>(
      'total_tags', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalFoldersMeta =
      const VerificationMeta('totalFolders');
  @override
  late final GeneratedColumn<int> totalFolders = GeneratedColumn<int>(
      'total_folders', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, recordedAt, totalLinks, totalDocuments, totalTags, totalFolders];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'statistics';
  @override
  VerificationContext validateIntegrity(Insertable<Statistic> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    }
    if (data.containsKey('total_links')) {
      context.handle(
          _totalLinksMeta,
          totalLinks.isAcceptableOrUnknown(
              data['total_links']!, _totalLinksMeta));
    }
    if (data.containsKey('total_documents')) {
      context.handle(
          _totalDocumentsMeta,
          totalDocuments.isAcceptableOrUnknown(
              data['total_documents']!, _totalDocumentsMeta));
    }
    if (data.containsKey('total_tags')) {
      context.handle(_totalTagsMeta,
          totalTags.isAcceptableOrUnknown(data['total_tags']!, _totalTagsMeta));
    }
    if (data.containsKey('total_folders')) {
      context.handle(
          _totalFoldersMeta,
          totalFolders.isAcceptableOrUnknown(
              data['total_folders']!, _totalFoldersMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Statistic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Statistic(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      totalLinks: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_links'])!,
      totalDocuments: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_documents'])!,
      totalTags: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_tags'])!,
      totalFolders: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_folders'])!,
    );
  }

  @override
  $StatisticsTable createAlias(String alias) {
    return $StatisticsTable(attachedDatabase, alias);
  }
}

class Statistic extends DataClass implements Insertable<Statistic> {
  final String id;
  final DateTime recordedAt;
  final int totalLinks;
  final int totalDocuments;
  final int totalTags;
  final int totalFolders;
  const Statistic(
      {required this.id,
      required this.recordedAt,
      required this.totalLinks,
      required this.totalDocuments,
      required this.totalTags,
      required this.totalFolders});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['total_links'] = Variable<int>(totalLinks);
    map['total_documents'] = Variable<int>(totalDocuments);
    map['total_tags'] = Variable<int>(totalTags);
    map['total_folders'] = Variable<int>(totalFolders);
    return map;
  }

  StatisticsCompanion toCompanion(bool nullToAbsent) {
    return StatisticsCompanion(
      id: Value(id),
      recordedAt: Value(recordedAt),
      totalLinks: Value(totalLinks),
      totalDocuments: Value(totalDocuments),
      totalTags: Value(totalTags),
      totalFolders: Value(totalFolders),
    );
  }

  factory Statistic.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Statistic(
      id: serializer.fromJson<String>(json['id']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      totalLinks: serializer.fromJson<int>(json['totalLinks']),
      totalDocuments: serializer.fromJson<int>(json['totalDocuments']),
      totalTags: serializer.fromJson<int>(json['totalTags']),
      totalFolders: serializer.fromJson<int>(json['totalFolders']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'totalLinks': serializer.toJson<int>(totalLinks),
      'totalDocuments': serializer.toJson<int>(totalDocuments),
      'totalTags': serializer.toJson<int>(totalTags),
      'totalFolders': serializer.toJson<int>(totalFolders),
    };
  }

  Statistic copyWith(
          {String? id,
          DateTime? recordedAt,
          int? totalLinks,
          int? totalDocuments,
          int? totalTags,
          int? totalFolders}) =>
      Statistic(
        id: id ?? this.id,
        recordedAt: recordedAt ?? this.recordedAt,
        totalLinks: totalLinks ?? this.totalLinks,
        totalDocuments: totalDocuments ?? this.totalDocuments,
        totalTags: totalTags ?? this.totalTags,
        totalFolders: totalFolders ?? this.totalFolders,
      );
  Statistic copyWithCompanion(StatisticsCompanion data) {
    return Statistic(
      id: data.id.present ? data.id.value : this.id,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      totalLinks:
          data.totalLinks.present ? data.totalLinks.value : this.totalLinks,
      totalDocuments: data.totalDocuments.present
          ? data.totalDocuments.value
          : this.totalDocuments,
      totalTags: data.totalTags.present ? data.totalTags.value : this.totalTags,
      totalFolders: data.totalFolders.present
          ? data.totalFolders.value
          : this.totalFolders,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Statistic(')
          ..write('id: $id, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('totalLinks: $totalLinks, ')
          ..write('totalDocuments: $totalDocuments, ')
          ..write('totalTags: $totalTags, ')
          ..write('totalFolders: $totalFolders')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, recordedAt, totalLinks, totalDocuments, totalTags, totalFolders);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Statistic &&
          other.id == this.id &&
          other.recordedAt == this.recordedAt &&
          other.totalLinks == this.totalLinks &&
          other.totalDocuments == this.totalDocuments &&
          other.totalTags == this.totalTags &&
          other.totalFolders == this.totalFolders);
}

class StatisticsCompanion extends UpdateCompanion<Statistic> {
  final Value<String> id;
  final Value<DateTime> recordedAt;
  final Value<int> totalLinks;
  final Value<int> totalDocuments;
  final Value<int> totalTags;
  final Value<int> totalFolders;
  final Value<int> rowid;
  const StatisticsCompanion({
    this.id = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.totalLinks = const Value.absent(),
    this.totalDocuments = const Value.absent(),
    this.totalTags = const Value.absent(),
    this.totalFolders = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatisticsCompanion.insert({
    required String id,
    this.recordedAt = const Value.absent(),
    this.totalLinks = const Value.absent(),
    this.totalDocuments = const Value.absent(),
    this.totalTags = const Value.absent(),
    this.totalFolders = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Statistic> custom({
    Expression<String>? id,
    Expression<DateTime>? recordedAt,
    Expression<int>? totalLinks,
    Expression<int>? totalDocuments,
    Expression<int>? totalTags,
    Expression<int>? totalFolders,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (totalLinks != null) 'total_links': totalLinks,
      if (totalDocuments != null) 'total_documents': totalDocuments,
      if (totalTags != null) 'total_tags': totalTags,
      if (totalFolders != null) 'total_folders': totalFolders,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatisticsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? recordedAt,
      Value<int>? totalLinks,
      Value<int>? totalDocuments,
      Value<int>? totalTags,
      Value<int>? totalFolders,
      Value<int>? rowid}) {
    return StatisticsCompanion(
      id: id ?? this.id,
      recordedAt: recordedAt ?? this.recordedAt,
      totalLinks: totalLinks ?? this.totalLinks,
      totalDocuments: totalDocuments ?? this.totalDocuments,
      totalTags: totalTags ?? this.totalTags,
      totalFolders: totalFolders ?? this.totalFolders,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (totalLinks.present) {
      map['total_links'] = Variable<int>(totalLinks.value);
    }
    if (totalDocuments.present) {
      map['total_documents'] = Variable<int>(totalDocuments.value);
    }
    if (totalTags.present) {
      map['total_tags'] = Variable<int>(totalTags.value);
    }
    if (totalFolders.present) {
      map['total_folders'] = Variable<int>(totalFolders.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatisticsCompanion(')
          ..write('id: $id, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('totalLinks: $totalLinks, ')
          ..write('totalDocuments: $totalDocuments, ')
          ..write('totalTags: $totalTags, ')
          ..write('totalFolders: $totalFolders, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityEventsTable extends ActivityEvents
    with TableInfo<$ActivityEventsTable, ActivityEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 30, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _occurredAtMeta =
      const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
      'occurred_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, occurredAt, eventType, entityType, entityId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_events';
  @override
  VerificationContext validateIntegrity(Insertable<ActivityEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
          _occurredAtMeta,
          occurredAt.isAcceptableOrUnknown(
              data['occurred_at']!, _occurredAtMeta));
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id']),
    );
  }

  @override
  $ActivityEventsTable createAlias(String alias) {
    return $ActivityEventsTable(attachedDatabase, alias);
  }
}

class ActivityEvent extends DataClass implements Insertable<ActivityEvent> {
  final String id;
  final DateTime occurredAt;
  final String eventType;
  final String entityType;
  final String? entityId;
  const ActivityEvent(
      {required this.id,
      required this.occurredAt,
      required this.eventType,
      required this.entityType,
      this.entityId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['event_type'] = Variable<String>(eventType);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    return map;
  }

  ActivityEventsCompanion toCompanion(bool nullToAbsent) {
    return ActivityEventsCompanion(
      id: Value(id),
      occurredAt: Value(occurredAt),
      eventType: Value(eventType),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
    );
  }

  factory ActivityEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityEvent(
      id: serializer.fromJson<String>(json['id']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      eventType: serializer.fromJson<String>(json['eventType']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String?>(json['entityId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'eventType': serializer.toJson<String>(eventType),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String?>(entityId),
    };
  }

  ActivityEvent copyWith(
          {String? id,
          DateTime? occurredAt,
          String? eventType,
          String? entityType,
          Value<String?> entityId = const Value.absent()}) =>
      ActivityEvent(
        id: id ?? this.id,
        occurredAt: occurredAt ?? this.occurredAt,
        eventType: eventType ?? this.eventType,
        entityType: entityType ?? this.entityType,
        entityId: entityId.present ? entityId.value : this.entityId,
      );
  ActivityEvent copyWithCompanion(ActivityEventsCompanion data) {
    return ActivityEvent(
      id: data.id.present ? data.id.value : this.id,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEvent(')
          ..write('id: $id, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('eventType: $eventType, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, occurredAt, eventType, entityType, entityId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityEvent &&
          other.id == this.id &&
          other.occurredAt == this.occurredAt &&
          other.eventType == this.eventType &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId);
}

class ActivityEventsCompanion extends UpdateCompanion<ActivityEvent> {
  final Value<String> id;
  final Value<DateTime> occurredAt;
  final Value<String> eventType;
  final Value<String> entityType;
  final Value<String?> entityId;
  final Value<int> rowid;
  const ActivityEventsCompanion({
    this.id = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.eventType = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityEventsCompanion.insert({
    required String id,
    this.occurredAt = const Value.absent(),
    required String eventType,
    required String entityType,
    this.entityId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        eventType = Value(eventType),
        entityType = Value(entityType);
  static Insertable<ActivityEvent> custom({
    Expression<String>? id,
    Expression<DateTime>? occurredAt,
    Expression<String>? eventType,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (eventType != null) 'event_type': eventType,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityEventsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? occurredAt,
      Value<String>? eventType,
      Value<String>? entityType,
      Value<String?>? entityId,
      Value<int>? rowid}) {
    return ActivityEventsCompanion(
      id: id ?? this.id,
      occurredAt: occurredAt ?? this.occurredAt,
      eventType: eventType ?? this.eventType,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEventsCompanion(')
          ..write('id: $id, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('eventType: $eventType, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentAccessTable extends RecentAccess
    with TableInfo<$RecentAccessTable, RecentAccessData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentAccessTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastAccessedAtMeta =
      const VerificationMeta('lastAccessedAt');
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>('last_accessed_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _accessCountMeta =
      const VerificationMeta('accessCount');
  @override
  late final GeneratedColumn<int> accessCount = GeneratedColumn<int>(
      'access_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns =>
      [entityId, entityType, lastAccessedAt, accessCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_access';
  @override
  VerificationContext validateIntegrity(Insertable<RecentAccessData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
          _lastAccessedAtMeta,
          lastAccessedAt.isAcceptableOrUnknown(
              data['last_accessed_at']!, _lastAccessedAtMeta));
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    if (data.containsKey('access_count')) {
      context.handle(
          _accessCountMeta,
          accessCount.isAcceptableOrUnknown(
              data['access_count']!, _accessCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityId, entityType};
  @override
  RecentAccessData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentAccessData(
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_accessed_at'])!,
      accessCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}access_count'])!,
    );
  }

  @override
  $RecentAccessTable createAlias(String alias) {
    return $RecentAccessTable(attachedDatabase, alias);
  }
}

class RecentAccessData extends DataClass
    implements Insertable<RecentAccessData> {
  final String entityId;
  final String entityType;
  final DateTime lastAccessedAt;
  final int accessCount;
  const RecentAccessData(
      {required this.entityId,
      required this.entityType,
      required this.lastAccessedAt,
      required this.accessCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_id'] = Variable<String>(entityId);
    map['entity_type'] = Variable<String>(entityType);
    map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    map['access_count'] = Variable<int>(accessCount);
    return map;
  }

  RecentAccessCompanion toCompanion(bool nullToAbsent) {
    return RecentAccessCompanion(
      entityId: Value(entityId),
      entityType: Value(entityType),
      lastAccessedAt: Value(lastAccessedAt),
      accessCount: Value(accessCount),
    );
  }

  factory RecentAccessData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentAccessData(
      entityId: serializer.fromJson<String>(json['entityId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      lastAccessedAt: serializer.fromJson<DateTime>(json['lastAccessedAt']),
      accessCount: serializer.fromJson<int>(json['accessCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityId': serializer.toJson<String>(entityId),
      'entityType': serializer.toJson<String>(entityType),
      'lastAccessedAt': serializer.toJson<DateTime>(lastAccessedAt),
      'accessCount': serializer.toJson<int>(accessCount),
    };
  }

  RecentAccessData copyWith(
          {String? entityId,
          String? entityType,
          DateTime? lastAccessedAt,
          int? accessCount}) =>
      RecentAccessData(
        entityId: entityId ?? this.entityId,
        entityType: entityType ?? this.entityType,
        lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
        accessCount: accessCount ?? this.accessCount,
      );
  RecentAccessData copyWithCompanion(RecentAccessCompanion data) {
    return RecentAccessData(
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
      accessCount:
          data.accessCount.present ? data.accessCount.value : this.accessCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentAccessData(')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('accessCount: $accessCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(entityId, entityType, lastAccessedAt, accessCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentAccessData &&
          other.entityId == this.entityId &&
          other.entityType == this.entityType &&
          other.lastAccessedAt == this.lastAccessedAt &&
          other.accessCount == this.accessCount);
}

class RecentAccessCompanion extends UpdateCompanion<RecentAccessData> {
  final Value<String> entityId;
  final Value<String> entityType;
  final Value<DateTime> lastAccessedAt;
  final Value<int> accessCount;
  final Value<int> rowid;
  const RecentAccessCompanion({
    this.entityId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.accessCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentAccessCompanion.insert({
    required String entityId,
    required String entityType,
    required DateTime lastAccessedAt,
    this.accessCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : entityId = Value(entityId),
        entityType = Value(entityType),
        lastAccessedAt = Value(lastAccessedAt);
  static Insertable<RecentAccessData> custom({
    Expression<String>? entityId,
    Expression<String>? entityType,
    Expression<DateTime>? lastAccessedAt,
    Expression<int>? accessCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityId != null) 'entity_id': entityId,
      if (entityType != null) 'entity_type': entityType,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (accessCount != null) 'access_count': accessCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentAccessCompanion copyWith(
      {Value<String>? entityId,
      Value<String>? entityType,
      Value<DateTime>? lastAccessedAt,
      Value<int>? accessCount,
      Value<int>? rowid}) {
    return RecentAccessCompanion(
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      accessCount: accessCount ?? this.accessCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (accessCount.present) {
      map['access_count'] = Variable<int>(accessCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentAccessCompanion(')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('accessCount: $accessCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WebMetadataEntriesTable extends WebMetadataEntries
    with TableInfo<$WebMetadataEntriesTable, WebMetadataEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WebMetadataEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _consecutiveUnchangedMeta =
      const VerificationMeta('consecutiveUnchanged');
  @override
  late final GeneratedColumn<int> consecutiveUnchanged = GeneratedColumn<int>(
      'consecutive_unchanged', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _ttlDaysMeta =
      const VerificationMeta('ttlDays');
  @override
  late final GeneratedColumn<int> ttlDays = GeneratedColumn<int>(
      'ttl_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(7));
  @override
  List<GeneratedColumn> get $columns => [
        url,
        title,
        description,
        image,
        fetchedAt,
        consecutiveUnchanged,
        ttlDays
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'web_metadata_entries';
  @override
  VerificationContext validateIntegrity(Insertable<WebMetadataEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('consecutive_unchanged')) {
      context.handle(
          _consecutiveUnchangedMeta,
          consecutiveUnchanged.isAcceptableOrUnknown(
              data['consecutive_unchanged']!, _consecutiveUnchangedMeta));
    }
    if (data.containsKey('ttl_days')) {
      context.handle(_ttlDaysMeta,
          ttlDays.isAcceptableOrUnknown(data['ttl_days']!, _ttlDaysMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  WebMetadataEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WebMetadataEntry(
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image']),
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
      consecutiveUnchanged: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}consecutive_unchanged'])!,
      ttlDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ttl_days'])!,
    );
  }

  @override
  $WebMetadataEntriesTable createAlias(String alias) {
    return $WebMetadataEntriesTable(attachedDatabase, alias);
  }
}

class WebMetadataEntry extends DataClass
    implements Insertable<WebMetadataEntry> {
  final String url;
  final String? title;
  final String? description;
  final String? image;
  final DateTime fetchedAt;
  final int consecutiveUnchanged;
  final int ttlDays;
  const WebMetadataEntry(
      {required this.url,
      this.title,
      this.description,
      this.image,
      required this.fetchedAt,
      required this.consecutiveUnchanged,
      required this.ttlDays});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<String>(image);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['consecutive_unchanged'] = Variable<int>(consecutiveUnchanged);
    map['ttl_days'] = Variable<int>(ttlDays);
    return map;
  }

  WebMetadataEntriesCompanion toCompanion(bool nullToAbsent) {
    return WebMetadataEntriesCompanion(
      url: Value(url),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      image:
          image == null && nullToAbsent ? const Value.absent() : Value(image),
      fetchedAt: Value(fetchedAt),
      consecutiveUnchanged: Value(consecutiveUnchanged),
      ttlDays: Value(ttlDays),
    );
  }

  factory WebMetadataEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WebMetadataEntry(
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      image: serializer.fromJson<String?>(json['image']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      consecutiveUnchanged:
          serializer.fromJson<int>(json['consecutiveUnchanged']),
      ttlDays: serializer.fromJson<int>(json['ttlDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'image': serializer.toJson<String?>(image),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'consecutiveUnchanged': serializer.toJson<int>(consecutiveUnchanged),
      'ttlDays': serializer.toJson<int>(ttlDays),
    };
  }

  WebMetadataEntry copyWith(
          {String? url,
          Value<String?> title = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> image = const Value.absent(),
          DateTime? fetchedAt,
          int? consecutiveUnchanged,
          int? ttlDays}) =>
      WebMetadataEntry(
        url: url ?? this.url,
        title: title.present ? title.value : this.title,
        description: description.present ? description.value : this.description,
        image: image.present ? image.value : this.image,
        fetchedAt: fetchedAt ?? this.fetchedAt,
        consecutiveUnchanged: consecutiveUnchanged ?? this.consecutiveUnchanged,
        ttlDays: ttlDays ?? this.ttlDays,
      );
  WebMetadataEntry copyWithCompanion(WebMetadataEntriesCompanion data) {
    return WebMetadataEntry(
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      image: data.image.present ? data.image.value : this.image,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      consecutiveUnchanged: data.consecutiveUnchanged.present
          ? data.consecutiveUnchanged.value
          : this.consecutiveUnchanged,
      ttlDays: data.ttlDays.present ? data.ttlDays.value : this.ttlDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WebMetadataEntry(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('image: $image, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('consecutiveUnchanged: $consecutiveUnchanged, ')
          ..write('ttlDays: $ttlDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      url, title, description, image, fetchedAt, consecutiveUnchanged, ttlDays);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WebMetadataEntry &&
          other.url == this.url &&
          other.title == this.title &&
          other.description == this.description &&
          other.image == this.image &&
          other.fetchedAt == this.fetchedAt &&
          other.consecutiveUnchanged == this.consecutiveUnchanged &&
          other.ttlDays == this.ttlDays);
}

class WebMetadataEntriesCompanion extends UpdateCompanion<WebMetadataEntry> {
  final Value<String> url;
  final Value<String?> title;
  final Value<String?> description;
  final Value<String?> image;
  final Value<DateTime> fetchedAt;
  final Value<int> consecutiveUnchanged;
  final Value<int> ttlDays;
  final Value<int> rowid;
  const WebMetadataEntriesCompanion({
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.image = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.consecutiveUnchanged = const Value.absent(),
    this.ttlDays = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WebMetadataEntriesCompanion.insert({
    required String url,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.image = const Value.absent(),
    required DateTime fetchedAt,
    this.consecutiveUnchanged = const Value.absent(),
    this.ttlDays = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : url = Value(url),
        fetchedAt = Value(fetchedAt);
  static Insertable<WebMetadataEntry> custom({
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? image,
    Expression<DateTime>? fetchedAt,
    Expression<int>? consecutiveUnchanged,
    Expression<int>? ttlDays,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (consecutiveUnchanged != null)
        'consecutive_unchanged': consecutiveUnchanged,
      if (ttlDays != null) 'ttl_days': ttlDays,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WebMetadataEntriesCompanion copyWith(
      {Value<String>? url,
      Value<String?>? title,
      Value<String?>? description,
      Value<String?>? image,
      Value<DateTime>? fetchedAt,
      Value<int>? consecutiveUnchanged,
      Value<int>? ttlDays,
      Value<int>? rowid}) {
    return WebMetadataEntriesCompanion(
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      consecutiveUnchanged: consecutiveUnchanged ?? this.consecutiveUnchanged,
      ttlDays: ttlDays ?? this.ttlDays,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (consecutiveUnchanged.present) {
      map['consecutive_unchanged'] = Variable<int>(consecutiveUnchanged.value);
    }
    if (ttlDays.present) {
      map['ttl_days'] = Variable<int>(ttlDays.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WebMetadataEntriesCompanion(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('image: $image, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('consecutiveUnchanged: $consecutiveUnchanged, ')
          ..write('ttlDays: $ttlDays, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArchiveJobsTable extends ArchiveJobs
    with TableInfo<$ArchiveJobsTable, ArchiveJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArchiveJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 30, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _linkIdMeta = const VerificationMeta('linkId');
  @override
  late final GeneratedColumn<String> linkId = GeneratedColumn<String>(
      'link_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceMeta =
      const VerificationMeta('service');
  @override
  late final GeneratedColumn<String> service = GeneratedColumn<String>(
      'service', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant("queued"));
  static const VerificationMeta _resultUrlMeta =
      const VerificationMeta('resultUrl');
  @override
  late final GeneratedColumn<String> resultUrl = GeneratedColumn<String>(
      'result_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        linkId,
        url,
        service,
        status,
        resultUrl,
        error,
        attempts,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'archive_jobs';
  @override
  VerificationContext validateIntegrity(Insertable<ArchiveJob> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('link_id')) {
      context.handle(_linkIdMeta,
          linkId.isAcceptableOrUnknown(data['link_id']!, _linkIdMeta));
    } else if (isInserting) {
      context.missing(_linkIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('service')) {
      context.handle(_serviceMeta,
          service.isAcceptableOrUnknown(data['service']!, _serviceMeta));
    } else if (isInserting) {
      context.missing(_serviceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('result_url')) {
      context.handle(_resultUrlMeta,
          resultUrl.isAcceptableOrUnknown(data['result_url']!, _resultUrlMeta));
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArchiveJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArchiveJob(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      linkId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}link_id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      service: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      resultUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result_url']),
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ArchiveJobsTable createAlias(String alias) {
    return $ArchiveJobsTable(attachedDatabase, alias);
  }
}

class ArchiveJob extends DataClass implements Insertable<ArchiveJob> {
  final String id;
  final String linkId;
  final String url;
  final String service;
  final String status;
  final String? resultUrl;
  final String? error;
  final int attempts;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ArchiveJob(
      {required this.id,
      required this.linkId,
      required this.url,
      required this.service,
      required this.status,
      this.resultUrl,
      this.error,
      required this.attempts,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['link_id'] = Variable<String>(linkId);
    map['url'] = Variable<String>(url);
    map['service'] = Variable<String>(service);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || resultUrl != null) {
      map['result_url'] = Variable<String>(resultUrl);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ArchiveJobsCompanion toCompanion(bool nullToAbsent) {
    return ArchiveJobsCompanion(
      id: Value(id),
      linkId: Value(linkId),
      url: Value(url),
      service: Value(service),
      status: Value(status),
      resultUrl: resultUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(resultUrl),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ArchiveJob.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArchiveJob(
      id: serializer.fromJson<String>(json['id']),
      linkId: serializer.fromJson<String>(json['linkId']),
      url: serializer.fromJson<String>(json['url']),
      service: serializer.fromJson<String>(json['service']),
      status: serializer.fromJson<String>(json['status']),
      resultUrl: serializer.fromJson<String?>(json['resultUrl']),
      error: serializer.fromJson<String?>(json['error']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'linkId': serializer.toJson<String>(linkId),
      'url': serializer.toJson<String>(url),
      'service': serializer.toJson<String>(service),
      'status': serializer.toJson<String>(status),
      'resultUrl': serializer.toJson<String?>(resultUrl),
      'error': serializer.toJson<String?>(error),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ArchiveJob copyWith(
          {String? id,
          String? linkId,
          String? url,
          String? service,
          String? status,
          Value<String?> resultUrl = const Value.absent(),
          Value<String?> error = const Value.absent(),
          int? attempts,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ArchiveJob(
        id: id ?? this.id,
        linkId: linkId ?? this.linkId,
        url: url ?? this.url,
        service: service ?? this.service,
        status: status ?? this.status,
        resultUrl: resultUrl.present ? resultUrl.value : this.resultUrl,
        error: error.present ? error.value : this.error,
        attempts: attempts ?? this.attempts,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ArchiveJob copyWithCompanion(ArchiveJobsCompanion data) {
    return ArchiveJob(
      id: data.id.present ? data.id.value : this.id,
      linkId: data.linkId.present ? data.linkId.value : this.linkId,
      url: data.url.present ? data.url.value : this.url,
      service: data.service.present ? data.service.value : this.service,
      status: data.status.present ? data.status.value : this.status,
      resultUrl: data.resultUrl.present ? data.resultUrl.value : this.resultUrl,
      error: data.error.present ? data.error.value : this.error,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArchiveJob(')
          ..write('id: $id, ')
          ..write('linkId: $linkId, ')
          ..write('url: $url, ')
          ..write('service: $service, ')
          ..write('status: $status, ')
          ..write('resultUrl: $resultUrl, ')
          ..write('error: $error, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, linkId, url, service, status, resultUrl,
      error, attempts, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArchiveJob &&
          other.id == this.id &&
          other.linkId == this.linkId &&
          other.url == this.url &&
          other.service == this.service &&
          other.status == this.status &&
          other.resultUrl == this.resultUrl &&
          other.error == this.error &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ArchiveJobsCompanion extends UpdateCompanion<ArchiveJob> {
  final Value<String> id;
  final Value<String> linkId;
  final Value<String> url;
  final Value<String> service;
  final Value<String> status;
  final Value<String?> resultUrl;
  final Value<String?> error;
  final Value<int> attempts;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ArchiveJobsCompanion({
    this.id = const Value.absent(),
    this.linkId = const Value.absent(),
    this.url = const Value.absent(),
    this.service = const Value.absent(),
    this.status = const Value.absent(),
    this.resultUrl = const Value.absent(),
    this.error = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArchiveJobsCompanion.insert({
    required String id,
    required String linkId,
    required String url,
    required String service,
    this.status = const Value.absent(),
    this.resultUrl = const Value.absent(),
    this.error = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        linkId = Value(linkId),
        url = Value(url),
        service = Value(service);
  static Insertable<ArchiveJob> custom({
    Expression<String>? id,
    Expression<String>? linkId,
    Expression<String>? url,
    Expression<String>? service,
    Expression<String>? status,
    Expression<String>? resultUrl,
    Expression<String>? error,
    Expression<int>? attempts,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (linkId != null) 'link_id': linkId,
      if (url != null) 'url': url,
      if (service != null) 'service': service,
      if (status != null) 'status': status,
      if (resultUrl != null) 'result_url': resultUrl,
      if (error != null) 'error': error,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArchiveJobsCompanion copyWith(
      {Value<String>? id,
      Value<String>? linkId,
      Value<String>? url,
      Value<String>? service,
      Value<String>? status,
      Value<String?>? resultUrl,
      Value<String?>? error,
      Value<int>? attempts,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ArchiveJobsCompanion(
      id: id ?? this.id,
      linkId: linkId ?? this.linkId,
      url: url ?? this.url,
      service: service ?? this.service,
      status: status ?? this.status,
      resultUrl: resultUrl ?? this.resultUrl,
      error: error ?? this.error,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (linkId.present) {
      map['link_id'] = Variable<String>(linkId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (resultUrl.present) {
      map['result_url'] = Variable<String>(resultUrl.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArchiveJobsCompanion(')
          ..write('id: $id, ')
          ..write('linkId: $linkId, ')
          ..write('url: $url, ')
          ..write('service: $service, ')
          ..write('status: $status, ')
          ..write('resultUrl: $resultUrl, ')
          ..write('error: $error, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $StatisticsTable statistics = $StatisticsTable(this);
  late final $ActivityEventsTable activityEvents = $ActivityEventsTable(this);
  late final $RecentAccessTable recentAccess = $RecentAccessTable(this);
  late final $WebMetadataEntriesTable webMetadataEntries =
      $WebMetadataEntriesTable(this);
  late final $ArchiveJobsTable archiveJobs = $ArchiveJobsTable(this);
  late final Index folderTitle =
      Index('folder_title', 'CREATE INDEX folder_title ON folders (title)');
  late final Index documentTitle = Index(
      'document_title', 'CREATE INDEX document_title ON documents (title)');
  late final Index itemsFolderItemIdx = Index('items_folder_item_idx',
      'CREATE UNIQUE INDEX items_folder_item_idx ON items (folder_id, item_id)');
  late final Index metadataRecordsItemIdx = Index('metadata_records_item_idx',
      'CREATE INDEX metadata_records_item_idx ON metadata_records (item_id)');
  late final Index activityEventsOccurredIdx = Index(
      'activity_events_occurred_idx',
      'CREATE INDEX activity_events_occurred_idx ON activity_events (occurred_at)');
  late final Index archiveJobsStatusCreatedIdx = Index(
      'archive_jobs_status_created_idx',
      'CREATE INDEX archive_jobs_status_created_idx ON archive_jobs (status, created_at)');
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
        statistics,
        activityEvents,
        recentAccess,
        webMetadataEntries,
        archiveJobs,
        folderTitle,
        documentTitle,
        itemsFolderItemIdx,
        metadataRecordsItemIdx,
        activityEventsOccurredIdx,
        archiveJobsStatusCreatedIdx
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$FoldersTableCreateCompanionBuilder = FoldersCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required String title,
  required String description,
  Value<int?> color,
  Value<int> rowid,
});
typedef $$FoldersTableUpdateCompanionBuilder = FoldersCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> title,
  Value<String> description,
  Value<int?> color,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

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
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int?> color = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FoldersCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            title: title,
            description: description,
            color: color,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            required String title,
            required String description,
            Value<int?> color = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FoldersCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            title: title,
            description: description,
            color: color,
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
  Value<DateTime> updatedAt,
  required String title,
  required String filePath,
  required DocumentFileType fileType,
  Value<int?> fileSize,
  Value<String?> checksum,
  Value<int> rowid,
});
typedef $$DocumentsTableUpdateCompanionBuilder = DocumentsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> title,
  Value<String> filePath,
  Value<DocumentFileType> fileType,
  Value<int?> fileSize,
  Value<String?> checksum,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DocumentFileType, DocumentFileType, String>
      get fileType => $composableBuilder(
          column: $table.fileType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileType => $composableBuilder(
      column: $table.fileType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DocumentFileType, String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);
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
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<DocumentFileType> fileType = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<String?> checksum = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            title: title,
            filePath: filePath,
            fileType: fileType,
            fileSize: fileSize,
            checksum: checksum,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            required String title,
            required String filePath,
            required DocumentFileType fileType,
            Value<int?> fileSize = const Value.absent(),
            Value<String?> checksum = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            title: title,
            filePath: filePath,
            fileType: fileType,
            fileSize: fileSize,
            checksum: checksum,
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
  Value<int?> color,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<String> name,
  Value<int?> color,
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

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);
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
            Value<int?> color = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            createdAt: createdAt,
            name: name,
            color: color,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            required String name,
            Value<int?> color = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            createdAt: createdAt,
            name: name,
            color: color,
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
typedef $$StatisticsTableCreateCompanionBuilder = StatisticsCompanion Function({
  required String id,
  Value<DateTime> recordedAt,
  Value<int> totalLinks,
  Value<int> totalDocuments,
  Value<int> totalTags,
  Value<int> totalFolders,
  Value<int> rowid,
});
typedef $$StatisticsTableUpdateCompanionBuilder = StatisticsCompanion Function({
  Value<String> id,
  Value<DateTime> recordedAt,
  Value<int> totalLinks,
  Value<int> totalDocuments,
  Value<int> totalTags,
  Value<int> totalFolders,
  Value<int> rowid,
});

class $$StatisticsTableFilterComposer
    extends Composer<_$AppDatabase, $StatisticsTable> {
  $$StatisticsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalLinks => $composableBuilder(
      column: $table.totalLinks, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalDocuments => $composableBuilder(
      column: $table.totalDocuments,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalTags => $composableBuilder(
      column: $table.totalTags, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalFolders => $composableBuilder(
      column: $table.totalFolders, builder: (column) => ColumnFilters(column));
}

class $$StatisticsTableOrderingComposer
    extends Composer<_$AppDatabase, $StatisticsTable> {
  $$StatisticsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalLinks => $composableBuilder(
      column: $table.totalLinks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalDocuments => $composableBuilder(
      column: $table.totalDocuments,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalTags => $composableBuilder(
      column: $table.totalTags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalFolders => $composableBuilder(
      column: $table.totalFolders,
      builder: (column) => ColumnOrderings(column));
}

class $$StatisticsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatisticsTable> {
  $$StatisticsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<int> get totalLinks => $composableBuilder(
      column: $table.totalLinks, builder: (column) => column);

  GeneratedColumn<int> get totalDocuments => $composableBuilder(
      column: $table.totalDocuments, builder: (column) => column);

  GeneratedColumn<int> get totalTags =>
      $composableBuilder(column: $table.totalTags, builder: (column) => column);

  GeneratedColumn<int> get totalFolders => $composableBuilder(
      column: $table.totalFolders, builder: (column) => column);
}

class $$StatisticsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StatisticsTable,
    Statistic,
    $$StatisticsTableFilterComposer,
    $$StatisticsTableOrderingComposer,
    $$StatisticsTableAnnotationComposer,
    $$StatisticsTableCreateCompanionBuilder,
    $$StatisticsTableUpdateCompanionBuilder,
    (Statistic, BaseReferences<_$AppDatabase, $StatisticsTable, Statistic>),
    Statistic,
    PrefetchHooks Function()> {
  $$StatisticsTableTableManager(_$AppDatabase db, $StatisticsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatisticsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatisticsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatisticsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<int> totalLinks = const Value.absent(),
            Value<int> totalDocuments = const Value.absent(),
            Value<int> totalTags = const Value.absent(),
            Value<int> totalFolders = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StatisticsCompanion(
            id: id,
            recordedAt: recordedAt,
            totalLinks: totalLinks,
            totalDocuments: totalDocuments,
            totalTags: totalTags,
            totalFolders: totalFolders,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> recordedAt = const Value.absent(),
            Value<int> totalLinks = const Value.absent(),
            Value<int> totalDocuments = const Value.absent(),
            Value<int> totalTags = const Value.absent(),
            Value<int> totalFolders = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StatisticsCompanion.insert(
            id: id,
            recordedAt: recordedAt,
            totalLinks: totalLinks,
            totalDocuments: totalDocuments,
            totalTags: totalTags,
            totalFolders: totalFolders,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StatisticsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StatisticsTable,
    Statistic,
    $$StatisticsTableFilterComposer,
    $$StatisticsTableOrderingComposer,
    $$StatisticsTableAnnotationComposer,
    $$StatisticsTableCreateCompanionBuilder,
    $$StatisticsTableUpdateCompanionBuilder,
    (Statistic, BaseReferences<_$AppDatabase, $StatisticsTable, Statistic>),
    Statistic,
    PrefetchHooks Function()>;
typedef $$ActivityEventsTableCreateCompanionBuilder = ActivityEventsCompanion
    Function({
  required String id,
  Value<DateTime> occurredAt,
  required String eventType,
  required String entityType,
  Value<String?> entityId,
  Value<int> rowid,
});
typedef $$ActivityEventsTableUpdateCompanionBuilder = ActivityEventsCompanion
    Function({
  Value<String> id,
  Value<DateTime> occurredAt,
  Value<String> eventType,
  Value<String> entityType,
  Value<String?> entityId,
  Value<int> rowid,
});

class $$ActivityEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));
}

class $$ActivityEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));
}

class $$ActivityEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);
}

class $$ActivityEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityEventsTable,
    ActivityEvent,
    $$ActivityEventsTableFilterComposer,
    $$ActivityEventsTableOrderingComposer,
    $$ActivityEventsTableAnnotationComposer,
    $$ActivityEventsTableCreateCompanionBuilder,
    $$ActivityEventsTableUpdateCompanionBuilder,
    (
      ActivityEvent,
      BaseReferences<_$AppDatabase, $ActivityEventsTable, ActivityEvent>
    ),
    ActivityEvent,
    PrefetchHooks Function()> {
  $$ActivityEventsTableTableManager(
      _$AppDatabase db, $ActivityEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String?> entityId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityEventsCompanion(
            id: id,
            occurredAt: occurredAt,
            eventType: eventType,
            entityType: entityType,
            entityId: entityId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> occurredAt = const Value.absent(),
            required String eventType,
            required String entityType,
            Value<String?> entityId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityEventsCompanion.insert(
            id: id,
            occurredAt: occurredAt,
            eventType: eventType,
            entityType: entityType,
            entityId: entityId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ActivityEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivityEventsTable,
    ActivityEvent,
    $$ActivityEventsTableFilterComposer,
    $$ActivityEventsTableOrderingComposer,
    $$ActivityEventsTableAnnotationComposer,
    $$ActivityEventsTableCreateCompanionBuilder,
    $$ActivityEventsTableUpdateCompanionBuilder,
    (
      ActivityEvent,
      BaseReferences<_$AppDatabase, $ActivityEventsTable, ActivityEvent>
    ),
    ActivityEvent,
    PrefetchHooks Function()>;
typedef $$RecentAccessTableCreateCompanionBuilder = RecentAccessCompanion
    Function({
  required String entityId,
  required String entityType,
  required DateTime lastAccessedAt,
  Value<int> accessCount,
  Value<int> rowid,
});
typedef $$RecentAccessTableUpdateCompanionBuilder = RecentAccessCompanion
    Function({
  Value<String> entityId,
  Value<String> entityType,
  Value<DateTime> lastAccessedAt,
  Value<int> accessCount,
  Value<int> rowid,
});

class $$RecentAccessTableFilterComposer
    extends Composer<_$AppDatabase, $RecentAccessTable> {
  $$RecentAccessTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accessCount => $composableBuilder(
      column: $table.accessCount, builder: (column) => ColumnFilters(column));
}

class $$RecentAccessTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentAccessTable> {
  $$RecentAccessTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accessCount => $composableBuilder(
      column: $table.accessCount, builder: (column) => ColumnOrderings(column));
}

class $$RecentAccessTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentAccessTable> {
  $$RecentAccessTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt, builder: (column) => column);

  GeneratedColumn<int> get accessCount => $composableBuilder(
      column: $table.accessCount, builder: (column) => column);
}

class $$RecentAccessTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecentAccessTable,
    RecentAccessData,
    $$RecentAccessTableFilterComposer,
    $$RecentAccessTableOrderingComposer,
    $$RecentAccessTableAnnotationComposer,
    $$RecentAccessTableCreateCompanionBuilder,
    $$RecentAccessTableUpdateCompanionBuilder,
    (
      RecentAccessData,
      BaseReferences<_$AppDatabase, $RecentAccessTable, RecentAccessData>
    ),
    RecentAccessData,
    PrefetchHooks Function()> {
  $$RecentAccessTableTableManager(_$AppDatabase db, $RecentAccessTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentAccessTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentAccessTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentAccessTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entityId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<DateTime> lastAccessedAt = const Value.absent(),
            Value<int> accessCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecentAccessCompanion(
            entityId: entityId,
            entityType: entityType,
            lastAccessedAt: lastAccessedAt,
            accessCount: accessCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entityId,
            required String entityType,
            required DateTime lastAccessedAt,
            Value<int> accessCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecentAccessCompanion.insert(
            entityId: entityId,
            entityType: entityType,
            lastAccessedAt: lastAccessedAt,
            accessCount: accessCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecentAccessTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecentAccessTable,
    RecentAccessData,
    $$RecentAccessTableFilterComposer,
    $$RecentAccessTableOrderingComposer,
    $$RecentAccessTableAnnotationComposer,
    $$RecentAccessTableCreateCompanionBuilder,
    $$RecentAccessTableUpdateCompanionBuilder,
    (
      RecentAccessData,
      BaseReferences<_$AppDatabase, $RecentAccessTable, RecentAccessData>
    ),
    RecentAccessData,
    PrefetchHooks Function()>;
typedef $$WebMetadataEntriesTableCreateCompanionBuilder
    = WebMetadataEntriesCompanion Function({
  required String url,
  Value<String?> title,
  Value<String?> description,
  Value<String?> image,
  required DateTime fetchedAt,
  Value<int> consecutiveUnchanged,
  Value<int> ttlDays,
  Value<int> rowid,
});
typedef $$WebMetadataEntriesTableUpdateCompanionBuilder
    = WebMetadataEntriesCompanion Function({
  Value<String> url,
  Value<String?> title,
  Value<String?> description,
  Value<String?> image,
  Value<DateTime> fetchedAt,
  Value<int> consecutiveUnchanged,
  Value<int> ttlDays,
  Value<int> rowid,
});

class $$WebMetadataEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WebMetadataEntriesTable> {
  $$WebMetadataEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get consecutiveUnchanged => $composableBuilder(
      column: $table.consecutiveUnchanged,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ttlDays => $composableBuilder(
      column: $table.ttlDays, builder: (column) => ColumnFilters(column));
}

class $$WebMetadataEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WebMetadataEntriesTable> {
  $$WebMetadataEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get consecutiveUnchanged => $composableBuilder(
      column: $table.consecutiveUnchanged,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ttlDays => $composableBuilder(
      column: $table.ttlDays, builder: (column) => ColumnOrderings(column));
}

class $$WebMetadataEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WebMetadataEntriesTable> {
  $$WebMetadataEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<int> get consecutiveUnchanged => $composableBuilder(
      column: $table.consecutiveUnchanged, builder: (column) => column);

  GeneratedColumn<int> get ttlDays =>
      $composableBuilder(column: $table.ttlDays, builder: (column) => column);
}

class $$WebMetadataEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WebMetadataEntriesTable,
    WebMetadataEntry,
    $$WebMetadataEntriesTableFilterComposer,
    $$WebMetadataEntriesTableOrderingComposer,
    $$WebMetadataEntriesTableAnnotationComposer,
    $$WebMetadataEntriesTableCreateCompanionBuilder,
    $$WebMetadataEntriesTableUpdateCompanionBuilder,
    (
      WebMetadataEntry,
      BaseReferences<_$AppDatabase, $WebMetadataEntriesTable, WebMetadataEntry>
    ),
    WebMetadataEntry,
    PrefetchHooks Function()> {
  $$WebMetadataEntriesTableTableManager(
      _$AppDatabase db, $WebMetadataEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WebMetadataEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WebMetadataEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WebMetadataEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> url = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> image = const Value.absent(),
            Value<DateTime> fetchedAt = const Value.absent(),
            Value<int> consecutiveUnchanged = const Value.absent(),
            Value<int> ttlDays = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WebMetadataEntriesCompanion(
            url: url,
            title: title,
            description: description,
            image: image,
            fetchedAt: fetchedAt,
            consecutiveUnchanged: consecutiveUnchanged,
            ttlDays: ttlDays,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String url,
            Value<String?> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> image = const Value.absent(),
            required DateTime fetchedAt,
            Value<int> consecutiveUnchanged = const Value.absent(),
            Value<int> ttlDays = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WebMetadataEntriesCompanion.insert(
            url: url,
            title: title,
            description: description,
            image: image,
            fetchedAt: fetchedAt,
            consecutiveUnchanged: consecutiveUnchanged,
            ttlDays: ttlDays,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WebMetadataEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WebMetadataEntriesTable,
    WebMetadataEntry,
    $$WebMetadataEntriesTableFilterComposer,
    $$WebMetadataEntriesTableOrderingComposer,
    $$WebMetadataEntriesTableAnnotationComposer,
    $$WebMetadataEntriesTableCreateCompanionBuilder,
    $$WebMetadataEntriesTableUpdateCompanionBuilder,
    (
      WebMetadataEntry,
      BaseReferences<_$AppDatabase, $WebMetadataEntriesTable, WebMetadataEntry>
    ),
    WebMetadataEntry,
    PrefetchHooks Function()>;
typedef $$ArchiveJobsTableCreateCompanionBuilder = ArchiveJobsCompanion
    Function({
  required String id,
  required String linkId,
  required String url,
  required String service,
  Value<String> status,
  Value<String?> resultUrl,
  Value<String?> error,
  Value<int> attempts,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ArchiveJobsTableUpdateCompanionBuilder = ArchiveJobsCompanion
    Function({
  Value<String> id,
  Value<String> linkId,
  Value<String> url,
  Value<String> service,
  Value<String> status,
  Value<String?> resultUrl,
  Value<String?> error,
  Value<int> attempts,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ArchiveJobsTableFilterComposer
    extends Composer<_$AppDatabase, $ArchiveJobsTable> {
  $$ArchiveJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkId => $composableBuilder(
      column: $table.linkId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get service => $composableBuilder(
      column: $table.service, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultUrl => $composableBuilder(
      column: $table.resultUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ArchiveJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $ArchiveJobsTable> {
  $$ArchiveJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkId => $composableBuilder(
      column: $table.linkId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get service => $composableBuilder(
      column: $table.service, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultUrl => $composableBuilder(
      column: $table.resultUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ArchiveJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArchiveJobsTable> {
  $$ArchiveJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get linkId =>
      $composableBuilder(column: $table.linkId, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get resultUrl =>
      $composableBuilder(column: $table.resultUrl, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ArchiveJobsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ArchiveJobsTable,
    ArchiveJob,
    $$ArchiveJobsTableFilterComposer,
    $$ArchiveJobsTableOrderingComposer,
    $$ArchiveJobsTableAnnotationComposer,
    $$ArchiveJobsTableCreateCompanionBuilder,
    $$ArchiveJobsTableUpdateCompanionBuilder,
    (ArchiveJob, BaseReferences<_$AppDatabase, $ArchiveJobsTable, ArchiveJob>),
    ArchiveJob,
    PrefetchHooks Function()> {
  $$ArchiveJobsTableTableManager(_$AppDatabase db, $ArchiveJobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArchiveJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArchiveJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArchiveJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> linkId = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> service = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> resultUrl = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ArchiveJobsCompanion(
            id: id,
            linkId: linkId,
            url: url,
            service: service,
            status: status,
            resultUrl: resultUrl,
            error: error,
            attempts: attempts,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String linkId,
            required String url,
            required String service,
            Value<String> status = const Value.absent(),
            Value<String?> resultUrl = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ArchiveJobsCompanion.insert(
            id: id,
            linkId: linkId,
            url: url,
            service: service,
            status: status,
            resultUrl: resultUrl,
            error: error,
            attempts: attempts,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ArchiveJobsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ArchiveJobsTable,
    ArchiveJob,
    $$ArchiveJobsTableFilterComposer,
    $$ArchiveJobsTableOrderingComposer,
    $$ArchiveJobsTableAnnotationComposer,
    $$ArchiveJobsTableCreateCompanionBuilder,
    $$ArchiveJobsTableUpdateCompanionBuilder,
    (ArchiveJob, BaseReferences<_$AppDatabase, $ArchiveJobsTable, ArchiveJob>),
    ArchiveJob,
    PrefetchHooks Function()>;

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
  $$StatisticsTableTableManager get statistics =>
      $$StatisticsTableTableManager(_db, _db.statistics);
  $$ActivityEventsTableTableManager get activityEvents =>
      $$ActivityEventsTableTableManager(_db, _db.activityEvents);
  $$RecentAccessTableTableManager get recentAccess =>
      $$RecentAccessTableTableManager(_db, _db.recentAccess);
  $$WebMetadataEntriesTableTableManager get webMetadataEntries =>
      $$WebMetadataEntriesTableTableManager(_db, _db.webMetadataEntries);
  $$ArchiveJobsTableTableManager get archiveJobs =>
      $$ArchiveJobsTableTableManager(_db, _db.archiveJobs);
}
