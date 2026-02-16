// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

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
  late final Index folderTitle =
      Index('folder_title', 'CREATE INDEX folder_title ON folders (title)');
  late final Index documentTitle = Index(
      'document_title', 'CREATE INDEX document_title ON documents (title)');
  late final Index itemsFolderItemIdx = Index('items_folder_item_idx',
      'CREATE UNIQUE INDEX items_folder_item_idx ON items (folder_id, item_id)');
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
}

class $ThemeTypesTable extends ThemeTypes
    with TableInfo<$ThemeTypesTable, ThemeTypeEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThemeTypesTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'theme_types';
  @override
  VerificationContext validateIntegrity(Insertable<ThemeTypeEntity> instance,
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
  ThemeTypeEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThemeTypeEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $ThemeTypesTable createAlias(String alias) {
    return $ThemeTypesTable(attachedDatabase, alias);
  }
}

class ThemeTypeEntity extends DataClass implements Insertable<ThemeTypeEntity> {
  final int id;
  final String name;
  const ThemeTypeEntity({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ThemeTypesCompanion toCompanion(bool nullToAbsent) {
    return ThemeTypesCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory ThemeTypeEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThemeTypeEntity(
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

  ThemeTypeEntity copyWith({int? id, String? name}) => ThemeTypeEntity(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  ThemeTypeEntity copyWithCompanion(ThemeTypesCompanion data) {
    return ThemeTypeEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThemeTypeEntity(')
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
      (other is ThemeTypeEntity &&
          other.id == this.id &&
          other.name == this.name);
}

class ThemeTypesCompanion extends UpdateCompanion<ThemeTypeEntity> {
  final Value<int> id;
  final Value<String> name;
  const ThemeTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  ThemeTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<ThemeTypeEntity> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  ThemeTypesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return ThemeTypesCompanion(
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
    return (StringBuffer('ThemeTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $TimeDisplayFormatsTable extends TimeDisplayFormats
    with TableInfo<$TimeDisplayFormatsTable, TimeDisplayFormatEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeDisplayFormatsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'time_display_formats';
  @override
  VerificationContext validateIntegrity(
      Insertable<TimeDisplayFormatEntity> instance,
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
  TimeDisplayFormatEntity map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeDisplayFormatEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $TimeDisplayFormatsTable createAlias(String alias) {
    return $TimeDisplayFormatsTable(attachedDatabase, alias);
  }
}

class TimeDisplayFormatEntity extends DataClass
    implements Insertable<TimeDisplayFormatEntity> {
  final int id;
  final String name;
  const TimeDisplayFormatEntity({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TimeDisplayFormatsCompanion toCompanion(bool nullToAbsent) {
    return TimeDisplayFormatsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory TimeDisplayFormatEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeDisplayFormatEntity(
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

  TimeDisplayFormatEntity copyWith({int? id, String? name}) =>
      TimeDisplayFormatEntity(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  TimeDisplayFormatEntity copyWithCompanion(TimeDisplayFormatsCompanion data) {
    return TimeDisplayFormatEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeDisplayFormatEntity(')
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
      (other is TimeDisplayFormatEntity &&
          other.id == this.id &&
          other.name == this.name);
}

class TimeDisplayFormatsCompanion
    extends UpdateCompanion<TimeDisplayFormatEntity> {
  final Value<int> id;
  final Value<String> name;
  const TimeDisplayFormatsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TimeDisplayFormatsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<TimeDisplayFormatEntity> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TimeDisplayFormatsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return TimeDisplayFormatsCompanion(
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
    return (StringBuffer('TimeDisplayFormatsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ItemClickActionsTable extends ItemClickActions
    with TableInfo<$ItemClickActionsTable, ItemClickActionEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemClickActionsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'item_click_actions';
  @override
  VerificationContext validateIntegrity(
      Insertable<ItemClickActionEntity> instance,
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
  ItemClickActionEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemClickActionEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $ItemClickActionsTable createAlias(String alias) {
    return $ItemClickActionsTable(attachedDatabase, alias);
  }
}

class ItemClickActionEntity extends DataClass
    implements Insertable<ItemClickActionEntity> {
  final int id;
  final String name;
  const ItemClickActionEntity({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ItemClickActionsCompanion toCompanion(bool nullToAbsent) {
    return ItemClickActionsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory ItemClickActionEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemClickActionEntity(
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

  ItemClickActionEntity copyWith({int? id, String? name}) =>
      ItemClickActionEntity(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  ItemClickActionEntity copyWithCompanion(ItemClickActionsCompanion data) {
    return ItemClickActionEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemClickActionEntity(')
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
      (other is ItemClickActionEntity &&
          other.id == this.id &&
          other.name == this.name);
}

class ItemClickActionsCompanion extends UpdateCompanion<ItemClickActionEntity> {
  final Value<int> id;
  final Value<String> name;
  const ItemClickActionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  ItemClickActionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<ItemClickActionEntity> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  ItemClickActionsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return ItemClickActionsCompanion(
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
    return (StringBuffer('ItemClickActionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
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
  static const VerificationMeta _defaultArchiveIsMeta =
      const VerificationMeta('defaultArchiveIs');
  @override
  late final GeneratedColumn<bool> defaultArchiveIs = GeneratedColumn<bool>(
      'default_archive_is', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("default_archive_is" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _defaultArchiveOrgMeta =
      const VerificationMeta('defaultArchiveOrg');
  @override
  late final GeneratedColumn<bool> defaultArchiveOrg = GeneratedColumn<bool>(
      'default_archive_org', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("default_archive_org" IN (0, 1))'),
      defaultValue: const Constant(false));
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
  static const VerificationMeta _selectedThemeKeyMeta =
      const VerificationMeta('selectedThemeKey');
  @override
  late final GeneratedColumn<String> selectedThemeKey = GeneratedColumn<String>(
      'selected_theme_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _selectedThemeTypeMeta =
      const VerificationMeta('selectedThemeType');
  @override
  late final GeneratedColumn<int> selectedThemeType = GeneratedColumn<int>(
      'selected_theme_type', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES theme_types (id)'),
      defaultValue: const Constant(0));
  static const VerificationMeta _timeDisplayFormatMeta =
      const VerificationMeta('timeDisplayFormat');
  @override
  late final GeneratedColumn<int> timeDisplayFormat = GeneratedColumn<int>(
      'time_display_format', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES time_display_formats (id)'),
      defaultValue: const Constant(0));
  static const VerificationMeta _itemClickActionMeta =
      const VerificationMeta('itemClickAction');
  @override
  late final GeneratedColumn<int> itemClickAction = GeneratedColumn<int>(
      'item_click_action', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES item_click_actions (id)'),
      defaultValue: const Constant(0));
  static const VerificationMeta _cacheDirectoryMeta =
      const VerificationMeta('cacheDirectory');
  @override
  late final GeneratedColumn<String> cacheDirectory = GeneratedColumn<String>(
      'cache_directory', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _showDescriptionMeta =
      const VerificationMeta('showDescription');
  @override
  late final GeneratedColumn<bool> showDescription = GeneratedColumn<bool>(
      'show_description', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_description" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _showImagesMeta =
      const VerificationMeta('showImages');
  @override
  late final GeneratedColumn<bool> showImages = GeneratedColumn<bool>(
      'show_images', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("show_images" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _showTagsMeta =
      const VerificationMeta('showTags');
  @override
  late final GeneratedColumn<bool> showTags = GeneratedColumn<bool>(
      'show_tags', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("show_tags" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _showCopyLinkMeta =
      const VerificationMeta('showCopyLink');
  @override
  late final GeneratedColumn<bool> showCopyLink = GeneratedColumn<bool>(
      'show_copy_link', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_copy_link" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        darkMode,
        copyOnImport,
        defaultArchiveIs,
        defaultArchiveOrg,
        archiveOrgS3AccessKey,
        archiveOrgS3SecretKey,
        selectedThemeKey,
        selectedThemeType,
        timeDisplayFormat,
        itemClickAction,
        cacheDirectory,
        showDescription,
        showImages,
        showTags,
        showCopyLink
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
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
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
    if (data.containsKey('default_archive_is')) {
      context.handle(
          _defaultArchiveIsMeta,
          defaultArchiveIs.isAcceptableOrUnknown(
              data['default_archive_is']!, _defaultArchiveIsMeta));
    }
    if (data.containsKey('default_archive_org')) {
      context.handle(
          _defaultArchiveOrgMeta,
          defaultArchiveOrg.isAcceptableOrUnknown(
              data['default_archive_org']!, _defaultArchiveOrgMeta));
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
    if (data.containsKey('selected_theme_key')) {
      context.handle(
          _selectedThemeKeyMeta,
          selectedThemeKey.isAcceptableOrUnknown(
              data['selected_theme_key']!, _selectedThemeKeyMeta));
    }
    if (data.containsKey('selected_theme_type')) {
      context.handle(
          _selectedThemeTypeMeta,
          selectedThemeType.isAcceptableOrUnknown(
              data['selected_theme_type']!, _selectedThemeTypeMeta));
    }
    if (data.containsKey('time_display_format')) {
      context.handle(
          _timeDisplayFormatMeta,
          timeDisplayFormat.isAcceptableOrUnknown(
              data['time_display_format']!, _timeDisplayFormatMeta));
    }
    if (data.containsKey('item_click_action')) {
      context.handle(
          _itemClickActionMeta,
          itemClickAction.isAcceptableOrUnknown(
              data['item_click_action']!, _itemClickActionMeta));
    }
    if (data.containsKey('cache_directory')) {
      context.handle(
          _cacheDirectoryMeta,
          cacheDirectory.isAcceptableOrUnknown(
              data['cache_directory']!, _cacheDirectoryMeta));
    }
    if (data.containsKey('show_description')) {
      context.handle(
          _showDescriptionMeta,
          showDescription.isAcceptableOrUnknown(
              data['show_description']!, _showDescriptionMeta));
    }
    if (data.containsKey('show_images')) {
      context.handle(
          _showImagesMeta,
          showImages.isAcceptableOrUnknown(
              data['show_images']!, _showImagesMeta));
    }
    if (data.containsKey('show_tags')) {
      context.handle(_showTagsMeta,
          showTags.isAcceptableOrUnknown(data['show_tags']!, _showTagsMeta));
    }
    if (data.containsKey('show_copy_link')) {
      context.handle(
          _showCopyLinkMeta,
          showCopyLink.isAcceptableOrUnknown(
              data['show_copy_link']!, _showCopyLinkMeta));
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
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      darkMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dark_mode'])!,
      copyOnImport: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}copy_on_import'])!,
      defaultArchiveIs: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}default_archive_is'])!,
      defaultArchiveOrg: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}default_archive_org'])!,
      archiveOrgS3AccessKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}archive_org_s3_access_key']),
      archiveOrgS3SecretKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}archive_org_s3_secret_key']),
      selectedThemeKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}selected_theme_key']),
      selectedThemeType: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}selected_theme_type'])!,
      timeDisplayFormat: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}time_display_format'])!,
      itemClickAction: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_click_action'])!,
      cacheDirectory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cache_directory']),
      showDescription: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}show_description'])!,
      showImages: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}show_images'])!,
      showTags: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}show_tags'])!,
      showCopyLink: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}show_copy_link'])!,
    );
  }

  @override
  $UserConfigsTable createAlias(String alias) {
    return $UserConfigsTable(attachedDatabase, alias);
  }
}

class UserConfig extends DataClass implements Insertable<UserConfig> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool darkMode;
  final bool copyOnImport;
  final bool defaultArchiveIs;
  final bool defaultArchiveOrg;
  final String? archiveOrgS3AccessKey;
  final String? archiveOrgS3SecretKey;
  final String? selectedThemeKey;
  final int selectedThemeType;
  final int timeDisplayFormat;
  final int itemClickAction;
  final String? cacheDirectory;
  final bool showDescription;
  final bool showImages;
  final bool showTags;
  final bool showCopyLink;
  const UserConfig(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.darkMode,
      required this.copyOnImport,
      required this.defaultArchiveIs,
      required this.defaultArchiveOrg,
      this.archiveOrgS3AccessKey,
      this.archiveOrgS3SecretKey,
      this.selectedThemeKey,
      required this.selectedThemeType,
      required this.timeDisplayFormat,
      required this.itemClickAction,
      this.cacheDirectory,
      required this.showDescription,
      required this.showImages,
      required this.showTags,
      required this.showCopyLink});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['dark_mode'] = Variable<bool>(darkMode);
    map['copy_on_import'] = Variable<bool>(copyOnImport);
    map['default_archive_is'] = Variable<bool>(defaultArchiveIs);
    map['default_archive_org'] = Variable<bool>(defaultArchiveOrg);
    if (!nullToAbsent || archiveOrgS3AccessKey != null) {
      map['archive_org_s3_access_key'] =
          Variable<String>(archiveOrgS3AccessKey);
    }
    if (!nullToAbsent || archiveOrgS3SecretKey != null) {
      map['archive_org_s3_secret_key'] =
          Variable<String>(archiveOrgS3SecretKey);
    }
    if (!nullToAbsent || selectedThemeKey != null) {
      map['selected_theme_key'] = Variable<String>(selectedThemeKey);
    }
    map['selected_theme_type'] = Variable<int>(selectedThemeType);
    map['time_display_format'] = Variable<int>(timeDisplayFormat);
    map['item_click_action'] = Variable<int>(itemClickAction);
    if (!nullToAbsent || cacheDirectory != null) {
      map['cache_directory'] = Variable<String>(cacheDirectory);
    }
    map['show_description'] = Variable<bool>(showDescription);
    map['show_images'] = Variable<bool>(showImages);
    map['show_tags'] = Variable<bool>(showTags);
    map['show_copy_link'] = Variable<bool>(showCopyLink);
    return map;
  }

  UserConfigsCompanion toCompanion(bool nullToAbsent) {
    return UserConfigsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      darkMode: Value(darkMode),
      copyOnImport: Value(copyOnImport),
      defaultArchiveIs: Value(defaultArchiveIs),
      defaultArchiveOrg: Value(defaultArchiveOrg),
      archiveOrgS3AccessKey: archiveOrgS3AccessKey == null && nullToAbsent
          ? const Value.absent()
          : Value(archiveOrgS3AccessKey),
      archiveOrgS3SecretKey: archiveOrgS3SecretKey == null && nullToAbsent
          ? const Value.absent()
          : Value(archiveOrgS3SecretKey),
      selectedThemeKey: selectedThemeKey == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedThemeKey),
      selectedThemeType: Value(selectedThemeType),
      timeDisplayFormat: Value(timeDisplayFormat),
      itemClickAction: Value(itemClickAction),
      cacheDirectory: cacheDirectory == null && nullToAbsent
          ? const Value.absent()
          : Value(cacheDirectory),
      showDescription: Value(showDescription),
      showImages: Value(showImages),
      showTags: Value(showTags),
      showCopyLink: Value(showCopyLink),
    );
  }

  factory UserConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserConfig(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      darkMode: serializer.fromJson<bool>(json['darkMode']),
      copyOnImport: serializer.fromJson<bool>(json['copyOnImport']),
      defaultArchiveIs: serializer.fromJson<bool>(json['defaultArchiveIs']),
      defaultArchiveOrg: serializer.fromJson<bool>(json['defaultArchiveOrg']),
      archiveOrgS3AccessKey:
          serializer.fromJson<String?>(json['archiveOrgS3AccessKey']),
      archiveOrgS3SecretKey:
          serializer.fromJson<String?>(json['archiveOrgS3SecretKey']),
      selectedThemeKey: serializer.fromJson<String?>(json['selectedThemeKey']),
      selectedThemeType: serializer.fromJson<int>(json['selectedThemeType']),
      timeDisplayFormat: serializer.fromJson<int>(json['timeDisplayFormat']),
      itemClickAction: serializer.fromJson<int>(json['itemClickAction']),
      cacheDirectory: serializer.fromJson<String?>(json['cacheDirectory']),
      showDescription: serializer.fromJson<bool>(json['showDescription']),
      showImages: serializer.fromJson<bool>(json['showImages']),
      showTags: serializer.fromJson<bool>(json['showTags']),
      showCopyLink: serializer.fromJson<bool>(json['showCopyLink']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'darkMode': serializer.toJson<bool>(darkMode),
      'copyOnImport': serializer.toJson<bool>(copyOnImport),
      'defaultArchiveIs': serializer.toJson<bool>(defaultArchiveIs),
      'defaultArchiveOrg': serializer.toJson<bool>(defaultArchiveOrg),
      'archiveOrgS3AccessKey':
          serializer.toJson<String?>(archiveOrgS3AccessKey),
      'archiveOrgS3SecretKey':
          serializer.toJson<String?>(archiveOrgS3SecretKey),
      'selectedThemeKey': serializer.toJson<String?>(selectedThemeKey),
      'selectedThemeType': serializer.toJson<int>(selectedThemeType),
      'timeDisplayFormat': serializer.toJson<int>(timeDisplayFormat),
      'itemClickAction': serializer.toJson<int>(itemClickAction),
      'cacheDirectory': serializer.toJson<String?>(cacheDirectory),
      'showDescription': serializer.toJson<bool>(showDescription),
      'showImages': serializer.toJson<bool>(showImages),
      'showTags': serializer.toJson<bool>(showTags),
      'showCopyLink': serializer.toJson<bool>(showCopyLink),
    };
  }

  UserConfig copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? darkMode,
          bool? copyOnImport,
          bool? defaultArchiveIs,
          bool? defaultArchiveOrg,
          Value<String?> archiveOrgS3AccessKey = const Value.absent(),
          Value<String?> archiveOrgS3SecretKey = const Value.absent(),
          Value<String?> selectedThemeKey = const Value.absent(),
          int? selectedThemeType,
          int? timeDisplayFormat,
          int? itemClickAction,
          Value<String?> cacheDirectory = const Value.absent(),
          bool? showDescription,
          bool? showImages,
          bool? showTags,
          bool? showCopyLink}) =>
      UserConfig(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        darkMode: darkMode ?? this.darkMode,
        copyOnImport: copyOnImport ?? this.copyOnImport,
        defaultArchiveIs: defaultArchiveIs ?? this.defaultArchiveIs,
        defaultArchiveOrg: defaultArchiveOrg ?? this.defaultArchiveOrg,
        archiveOrgS3AccessKey: archiveOrgS3AccessKey.present
            ? archiveOrgS3AccessKey.value
            : this.archiveOrgS3AccessKey,
        archiveOrgS3SecretKey: archiveOrgS3SecretKey.present
            ? archiveOrgS3SecretKey.value
            : this.archiveOrgS3SecretKey,
        selectedThemeKey: selectedThemeKey.present
            ? selectedThemeKey.value
            : this.selectedThemeKey,
        selectedThemeType: selectedThemeType ?? this.selectedThemeType,
        timeDisplayFormat: timeDisplayFormat ?? this.timeDisplayFormat,
        itemClickAction: itemClickAction ?? this.itemClickAction,
        cacheDirectory:
            cacheDirectory.present ? cacheDirectory.value : this.cacheDirectory,
        showDescription: showDescription ?? this.showDescription,
        showImages: showImages ?? this.showImages,
        showTags: showTags ?? this.showTags,
        showCopyLink: showCopyLink ?? this.showCopyLink,
      );
  UserConfig copyWithCompanion(UserConfigsCompanion data) {
    return UserConfig(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      darkMode: data.darkMode.present ? data.darkMode.value : this.darkMode,
      copyOnImport: data.copyOnImport.present
          ? data.copyOnImport.value
          : this.copyOnImport,
      defaultArchiveIs: data.defaultArchiveIs.present
          ? data.defaultArchiveIs.value
          : this.defaultArchiveIs,
      defaultArchiveOrg: data.defaultArchiveOrg.present
          ? data.defaultArchiveOrg.value
          : this.defaultArchiveOrg,
      archiveOrgS3AccessKey: data.archiveOrgS3AccessKey.present
          ? data.archiveOrgS3AccessKey.value
          : this.archiveOrgS3AccessKey,
      archiveOrgS3SecretKey: data.archiveOrgS3SecretKey.present
          ? data.archiveOrgS3SecretKey.value
          : this.archiveOrgS3SecretKey,
      selectedThemeKey: data.selectedThemeKey.present
          ? data.selectedThemeKey.value
          : this.selectedThemeKey,
      selectedThemeType: data.selectedThemeType.present
          ? data.selectedThemeType.value
          : this.selectedThemeType,
      timeDisplayFormat: data.timeDisplayFormat.present
          ? data.timeDisplayFormat.value
          : this.timeDisplayFormat,
      itemClickAction: data.itemClickAction.present
          ? data.itemClickAction.value
          : this.itemClickAction,
      cacheDirectory: data.cacheDirectory.present
          ? data.cacheDirectory.value
          : this.cacheDirectory,
      showDescription: data.showDescription.present
          ? data.showDescription.value
          : this.showDescription,
      showImages:
          data.showImages.present ? data.showImages.value : this.showImages,
      showTags: data.showTags.present ? data.showTags.value : this.showTags,
      showCopyLink: data.showCopyLink.present
          ? data.showCopyLink.value
          : this.showCopyLink,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserConfig(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('darkMode: $darkMode, ')
          ..write('copyOnImport: $copyOnImport, ')
          ..write('defaultArchiveIs: $defaultArchiveIs, ')
          ..write('defaultArchiveOrg: $defaultArchiveOrg, ')
          ..write('archiveOrgS3AccessKey: $archiveOrgS3AccessKey, ')
          ..write('archiveOrgS3SecretKey: $archiveOrgS3SecretKey, ')
          ..write('selectedThemeKey: $selectedThemeKey, ')
          ..write('selectedThemeType: $selectedThemeType, ')
          ..write('timeDisplayFormat: $timeDisplayFormat, ')
          ..write('itemClickAction: $itemClickAction, ')
          ..write('cacheDirectory: $cacheDirectory, ')
          ..write('showDescription: $showDescription, ')
          ..write('showImages: $showImages, ')
          ..write('showTags: $showTags, ')
          ..write('showCopyLink: $showCopyLink')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      darkMode,
      copyOnImport,
      defaultArchiveIs,
      defaultArchiveOrg,
      archiveOrgS3AccessKey,
      archiveOrgS3SecretKey,
      selectedThemeKey,
      selectedThemeType,
      timeDisplayFormat,
      itemClickAction,
      cacheDirectory,
      showDescription,
      showImages,
      showTags,
      showCopyLink);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserConfig &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.darkMode == this.darkMode &&
          other.copyOnImport == this.copyOnImport &&
          other.defaultArchiveIs == this.defaultArchiveIs &&
          other.defaultArchiveOrg == this.defaultArchiveOrg &&
          other.archiveOrgS3AccessKey == this.archiveOrgS3AccessKey &&
          other.archiveOrgS3SecretKey == this.archiveOrgS3SecretKey &&
          other.selectedThemeKey == this.selectedThemeKey &&
          other.selectedThemeType == this.selectedThemeType &&
          other.timeDisplayFormat == this.timeDisplayFormat &&
          other.itemClickAction == this.itemClickAction &&
          other.cacheDirectory == this.cacheDirectory &&
          other.showDescription == this.showDescription &&
          other.showImages == this.showImages &&
          other.showTags == this.showTags &&
          other.showCopyLink == this.showCopyLink);
}

class UserConfigsCompanion extends UpdateCompanion<UserConfig> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> darkMode;
  final Value<bool> copyOnImport;
  final Value<bool> defaultArchiveIs;
  final Value<bool> defaultArchiveOrg;
  final Value<String?> archiveOrgS3AccessKey;
  final Value<String?> archiveOrgS3SecretKey;
  final Value<String?> selectedThemeKey;
  final Value<int> selectedThemeType;
  final Value<int> timeDisplayFormat;
  final Value<int> itemClickAction;
  final Value<String?> cacheDirectory;
  final Value<bool> showDescription;
  final Value<bool> showImages;
  final Value<bool> showTags;
  final Value<bool> showCopyLink;
  final Value<int> rowid;
  const UserConfigsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.copyOnImport = const Value.absent(),
    this.defaultArchiveIs = const Value.absent(),
    this.defaultArchiveOrg = const Value.absent(),
    this.archiveOrgS3AccessKey = const Value.absent(),
    this.archiveOrgS3SecretKey = const Value.absent(),
    this.selectedThemeKey = const Value.absent(),
    this.selectedThemeType = const Value.absent(),
    this.timeDisplayFormat = const Value.absent(),
    this.itemClickAction = const Value.absent(),
    this.cacheDirectory = const Value.absent(),
    this.showDescription = const Value.absent(),
    this.showImages = const Value.absent(),
    this.showTags = const Value.absent(),
    this.showCopyLink = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserConfigsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.copyOnImport = const Value.absent(),
    this.defaultArchiveIs = const Value.absent(),
    this.defaultArchiveOrg = const Value.absent(),
    this.archiveOrgS3AccessKey = const Value.absent(),
    this.archiveOrgS3SecretKey = const Value.absent(),
    this.selectedThemeKey = const Value.absent(),
    this.selectedThemeType = const Value.absent(),
    this.timeDisplayFormat = const Value.absent(),
    this.itemClickAction = const Value.absent(),
    this.cacheDirectory = const Value.absent(),
    this.showDescription = const Value.absent(),
    this.showImages = const Value.absent(),
    this.showTags = const Value.absent(),
    this.showCopyLink = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<UserConfig> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? darkMode,
    Expression<bool>? copyOnImport,
    Expression<bool>? defaultArchiveIs,
    Expression<bool>? defaultArchiveOrg,
    Expression<String>? archiveOrgS3AccessKey,
    Expression<String>? archiveOrgS3SecretKey,
    Expression<String>? selectedThemeKey,
    Expression<int>? selectedThemeType,
    Expression<int>? timeDisplayFormat,
    Expression<int>? itemClickAction,
    Expression<String>? cacheDirectory,
    Expression<bool>? showDescription,
    Expression<bool>? showImages,
    Expression<bool>? showTags,
    Expression<bool>? showCopyLink,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (darkMode != null) 'dark_mode': darkMode,
      if (copyOnImport != null) 'copy_on_import': copyOnImport,
      if (defaultArchiveIs != null) 'default_archive_is': defaultArchiveIs,
      if (defaultArchiveOrg != null) 'default_archive_org': defaultArchiveOrg,
      if (archiveOrgS3AccessKey != null)
        'archive_org_s3_access_key': archiveOrgS3AccessKey,
      if (archiveOrgS3SecretKey != null)
        'archive_org_s3_secret_key': archiveOrgS3SecretKey,
      if (selectedThemeKey != null) 'selected_theme_key': selectedThemeKey,
      if (selectedThemeType != null) 'selected_theme_type': selectedThemeType,
      if (timeDisplayFormat != null) 'time_display_format': timeDisplayFormat,
      if (itemClickAction != null) 'item_click_action': itemClickAction,
      if (cacheDirectory != null) 'cache_directory': cacheDirectory,
      if (showDescription != null) 'show_description': showDescription,
      if (showImages != null) 'show_images': showImages,
      if (showTags != null) 'show_tags': showTags,
      if (showCopyLink != null) 'show_copy_link': showCopyLink,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserConfigsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? darkMode,
      Value<bool>? copyOnImport,
      Value<bool>? defaultArchiveIs,
      Value<bool>? defaultArchiveOrg,
      Value<String?>? archiveOrgS3AccessKey,
      Value<String?>? archiveOrgS3SecretKey,
      Value<String?>? selectedThemeKey,
      Value<int>? selectedThemeType,
      Value<int>? timeDisplayFormat,
      Value<int>? itemClickAction,
      Value<String?>? cacheDirectory,
      Value<bool>? showDescription,
      Value<bool>? showImages,
      Value<bool>? showTags,
      Value<bool>? showCopyLink,
      Value<int>? rowid}) {
    return UserConfigsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      darkMode: darkMode ?? this.darkMode,
      copyOnImport: copyOnImport ?? this.copyOnImport,
      defaultArchiveIs: defaultArchiveIs ?? this.defaultArchiveIs,
      defaultArchiveOrg: defaultArchiveOrg ?? this.defaultArchiveOrg,
      archiveOrgS3AccessKey:
          archiveOrgS3AccessKey ?? this.archiveOrgS3AccessKey,
      archiveOrgS3SecretKey:
          archiveOrgS3SecretKey ?? this.archiveOrgS3SecretKey,
      selectedThemeKey: selectedThemeKey ?? this.selectedThemeKey,
      selectedThemeType: selectedThemeType ?? this.selectedThemeType,
      timeDisplayFormat: timeDisplayFormat ?? this.timeDisplayFormat,
      itemClickAction: itemClickAction ?? this.itemClickAction,
      cacheDirectory: cacheDirectory ?? this.cacheDirectory,
      showDescription: showDescription ?? this.showDescription,
      showImages: showImages ?? this.showImages,
      showTags: showTags ?? this.showTags,
      showCopyLink: showCopyLink ?? this.showCopyLink,
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
    if (darkMode.present) {
      map['dark_mode'] = Variable<bool>(darkMode.value);
    }
    if (copyOnImport.present) {
      map['copy_on_import'] = Variable<bool>(copyOnImport.value);
    }
    if (defaultArchiveIs.present) {
      map['default_archive_is'] = Variable<bool>(defaultArchiveIs.value);
    }
    if (defaultArchiveOrg.present) {
      map['default_archive_org'] = Variable<bool>(defaultArchiveOrg.value);
    }
    if (archiveOrgS3AccessKey.present) {
      map['archive_org_s3_access_key'] =
          Variable<String>(archiveOrgS3AccessKey.value);
    }
    if (archiveOrgS3SecretKey.present) {
      map['archive_org_s3_secret_key'] =
          Variable<String>(archiveOrgS3SecretKey.value);
    }
    if (selectedThemeKey.present) {
      map['selected_theme_key'] = Variable<String>(selectedThemeKey.value);
    }
    if (selectedThemeType.present) {
      map['selected_theme_type'] = Variable<int>(selectedThemeType.value);
    }
    if (timeDisplayFormat.present) {
      map['time_display_format'] = Variable<int>(timeDisplayFormat.value);
    }
    if (itemClickAction.present) {
      map['item_click_action'] = Variable<int>(itemClickAction.value);
    }
    if (cacheDirectory.present) {
      map['cache_directory'] = Variable<String>(cacheDirectory.value);
    }
    if (showDescription.present) {
      map['show_description'] = Variable<bool>(showDescription.value);
    }
    if (showImages.present) {
      map['show_images'] = Variable<bool>(showImages.value);
    }
    if (showTags.present) {
      map['show_tags'] = Variable<bool>(showTags.value);
    }
    if (showCopyLink.present) {
      map['show_copy_link'] = Variable<bool>(showCopyLink.value);
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('darkMode: $darkMode, ')
          ..write('copyOnImport: $copyOnImport, ')
          ..write('defaultArchiveIs: $defaultArchiveIs, ')
          ..write('defaultArchiveOrg: $defaultArchiveOrg, ')
          ..write('archiveOrgS3AccessKey: $archiveOrgS3AccessKey, ')
          ..write('archiveOrgS3SecretKey: $archiveOrgS3SecretKey, ')
          ..write('selectedThemeKey: $selectedThemeKey, ')
          ..write('selectedThemeType: $selectedThemeType, ')
          ..write('timeDisplayFormat: $timeDisplayFormat, ')
          ..write('itemClickAction: $itemClickAction, ')
          ..write('cacheDirectory: $cacheDirectory, ')
          ..write('showDescription: $showDescription, ')
          ..write('showImages: $showImages, ')
          ..write('showTags: $showTags, ')
          ..write('showCopyLink: $showCopyLink, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeedTypesTable extends SeedTypes
    with TableInfo<$SeedTypesTable, SeedTypeEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeedTypesTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'seed_types';
  @override
  VerificationContext validateIntegrity(Insertable<SeedTypeEntity> instance,
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
  SeedTypeEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeedTypeEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $SeedTypesTable createAlias(String alias) {
    return $SeedTypesTable(attachedDatabase, alias);
  }
}

class SeedTypeEntity extends DataClass implements Insertable<SeedTypeEntity> {
  final int id;
  final String name;
  const SeedTypeEntity({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  SeedTypesCompanion toCompanion(bool nullToAbsent) {
    return SeedTypesCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory SeedTypeEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeedTypeEntity(
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

  SeedTypeEntity copyWith({int? id, String? name}) => SeedTypeEntity(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  SeedTypeEntity copyWithCompanion(SeedTypesCompanion data) {
    return SeedTypeEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeedTypeEntity(')
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
      (other is SeedTypeEntity &&
          other.id == this.id &&
          other.name == this.name);
}

class SeedTypesCompanion extends UpdateCompanion<SeedTypeEntity> {
  final Value<int> id;
  final Value<String> name;
  const SeedTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  SeedTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<SeedTypeEntity> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  SeedTypesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return SeedTypesCompanion(
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
    return (StringBuffer('SeedTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _primaryColorMeta =
      const VerificationMeta('primaryColor');
  @override
  late final GeneratedColumn<int> primaryColor = GeneratedColumn<int>(
      'primary_color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _secondaryColorMeta =
      const VerificationMeta('secondaryColor');
  @override
  late final GeneratedColumn<int> secondaryColor = GeneratedColumn<int>(
      'secondary_color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tertiaryColorMeta =
      const VerificationMeta('tertiaryColor');
  @override
  late final GeneratedColumn<int> tertiaryColor = GeneratedColumn<int>(
      'tertiary_color', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _seedTypeMeta =
      const VerificationMeta('seedType');
  @override
  late final GeneratedColumn<int> seedType = GeneratedColumn<int>(
      'seed_type', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES seed_types (id)'),
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userConfigId,
        createdAt,
        updatedAt,
        name,
        primaryColor,
        secondaryColor,
        tertiaryColor,
        seedType
      ];
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
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('primary_color')) {
      context.handle(
          _primaryColorMeta,
          primaryColor.isAcceptableOrUnknown(
              data['primary_color']!, _primaryColorMeta));
    } else if (isInserting) {
      context.missing(_primaryColorMeta);
    }
    if (data.containsKey('secondary_color')) {
      context.handle(
          _secondaryColorMeta,
          secondaryColor.isAcceptableOrUnknown(
              data['secondary_color']!, _secondaryColorMeta));
    } else if (isInserting) {
      context.missing(_secondaryColorMeta);
    }
    if (data.containsKey('tertiary_color')) {
      context.handle(
          _tertiaryColorMeta,
          tertiaryColor.isAcceptableOrUnknown(
              data['tertiary_color']!, _tertiaryColorMeta));
    }
    if (data.containsKey('seed_type')) {
      context.handle(_seedTypeMeta,
          seedType.isAcceptableOrUnknown(data['seed_type']!, _seedTypeMeta));
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
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      primaryColor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}primary_color'])!,
      secondaryColor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}secondary_color'])!,
      tertiaryColor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tertiary_color']),
      seedType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}seed_type'])!,
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final int primaryColor;
  final int secondaryColor;
  final int? tertiaryColor;
  final int seedType;
  const UserTheme(
      {required this.id,
      required this.userConfigId,
      required this.createdAt,
      required this.updatedAt,
      required this.name,
      required this.primaryColor,
      required this.secondaryColor,
      this.tertiaryColor,
      required this.seedType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_config_id'] = Variable<String>(userConfigId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['name'] = Variable<String>(name);
    map['primary_color'] = Variable<int>(primaryColor);
    map['secondary_color'] = Variable<int>(secondaryColor);
    if (!nullToAbsent || tertiaryColor != null) {
      map['tertiary_color'] = Variable<int>(tertiaryColor);
    }
    map['seed_type'] = Variable<int>(seedType);
    return map;
  }

  UserThemesCompanion toCompanion(bool nullToAbsent) {
    return UserThemesCompanion(
      id: Value(id),
      userConfigId: Value(userConfigId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      name: Value(name),
      primaryColor: Value(primaryColor),
      secondaryColor: Value(secondaryColor),
      tertiaryColor: tertiaryColor == null && nullToAbsent
          ? const Value.absent()
          : Value(tertiaryColor),
      seedType: Value(seedType),
    );
  }

  factory UserTheme.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserTheme(
      id: serializer.fromJson<String>(json['id']),
      userConfigId: serializer.fromJson<String>(json['userConfigId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
      primaryColor: serializer.fromJson<int>(json['primaryColor']),
      secondaryColor: serializer.fromJson<int>(json['secondaryColor']),
      tertiaryColor: serializer.fromJson<int?>(json['tertiaryColor']),
      seedType: serializer.fromJson<int>(json['seedType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userConfigId': serializer.toJson<String>(userConfigId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'name': serializer.toJson<String>(name),
      'primaryColor': serializer.toJson<int>(primaryColor),
      'secondaryColor': serializer.toJson<int>(secondaryColor),
      'tertiaryColor': serializer.toJson<int?>(tertiaryColor),
      'seedType': serializer.toJson<int>(seedType),
    };
  }

  UserTheme copyWith(
          {String? id,
          String? userConfigId,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? name,
          int? primaryColor,
          int? secondaryColor,
          Value<int?> tertiaryColor = const Value.absent(),
          int? seedType}) =>
      UserTheme(
        id: id ?? this.id,
        userConfigId: userConfigId ?? this.userConfigId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        name: name ?? this.name,
        primaryColor: primaryColor ?? this.primaryColor,
        secondaryColor: secondaryColor ?? this.secondaryColor,
        tertiaryColor:
            tertiaryColor.present ? tertiaryColor.value : this.tertiaryColor,
        seedType: seedType ?? this.seedType,
      );
  UserTheme copyWithCompanion(UserThemesCompanion data) {
    return UserTheme(
      id: data.id.present ? data.id.value : this.id,
      userConfigId: data.userConfigId.present
          ? data.userConfigId.value
          : this.userConfigId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
      primaryColor: data.primaryColor.present
          ? data.primaryColor.value
          : this.primaryColor,
      secondaryColor: data.secondaryColor.present
          ? data.secondaryColor.value
          : this.secondaryColor,
      tertiaryColor: data.tertiaryColor.present
          ? data.tertiaryColor.value
          : this.tertiaryColor,
      seedType: data.seedType.present ? data.seedType.value : this.seedType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserTheme(')
          ..write('id: $id, ')
          ..write('userConfigId: $userConfigId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('primaryColor: $primaryColor, ')
          ..write('secondaryColor: $secondaryColor, ')
          ..write('tertiaryColor: $tertiaryColor, ')
          ..write('seedType: $seedType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userConfigId, createdAt, updatedAt, name,
      primaryColor, secondaryColor, tertiaryColor, seedType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserTheme &&
          other.id == this.id &&
          other.userConfigId == this.userConfigId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name &&
          other.primaryColor == this.primaryColor &&
          other.secondaryColor == this.secondaryColor &&
          other.tertiaryColor == this.tertiaryColor &&
          other.seedType == this.seedType);
}

class UserThemesCompanion extends UpdateCompanion<UserTheme> {
  final Value<String> id;
  final Value<String> userConfigId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> name;
  final Value<int> primaryColor;
  final Value<int> secondaryColor;
  final Value<int?> tertiaryColor;
  final Value<int> seedType;
  final Value<int> rowid;
  const UserThemesCompanion({
    this.id = const Value.absent(),
    this.userConfigId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.primaryColor = const Value.absent(),
    this.secondaryColor = const Value.absent(),
    this.tertiaryColor = const Value.absent(),
    this.seedType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserThemesCompanion.insert({
    required String id,
    required String userConfigId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String name,
    required int primaryColor,
    required int secondaryColor,
    this.tertiaryColor = const Value.absent(),
    this.seedType = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userConfigId = Value(userConfigId),
        name = Value(name),
        primaryColor = Value(primaryColor),
        secondaryColor = Value(secondaryColor);
  static Insertable<UserTheme> custom({
    Expression<String>? id,
    Expression<String>? userConfigId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<int>? primaryColor,
    Expression<int>? secondaryColor,
    Expression<int>? tertiaryColor,
    Expression<int>? seedType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userConfigId != null) 'user_config_id': userConfigId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (primaryColor != null) 'primary_color': primaryColor,
      if (secondaryColor != null) 'secondary_color': secondaryColor,
      if (tertiaryColor != null) 'tertiary_color': tertiaryColor,
      if (seedType != null) 'seed_type': seedType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserThemesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userConfigId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? name,
      Value<int>? primaryColor,
      Value<int>? secondaryColor,
      Value<int?>? tertiaryColor,
      Value<int>? seedType,
      Value<int>? rowid}) {
    return UserThemesCompanion(
      id: id ?? this.id,
      userConfigId: userConfigId ?? this.userConfigId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      tertiaryColor: tertiaryColor ?? this.tertiaryColor,
      seedType: seedType ?? this.seedType,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (primaryColor.present) {
      map['primary_color'] = Variable<int>(primaryColor.value);
    }
    if (secondaryColor.present) {
      map['secondary_color'] = Variable<int>(secondaryColor.value);
    }
    if (tertiaryColor.present) {
      map['tertiary_color'] = Variable<int>(tertiaryColor.value);
    }
    if (seedType.present) {
      map['seed_type'] = Variable<int>(seedType.value);
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('primaryColor: $primaryColor, ')
          ..write('secondaryColor: $secondaryColor, ')
          ..write('tertiaryColor: $tertiaryColor, ')
          ..write('seedType: $seedType, ')
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
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES user_configs (id) ON DELETE CASCADE'));
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

abstract class _$ConfigDatabase extends GeneratedDatabase {
  _$ConfigDatabase(QueryExecutor e) : super(e);
  $ConfigDatabaseManager get managers => $ConfigDatabaseManager(this);
  late final $ThemeTypesTable themeTypes = $ThemeTypesTable(this);
  late final $TimeDisplayFormatsTable timeDisplayFormats =
      $TimeDisplayFormatsTable(this);
  late final $ItemClickActionsTable itemClickActions =
      $ItemClickActionsTable(this);
  late final $UserConfigsTable userConfigs = $UserConfigsTable(this);
  late final $SeedTypesTable seedTypes = $SeedTypesTable(this);
  late final $UserThemesTable userThemes = $UserThemesTable(this);
  late final $BackupSettingsTable backupSettings = $BackupSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        themeTypes,
        timeDisplayFormats,
        itemClickActions,
        userConfigs,
        seedTypes,
        userThemes,
        backupSettings
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('user_configs',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('backup_settings', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ThemeTypesTableCreateCompanionBuilder = ThemeTypesCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$ThemeTypesTableUpdateCompanionBuilder = ThemeTypesCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$ThemeTypesTableReferences extends BaseReferences<_$ConfigDatabase,
    $ThemeTypesTable, ThemeTypeEntity> {
  $$ThemeTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserConfigsTable, List<UserConfig>>
      _userConfigsRefsTable(_$ConfigDatabase db) =>
          MultiTypedResultKey.fromTable(db.userConfigs,
              aliasName: $_aliasNameGenerator(
                  db.themeTypes.id, db.userConfigs.selectedThemeType));

  $$UserConfigsTableProcessedTableManager get userConfigsRefs {
    final manager = $$UserConfigsTableTableManager($_db, $_db.userConfigs)
        .filter(
            (f) => f.selectedThemeType.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userConfigsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ThemeTypesTableFilterComposer
    extends Composer<_$ConfigDatabase, $ThemeTypesTable> {
  $$ThemeTypesTableFilterComposer({
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

  Expression<bool> userConfigsRefs(
      Expression<bool> Function($$UserConfigsTableFilterComposer f) f) {
    final $$UserConfigsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.selectedThemeType,
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
    return f(composer);
  }
}

class $$ThemeTypesTableOrderingComposer
    extends Composer<_$ConfigDatabase, $ThemeTypesTable> {
  $$ThemeTypesTableOrderingComposer({
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

class $$ThemeTypesTableAnnotationComposer
    extends Composer<_$ConfigDatabase, $ThemeTypesTable> {
  $$ThemeTypesTableAnnotationComposer({
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

  Expression<T> userConfigsRefs<T extends Object>(
      Expression<T> Function($$UserConfigsTableAnnotationComposer a) f) {
    final $$UserConfigsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.selectedThemeType,
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
    return f(composer);
  }
}

class $$ThemeTypesTableTableManager extends RootTableManager<
    _$ConfigDatabase,
    $ThemeTypesTable,
    ThemeTypeEntity,
    $$ThemeTypesTableFilterComposer,
    $$ThemeTypesTableOrderingComposer,
    $$ThemeTypesTableAnnotationComposer,
    $$ThemeTypesTableCreateCompanionBuilder,
    $$ThemeTypesTableUpdateCompanionBuilder,
    (ThemeTypeEntity, $$ThemeTypesTableReferences),
    ThemeTypeEntity,
    PrefetchHooks Function({bool userConfigsRefs})> {
  $$ThemeTypesTableTableManager(_$ConfigDatabase db, $ThemeTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThemeTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThemeTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThemeTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              ThemeTypesCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              ThemeTypesCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ThemeTypesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userConfigsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userConfigsRefs) db.userConfigs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userConfigsRefs)
                    await $_getPrefetchedData<ThemeTypeEntity, $ThemeTypesTable,
                            UserConfig>(
                        currentTable: table,
                        referencedTable: $$ThemeTypesTableReferences
                            ._userConfigsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ThemeTypesTableReferences(db, table, p0)
                                .userConfigsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.selectedThemeType == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ThemeTypesTableProcessedTableManager = ProcessedTableManager<
    _$ConfigDatabase,
    $ThemeTypesTable,
    ThemeTypeEntity,
    $$ThemeTypesTableFilterComposer,
    $$ThemeTypesTableOrderingComposer,
    $$ThemeTypesTableAnnotationComposer,
    $$ThemeTypesTableCreateCompanionBuilder,
    $$ThemeTypesTableUpdateCompanionBuilder,
    (ThemeTypeEntity, $$ThemeTypesTableReferences),
    ThemeTypeEntity,
    PrefetchHooks Function({bool userConfigsRefs})>;
typedef $$TimeDisplayFormatsTableCreateCompanionBuilder
    = TimeDisplayFormatsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$TimeDisplayFormatsTableUpdateCompanionBuilder
    = TimeDisplayFormatsCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$TimeDisplayFormatsTableReferences extends BaseReferences<
    _$ConfigDatabase, $TimeDisplayFormatsTable, TimeDisplayFormatEntity> {
  $$TimeDisplayFormatsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserConfigsTable, List<UserConfig>>
      _userConfigsRefsTable(_$ConfigDatabase db) =>
          MultiTypedResultKey.fromTable(db.userConfigs,
              aliasName: $_aliasNameGenerator(
                  db.timeDisplayFormats.id, db.userConfigs.timeDisplayFormat));

  $$UserConfigsTableProcessedTableManager get userConfigsRefs {
    final manager = $$UserConfigsTableTableManager($_db, $_db.userConfigs)
        .filter(
            (f) => f.timeDisplayFormat.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userConfigsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TimeDisplayFormatsTableFilterComposer
    extends Composer<_$ConfigDatabase, $TimeDisplayFormatsTable> {
  $$TimeDisplayFormatsTableFilterComposer({
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

  Expression<bool> userConfigsRefs(
      Expression<bool> Function($$UserConfigsTableFilterComposer f) f) {
    final $$UserConfigsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.timeDisplayFormat,
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
    return f(composer);
  }
}

class $$TimeDisplayFormatsTableOrderingComposer
    extends Composer<_$ConfigDatabase, $TimeDisplayFormatsTable> {
  $$TimeDisplayFormatsTableOrderingComposer({
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

class $$TimeDisplayFormatsTableAnnotationComposer
    extends Composer<_$ConfigDatabase, $TimeDisplayFormatsTable> {
  $$TimeDisplayFormatsTableAnnotationComposer({
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

  Expression<T> userConfigsRefs<T extends Object>(
      Expression<T> Function($$UserConfigsTableAnnotationComposer a) f) {
    final $$UserConfigsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.timeDisplayFormat,
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
    return f(composer);
  }
}

class $$TimeDisplayFormatsTableTableManager extends RootTableManager<
    _$ConfigDatabase,
    $TimeDisplayFormatsTable,
    TimeDisplayFormatEntity,
    $$TimeDisplayFormatsTableFilterComposer,
    $$TimeDisplayFormatsTableOrderingComposer,
    $$TimeDisplayFormatsTableAnnotationComposer,
    $$TimeDisplayFormatsTableCreateCompanionBuilder,
    $$TimeDisplayFormatsTableUpdateCompanionBuilder,
    (TimeDisplayFormatEntity, $$TimeDisplayFormatsTableReferences),
    TimeDisplayFormatEntity,
    PrefetchHooks Function({bool userConfigsRefs})> {
  $$TimeDisplayFormatsTableTableManager(
      _$ConfigDatabase db, $TimeDisplayFormatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimeDisplayFormatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimeDisplayFormatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimeDisplayFormatsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              TimeDisplayFormatsCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              TimeDisplayFormatsCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TimeDisplayFormatsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userConfigsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userConfigsRefs) db.userConfigs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userConfigsRefs)
                    await $_getPrefetchedData<TimeDisplayFormatEntity,
                            $TimeDisplayFormatsTable, UserConfig>(
                        currentTable: table,
                        referencedTable: $$TimeDisplayFormatsTableReferences
                            ._userConfigsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TimeDisplayFormatsTableReferences(db, table, p0)
                                .userConfigsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.timeDisplayFormat == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TimeDisplayFormatsTableProcessedTableManager = ProcessedTableManager<
    _$ConfigDatabase,
    $TimeDisplayFormatsTable,
    TimeDisplayFormatEntity,
    $$TimeDisplayFormatsTableFilterComposer,
    $$TimeDisplayFormatsTableOrderingComposer,
    $$TimeDisplayFormatsTableAnnotationComposer,
    $$TimeDisplayFormatsTableCreateCompanionBuilder,
    $$TimeDisplayFormatsTableUpdateCompanionBuilder,
    (TimeDisplayFormatEntity, $$TimeDisplayFormatsTableReferences),
    TimeDisplayFormatEntity,
    PrefetchHooks Function({bool userConfigsRefs})>;
typedef $$ItemClickActionsTableCreateCompanionBuilder
    = ItemClickActionsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$ItemClickActionsTableUpdateCompanionBuilder
    = ItemClickActionsCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$ItemClickActionsTableReferences extends BaseReferences<
    _$ConfigDatabase, $ItemClickActionsTable, ItemClickActionEntity> {
  $$ItemClickActionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserConfigsTable, List<UserConfig>>
      _userConfigsRefsTable(_$ConfigDatabase db) =>
          MultiTypedResultKey.fromTable(db.userConfigs,
              aliasName: $_aliasNameGenerator(
                  db.itemClickActions.id, db.userConfigs.itemClickAction));

  $$UserConfigsTableProcessedTableManager get userConfigsRefs {
    final manager = $$UserConfigsTableTableManager($_db, $_db.userConfigs)
        .filter(
            (f) => f.itemClickAction.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userConfigsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ItemClickActionsTableFilterComposer
    extends Composer<_$ConfigDatabase, $ItemClickActionsTable> {
  $$ItemClickActionsTableFilterComposer({
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

  Expression<bool> userConfigsRefs(
      Expression<bool> Function($$UserConfigsTableFilterComposer f) f) {
    final $$UserConfigsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.itemClickAction,
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
    return f(composer);
  }
}

class $$ItemClickActionsTableOrderingComposer
    extends Composer<_$ConfigDatabase, $ItemClickActionsTable> {
  $$ItemClickActionsTableOrderingComposer({
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

class $$ItemClickActionsTableAnnotationComposer
    extends Composer<_$ConfigDatabase, $ItemClickActionsTable> {
  $$ItemClickActionsTableAnnotationComposer({
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

  Expression<T> userConfigsRefs<T extends Object>(
      Expression<T> Function($$UserConfigsTableAnnotationComposer a) f) {
    final $$UserConfigsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userConfigs,
        getReferencedColumn: (t) => t.itemClickAction,
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
    return f(composer);
  }
}

class $$ItemClickActionsTableTableManager extends RootTableManager<
    _$ConfigDatabase,
    $ItemClickActionsTable,
    ItemClickActionEntity,
    $$ItemClickActionsTableFilterComposer,
    $$ItemClickActionsTableOrderingComposer,
    $$ItemClickActionsTableAnnotationComposer,
    $$ItemClickActionsTableCreateCompanionBuilder,
    $$ItemClickActionsTableUpdateCompanionBuilder,
    (ItemClickActionEntity, $$ItemClickActionsTableReferences),
    ItemClickActionEntity,
    PrefetchHooks Function({bool userConfigsRefs})> {
  $$ItemClickActionsTableTableManager(
      _$ConfigDatabase db, $ItemClickActionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemClickActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemClickActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemClickActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              ItemClickActionsCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              ItemClickActionsCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ItemClickActionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userConfigsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userConfigsRefs) db.userConfigs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userConfigsRefs)
                    await $_getPrefetchedData<ItemClickActionEntity,
                            $ItemClickActionsTable, UserConfig>(
                        currentTable: table,
                        referencedTable: $$ItemClickActionsTableReferences
                            ._userConfigsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ItemClickActionsTableReferences(db, table, p0)
                                .userConfigsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.itemClickAction == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ItemClickActionsTableProcessedTableManager = ProcessedTableManager<
    _$ConfigDatabase,
    $ItemClickActionsTable,
    ItemClickActionEntity,
    $$ItemClickActionsTableFilterComposer,
    $$ItemClickActionsTableOrderingComposer,
    $$ItemClickActionsTableAnnotationComposer,
    $$ItemClickActionsTableCreateCompanionBuilder,
    $$ItemClickActionsTableUpdateCompanionBuilder,
    (ItemClickActionEntity, $$ItemClickActionsTableReferences),
    ItemClickActionEntity,
    PrefetchHooks Function({bool userConfigsRefs})>;
typedef $$UserConfigsTableCreateCompanionBuilder = UserConfigsCompanion
    Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> darkMode,
  Value<bool> copyOnImport,
  Value<bool> defaultArchiveIs,
  Value<bool> defaultArchiveOrg,
  Value<String?> archiveOrgS3AccessKey,
  Value<String?> archiveOrgS3SecretKey,
  Value<String?> selectedThemeKey,
  Value<int> selectedThemeType,
  Value<int> timeDisplayFormat,
  Value<int> itemClickAction,
  Value<String?> cacheDirectory,
  Value<bool> showDescription,
  Value<bool> showImages,
  Value<bool> showTags,
  Value<bool> showCopyLink,
  Value<int> rowid,
});
typedef $$UserConfigsTableUpdateCompanionBuilder = UserConfigsCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> darkMode,
  Value<bool> copyOnImport,
  Value<bool> defaultArchiveIs,
  Value<bool> defaultArchiveOrg,
  Value<String?> archiveOrgS3AccessKey,
  Value<String?> archiveOrgS3SecretKey,
  Value<String?> selectedThemeKey,
  Value<int> selectedThemeType,
  Value<int> timeDisplayFormat,
  Value<int> itemClickAction,
  Value<String?> cacheDirectory,
  Value<bool> showDescription,
  Value<bool> showImages,
  Value<bool> showTags,
  Value<bool> showCopyLink,
  Value<int> rowid,
});

final class $$UserConfigsTableReferences
    extends BaseReferences<_$ConfigDatabase, $UserConfigsTable, UserConfig> {
  $$UserConfigsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ThemeTypesTable _selectedThemeTypeTable(_$ConfigDatabase db) =>
      db.themeTypes.createAlias($_aliasNameGenerator(
          db.userConfigs.selectedThemeType, db.themeTypes.id));

  $$ThemeTypesTableProcessedTableManager get selectedThemeType {
    final $_column = $_itemColumn<int>('selected_theme_type')!;

    final manager = $$ThemeTypesTableTableManager($_db, $_db.themeTypes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_selectedThemeTypeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TimeDisplayFormatsTable _timeDisplayFormatTable(
          _$ConfigDatabase db) =>
      db.timeDisplayFormats.createAlias($_aliasNameGenerator(
          db.userConfigs.timeDisplayFormat, db.timeDisplayFormats.id));

  $$TimeDisplayFormatsTableProcessedTableManager get timeDisplayFormat {
    final $_column = $_itemColumn<int>('time_display_format')!;

    final manager =
        $$TimeDisplayFormatsTableTableManager($_db, $_db.timeDisplayFormats)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_timeDisplayFormatTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ItemClickActionsTable _itemClickActionTable(_$ConfigDatabase db) =>
      db.itemClickActions.createAlias($_aliasNameGenerator(
          db.userConfigs.itemClickAction, db.itemClickActions.id));

  $$ItemClickActionsTableProcessedTableManager get itemClickAction {
    final $_column = $_itemColumn<int>('item_click_action')!;

    final manager =
        $$ItemClickActionsTableTableManager($_db, $_db.itemClickActions)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemClickActionTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get darkMode => $composableBuilder(
      column: $table.darkMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get copyOnImport => $composableBuilder(
      column: $table.copyOnImport, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get defaultArchiveIs => $composableBuilder(
      column: $table.defaultArchiveIs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get defaultArchiveOrg => $composableBuilder(
      column: $table.defaultArchiveOrg,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get archiveOrgS3AccessKey => $composableBuilder(
      column: $table.archiveOrgS3AccessKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get archiveOrgS3SecretKey => $composableBuilder(
      column: $table.archiveOrgS3SecretKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get selectedThemeKey => $composableBuilder(
      column: $table.selectedThemeKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cacheDirectory => $composableBuilder(
      column: $table.cacheDirectory,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showDescription => $composableBuilder(
      column: $table.showDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showImages => $composableBuilder(
      column: $table.showImages, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showTags => $composableBuilder(
      column: $table.showTags, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showCopyLink => $composableBuilder(
      column: $table.showCopyLink, builder: (column) => ColumnFilters(column));

  $$ThemeTypesTableFilterComposer get selectedThemeType {
    final $$ThemeTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.selectedThemeType,
        referencedTable: $db.themeTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ThemeTypesTableFilterComposer(
              $db: $db,
              $table: $db.themeTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TimeDisplayFormatsTableFilterComposer get timeDisplayFormat {
    final $$TimeDisplayFormatsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.timeDisplayFormat,
        referencedTable: $db.timeDisplayFormats,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TimeDisplayFormatsTableFilterComposer(
              $db: $db,
              $table: $db.timeDisplayFormats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ItemClickActionsTableFilterComposer get itemClickAction {
    final $$ItemClickActionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemClickAction,
        referencedTable: $db.itemClickActions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemClickActionsTableFilterComposer(
              $db: $db,
              $table: $db.itemClickActions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get darkMode => $composableBuilder(
      column: $table.darkMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get copyOnImport => $composableBuilder(
      column: $table.copyOnImport,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get defaultArchiveIs => $composableBuilder(
      column: $table.defaultArchiveIs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get defaultArchiveOrg => $composableBuilder(
      column: $table.defaultArchiveOrg,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get archiveOrgS3AccessKey => $composableBuilder(
      column: $table.archiveOrgS3AccessKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get archiveOrgS3SecretKey => $composableBuilder(
      column: $table.archiveOrgS3SecretKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get selectedThemeKey => $composableBuilder(
      column: $table.selectedThemeKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cacheDirectory => $composableBuilder(
      column: $table.cacheDirectory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showDescription => $composableBuilder(
      column: $table.showDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showImages => $composableBuilder(
      column: $table.showImages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showTags => $composableBuilder(
      column: $table.showTags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showCopyLink => $composableBuilder(
      column: $table.showCopyLink,
      builder: (column) => ColumnOrderings(column));

  $$ThemeTypesTableOrderingComposer get selectedThemeType {
    final $$ThemeTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.selectedThemeType,
        referencedTable: $db.themeTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ThemeTypesTableOrderingComposer(
              $db: $db,
              $table: $db.themeTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TimeDisplayFormatsTableOrderingComposer get timeDisplayFormat {
    final $$TimeDisplayFormatsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.timeDisplayFormat,
        referencedTable: $db.timeDisplayFormats,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TimeDisplayFormatsTableOrderingComposer(
              $db: $db,
              $table: $db.timeDisplayFormats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ItemClickActionsTableOrderingComposer get itemClickAction {
    final $$ItemClickActionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemClickAction,
        referencedTable: $db.itemClickActions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemClickActionsTableOrderingComposer(
              $db: $db,
              $table: $db.itemClickActions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get darkMode =>
      $composableBuilder(column: $table.darkMode, builder: (column) => column);

  GeneratedColumn<bool> get copyOnImport => $composableBuilder(
      column: $table.copyOnImport, builder: (column) => column);

  GeneratedColumn<bool> get defaultArchiveIs => $composableBuilder(
      column: $table.defaultArchiveIs, builder: (column) => column);

  GeneratedColumn<bool> get defaultArchiveOrg => $composableBuilder(
      column: $table.defaultArchiveOrg, builder: (column) => column);

  GeneratedColumn<String> get archiveOrgS3AccessKey => $composableBuilder(
      column: $table.archiveOrgS3AccessKey, builder: (column) => column);

  GeneratedColumn<String> get archiveOrgS3SecretKey => $composableBuilder(
      column: $table.archiveOrgS3SecretKey, builder: (column) => column);

  GeneratedColumn<String> get selectedThemeKey => $composableBuilder(
      column: $table.selectedThemeKey, builder: (column) => column);

  GeneratedColumn<String> get cacheDirectory => $composableBuilder(
      column: $table.cacheDirectory, builder: (column) => column);

  GeneratedColumn<bool> get showDescription => $composableBuilder(
      column: $table.showDescription, builder: (column) => column);

  GeneratedColumn<bool> get showImages => $composableBuilder(
      column: $table.showImages, builder: (column) => column);

  GeneratedColumn<bool> get showTags =>
      $composableBuilder(column: $table.showTags, builder: (column) => column);

  GeneratedColumn<bool> get showCopyLink => $composableBuilder(
      column: $table.showCopyLink, builder: (column) => column);

  $$ThemeTypesTableAnnotationComposer get selectedThemeType {
    final $$ThemeTypesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.selectedThemeType,
        referencedTable: $db.themeTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ThemeTypesTableAnnotationComposer(
              $db: $db,
              $table: $db.themeTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TimeDisplayFormatsTableAnnotationComposer get timeDisplayFormat {
    final $$TimeDisplayFormatsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.timeDisplayFormat,
            referencedTable: $db.timeDisplayFormats,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TimeDisplayFormatsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.timeDisplayFormats,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$ItemClickActionsTableAnnotationComposer get itemClickAction {
    final $$ItemClickActionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemClickAction,
        referencedTable: $db.itemClickActions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemClickActionsTableAnnotationComposer(
              $db: $db,
              $table: $db.itemClickActions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

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
        {bool selectedThemeType,
        bool timeDisplayFormat,
        bool itemClickAction,
        bool userThemesRefs,
        bool backupSettingsRefs})> {
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> darkMode = const Value.absent(),
            Value<bool> copyOnImport = const Value.absent(),
            Value<bool> defaultArchiveIs = const Value.absent(),
            Value<bool> defaultArchiveOrg = const Value.absent(),
            Value<String?> archiveOrgS3AccessKey = const Value.absent(),
            Value<String?> archiveOrgS3SecretKey = const Value.absent(),
            Value<String?> selectedThemeKey = const Value.absent(),
            Value<int> selectedThemeType = const Value.absent(),
            Value<int> timeDisplayFormat = const Value.absent(),
            Value<int> itemClickAction = const Value.absent(),
            Value<String?> cacheDirectory = const Value.absent(),
            Value<bool> showDescription = const Value.absent(),
            Value<bool> showImages = const Value.absent(),
            Value<bool> showTags = const Value.absent(),
            Value<bool> showCopyLink = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserConfigsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            darkMode: darkMode,
            copyOnImport: copyOnImport,
            defaultArchiveIs: defaultArchiveIs,
            defaultArchiveOrg: defaultArchiveOrg,
            archiveOrgS3AccessKey: archiveOrgS3AccessKey,
            archiveOrgS3SecretKey: archiveOrgS3SecretKey,
            selectedThemeKey: selectedThemeKey,
            selectedThemeType: selectedThemeType,
            timeDisplayFormat: timeDisplayFormat,
            itemClickAction: itemClickAction,
            cacheDirectory: cacheDirectory,
            showDescription: showDescription,
            showImages: showImages,
            showTags: showTags,
            showCopyLink: showCopyLink,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> darkMode = const Value.absent(),
            Value<bool> copyOnImport = const Value.absent(),
            Value<bool> defaultArchiveIs = const Value.absent(),
            Value<bool> defaultArchiveOrg = const Value.absent(),
            Value<String?> archiveOrgS3AccessKey = const Value.absent(),
            Value<String?> archiveOrgS3SecretKey = const Value.absent(),
            Value<String?> selectedThemeKey = const Value.absent(),
            Value<int> selectedThemeType = const Value.absent(),
            Value<int> timeDisplayFormat = const Value.absent(),
            Value<int> itemClickAction = const Value.absent(),
            Value<String?> cacheDirectory = const Value.absent(),
            Value<bool> showDescription = const Value.absent(),
            Value<bool> showImages = const Value.absent(),
            Value<bool> showTags = const Value.absent(),
            Value<bool> showCopyLink = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserConfigsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            darkMode: darkMode,
            copyOnImport: copyOnImport,
            defaultArchiveIs: defaultArchiveIs,
            defaultArchiveOrg: defaultArchiveOrg,
            archiveOrgS3AccessKey: archiveOrgS3AccessKey,
            archiveOrgS3SecretKey: archiveOrgS3SecretKey,
            selectedThemeKey: selectedThemeKey,
            selectedThemeType: selectedThemeType,
            timeDisplayFormat: timeDisplayFormat,
            itemClickAction: itemClickAction,
            cacheDirectory: cacheDirectory,
            showDescription: showDescription,
            showImages: showImages,
            showTags: showTags,
            showCopyLink: showCopyLink,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserConfigsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {selectedThemeType = false,
              timeDisplayFormat = false,
              itemClickAction = false,
              userThemesRefs = false,
              backupSettingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userThemesRefs) db.userThemes,
                if (backupSettingsRefs) db.backupSettings
              ],
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
                if (selectedThemeType) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.selectedThemeType,
                    referencedTable: $$UserConfigsTableReferences
                        ._selectedThemeTypeTable(db),
                    referencedColumn: $$UserConfigsTableReferences
                        ._selectedThemeTypeTable(db)
                        .id,
                  ) as T;
                }
                if (timeDisplayFormat) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.timeDisplayFormat,
                    referencedTable: $$UserConfigsTableReferences
                        ._timeDisplayFormatTable(db),
                    referencedColumn: $$UserConfigsTableReferences
                        ._timeDisplayFormatTable(db)
                        .id,
                  ) as T;
                }
                if (itemClickAction) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.itemClickAction,
                    referencedTable:
                        $$UserConfigsTableReferences._itemClickActionTable(db),
                    referencedColumn: $$UserConfigsTableReferences
                        ._itemClickActionTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
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
        {bool selectedThemeType,
        bool timeDisplayFormat,
        bool itemClickAction,
        bool userThemesRefs,
        bool backupSettingsRefs})>;
typedef $$SeedTypesTableCreateCompanionBuilder = SeedTypesCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$SeedTypesTableUpdateCompanionBuilder = SeedTypesCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$SeedTypesTableReferences
    extends BaseReferences<_$ConfigDatabase, $SeedTypesTable, SeedTypeEntity> {
  $$SeedTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserThemesTable, List<UserTheme>>
      _userThemesRefsTable(_$ConfigDatabase db) =>
          MultiTypedResultKey.fromTable(db.userThemes,
              aliasName: $_aliasNameGenerator(
                  db.seedTypes.id, db.userThemes.seedType));

  $$UserThemesTableProcessedTableManager get userThemesRefs {
    final manager = $$UserThemesTableTableManager($_db, $_db.userThemes)
        .filter((f) => f.seedType.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userThemesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SeedTypesTableFilterComposer
    extends Composer<_$ConfigDatabase, $SeedTypesTable> {
  $$SeedTypesTableFilterComposer({
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

  Expression<bool> userThemesRefs(
      Expression<bool> Function($$UserThemesTableFilterComposer f) f) {
    final $$UserThemesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userThemes,
        getReferencedColumn: (t) => t.seedType,
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
}

class $$SeedTypesTableOrderingComposer
    extends Composer<_$ConfigDatabase, $SeedTypesTable> {
  $$SeedTypesTableOrderingComposer({
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

class $$SeedTypesTableAnnotationComposer
    extends Composer<_$ConfigDatabase, $SeedTypesTable> {
  $$SeedTypesTableAnnotationComposer({
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

  Expression<T> userThemesRefs<T extends Object>(
      Expression<T> Function($$UserThemesTableAnnotationComposer a) f) {
    final $$UserThemesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userThemes,
        getReferencedColumn: (t) => t.seedType,
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
}

class $$SeedTypesTableTableManager extends RootTableManager<
    _$ConfigDatabase,
    $SeedTypesTable,
    SeedTypeEntity,
    $$SeedTypesTableFilterComposer,
    $$SeedTypesTableOrderingComposer,
    $$SeedTypesTableAnnotationComposer,
    $$SeedTypesTableCreateCompanionBuilder,
    $$SeedTypesTableUpdateCompanionBuilder,
    (SeedTypeEntity, $$SeedTypesTableReferences),
    SeedTypeEntity,
    PrefetchHooks Function({bool userThemesRefs})> {
  $$SeedTypesTableTableManager(_$ConfigDatabase db, $SeedTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeedTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeedTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeedTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              SeedTypesCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              SeedTypesCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SeedTypesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userThemesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userThemesRefs) db.userThemes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userThemesRefs)
                    await $_getPrefetchedData<SeedTypeEntity, $SeedTypesTable,
                            UserTheme>(
                        currentTable: table,
                        referencedTable:
                            $$SeedTypesTableReferences._userThemesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SeedTypesTableReferences(db, table, p0)
                                .userThemesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.seedType == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SeedTypesTableProcessedTableManager = ProcessedTableManager<
    _$ConfigDatabase,
    $SeedTypesTable,
    SeedTypeEntity,
    $$SeedTypesTableFilterComposer,
    $$SeedTypesTableOrderingComposer,
    $$SeedTypesTableAnnotationComposer,
    $$SeedTypesTableCreateCompanionBuilder,
    $$SeedTypesTableUpdateCompanionBuilder,
    (SeedTypeEntity, $$SeedTypesTableReferences),
    SeedTypeEntity,
    PrefetchHooks Function({bool userThemesRefs})>;
typedef $$UserThemesTableCreateCompanionBuilder = UserThemesCompanion Function({
  required String id,
  required String userConfigId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required String name,
  required int primaryColor,
  required int secondaryColor,
  Value<int?> tertiaryColor,
  Value<int> seedType,
  Value<int> rowid,
});
typedef $$UserThemesTableUpdateCompanionBuilder = UserThemesCompanion Function({
  Value<String> id,
  Value<String> userConfigId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> name,
  Value<int> primaryColor,
  Value<int> secondaryColor,
  Value<int?> tertiaryColor,
  Value<int> seedType,
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

  static $SeedTypesTable _seedTypeTable(_$ConfigDatabase db) =>
      db.seedTypes.createAlias(
          $_aliasNameGenerator(db.userThemes.seedType, db.seedTypes.id));

  $$SeedTypesTableProcessedTableManager get seedType {
    final $_column = $_itemColumn<int>('seed_type')!;

    final manager = $$SeedTypesTableTableManager($_db, $_db.seedTypes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seedTypeTable($_db));
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get primaryColor => $composableBuilder(
      column: $table.primaryColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get secondaryColor => $composableBuilder(
      column: $table.secondaryColor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tertiaryColor => $composableBuilder(
      column: $table.tertiaryColor, builder: (column) => ColumnFilters(column));

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

  $$SeedTypesTableFilterComposer get seedType {
    final $$SeedTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seedType,
        referencedTable: $db.seedTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeedTypesTableFilterComposer(
              $db: $db,
              $table: $db.seedTypes,
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get primaryColor => $composableBuilder(
      column: $table.primaryColor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get secondaryColor => $composableBuilder(
      column: $table.secondaryColor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tertiaryColor => $composableBuilder(
      column: $table.tertiaryColor,
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

  $$SeedTypesTableOrderingComposer get seedType {
    final $$SeedTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seedType,
        referencedTable: $db.seedTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeedTypesTableOrderingComposer(
              $db: $db,
              $table: $db.seedTypes,
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get primaryColor => $composableBuilder(
      column: $table.primaryColor, builder: (column) => column);

  GeneratedColumn<int> get secondaryColor => $composableBuilder(
      column: $table.secondaryColor, builder: (column) => column);

  GeneratedColumn<int> get tertiaryColor => $composableBuilder(
      column: $table.tertiaryColor, builder: (column) => column);

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

  $$SeedTypesTableAnnotationComposer get seedType {
    final $$SeedTypesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seedType,
        referencedTable: $db.seedTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeedTypesTableAnnotationComposer(
              $db: $db,
              $table: $db.seedTypes,
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
    PrefetchHooks Function({bool userConfigId, bool seedType})> {
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> primaryColor = const Value.absent(),
            Value<int> secondaryColor = const Value.absent(),
            Value<int?> tertiaryColor = const Value.absent(),
            Value<int> seedType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserThemesCompanion(
            id: id,
            userConfigId: userConfigId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: name,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            tertiaryColor: tertiaryColor,
            seedType: seedType,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userConfigId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            required String name,
            required int primaryColor,
            required int secondaryColor,
            Value<int?> tertiaryColor = const Value.absent(),
            Value<int> seedType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserThemesCompanion.insert(
            id: id,
            userConfigId: userConfigId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: name,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            tertiaryColor: tertiaryColor,
            seedType: seedType,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserThemesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userConfigId = false, seedType = false}) {
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
                if (seedType) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.seedType,
                    referencedTable:
                        $$UserThemesTableReferences._seedTypeTable(db),
                    referencedColumn:
                        $$UserThemesTableReferences._seedTypeTable(db).id,
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
    PrefetchHooks Function({bool userConfigId, bool seedType})>;
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

class $ConfigDatabaseManager {
  final _$ConfigDatabase _db;
  $ConfigDatabaseManager(this._db);
  $$ThemeTypesTableTableManager get themeTypes =>
      $$ThemeTypesTableTableManager(_db, _db.themeTypes);
  $$TimeDisplayFormatsTableTableManager get timeDisplayFormats =>
      $$TimeDisplayFormatsTableTableManager(_db, _db.timeDisplayFormats);
  $$ItemClickActionsTableTableManager get itemClickActions =>
      $$ItemClickActionsTableTableManager(_db, _db.itemClickActions);
  $$UserConfigsTableTableManager get userConfigs =>
      $$UserConfigsTableTableManager(_db, _db.userConfigs);
  $$SeedTypesTableTableManager get seedTypes =>
      $$SeedTypesTableTableManager(_db, _db.seedTypes);
  $$UserThemesTableTableManager get userThemes =>
      $$UserThemesTableTableManager(_db, _db.userThemes);
  $$BackupSettingsTableTableManager get backupSettings =>
      $$BackupSettingsTableTableManager(_db, _db.backupSettings);
}
