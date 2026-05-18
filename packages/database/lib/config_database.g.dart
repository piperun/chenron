// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_database.dart';

// ignore_for_file: type=lint
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
  @override
  late final GeneratedColumnWithTypeConverter<ThemeType, int>
      selectedThemeType = GeneratedColumn<int>(
              'selected_theme_type', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<ThemeType>(
              $UserConfigsTable.$converterselectedThemeType);
  @override
  late final GeneratedColumnWithTypeConverter<TimeDisplayFormat, int>
      timeDisplayFormat = GeneratedColumn<int>(
              'time_display_format', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<TimeDisplayFormat>(
              $UserConfigsTable.$convertertimeDisplayFormat);
  @override
  late final GeneratedColumnWithTypeConverter<ItemClickAction, int>
      itemClickAction = GeneratedColumn<int>(
              'item_click_action', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<ItemClickAction>(
              $UserConfigsTable.$converteritemClickAction);
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
      selectedThemeType: $UserConfigsTable.$converterselectedThemeType.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.int,
              data['${effectivePrefix}selected_theme_type'])!),
      timeDisplayFormat: $UserConfigsTable.$convertertimeDisplayFormat.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.int,
              data['${effectivePrefix}time_display_format'])!),
      itemClickAction: $UserConfigsTable.$converteritemClickAction.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}item_click_action'])!),
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

  static JsonTypeConverter2<ThemeType, int, int> $converterselectedThemeType =
      const EnumIndexConverter<ThemeType>(ThemeType.values);
  static JsonTypeConverter2<TimeDisplayFormat, int, int>
      $convertertimeDisplayFormat =
      const EnumIndexConverter<TimeDisplayFormat>(TimeDisplayFormat.values);
  static JsonTypeConverter2<ItemClickAction, int, int>
      $converteritemClickAction =
      const EnumIndexConverter<ItemClickAction>(ItemClickAction.values);
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
  final ThemeType selectedThemeType;
  final TimeDisplayFormat timeDisplayFormat;
  final ItemClickAction itemClickAction;
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
    {
      map['selected_theme_type'] = Variable<int>($UserConfigsTable
          .$converterselectedThemeType
          .toSql(selectedThemeType));
    }
    {
      map['time_display_format'] = Variable<int>($UserConfigsTable
          .$convertertimeDisplayFormat
          .toSql(timeDisplayFormat));
    }
    {
      map['item_click_action'] = Variable<int>(
          $UserConfigsTable.$converteritemClickAction.toSql(itemClickAction));
    }
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
      selectedThemeType: $UserConfigsTable.$converterselectedThemeType
          .fromJson(serializer.fromJson<int>(json['selectedThemeType'])),
      timeDisplayFormat: $UserConfigsTable.$convertertimeDisplayFormat
          .fromJson(serializer.fromJson<int>(json['timeDisplayFormat'])),
      itemClickAction: $UserConfigsTable.$converteritemClickAction
          .fromJson(serializer.fromJson<int>(json['itemClickAction'])),
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
      'selectedThemeType': serializer.toJson<int>($UserConfigsTable
          .$converterselectedThemeType
          .toJson(selectedThemeType)),
      'timeDisplayFormat': serializer.toJson<int>($UserConfigsTable
          .$convertertimeDisplayFormat
          .toJson(timeDisplayFormat)),
      'itemClickAction': serializer.toJson<int>(
          $UserConfigsTable.$converteritemClickAction.toJson(itemClickAction)),
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
          ThemeType? selectedThemeType,
          TimeDisplayFormat? timeDisplayFormat,
          ItemClickAction? itemClickAction,
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
  final Value<ThemeType> selectedThemeType;
  final Value<TimeDisplayFormat> timeDisplayFormat;
  final Value<ItemClickAction> itemClickAction;
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
      Value<ThemeType>? selectedThemeType,
      Value<TimeDisplayFormat>? timeDisplayFormat,
      Value<ItemClickAction>? itemClickAction,
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
      map['selected_theme_type'] = Variable<int>($UserConfigsTable
          .$converterselectedThemeType
          .toSql(selectedThemeType.value));
    }
    if (timeDisplayFormat.present) {
      map['time_display_format'] = Variable<int>($UserConfigsTable
          .$convertertimeDisplayFormat
          .toSql(timeDisplayFormat.value));
    }
    if (itemClickAction.present) {
      map['item_click_action'] = Variable<int>($UserConfigsTable
          .$converteritemClickAction
          .toSql(itemClickAction.value));
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
  @override
  late final GeneratedColumnWithTypeConverter<SeedType, int> seedType =
      GeneratedColumn<int>('seed_type', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<SeedType>($UserThemesTable.$converterseedType);
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
      seedType: $UserThemesTable.$converterseedType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}seed_type'])!),
    );
  }

  @override
  $UserThemesTable createAlias(String alias) {
    return $UserThemesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SeedType, int, int> $converterseedType =
      const EnumIndexConverter<SeedType>(SeedType.values);
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
  final SeedType seedType;
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
    {
      map['seed_type'] =
          Variable<int>($UserThemesTable.$converterseedType.toSql(seedType));
    }
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
      seedType: $UserThemesTable.$converterseedType
          .fromJson(serializer.fromJson<int>(json['seedType'])),
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
      'seedType': serializer
          .toJson<int>($UserThemesTable.$converterseedType.toJson(seedType)),
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
          SeedType? seedType}) =>
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
  final Value<SeedType> seedType;
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
      Value<SeedType>? seedType,
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
      map['seed_type'] = Variable<int>(
          $UserThemesTable.$converterseedType.toSql(seedType.value));
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
  late final $UserConfigsTable userConfigs = $UserConfigsTable(this);
  late final $UserThemesTable userThemes = $UserThemesTable(this);
  late final $BackupSettingsTable backupSettings = $BackupSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [userConfigs, userThemes, backupSettings];
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
  Value<ThemeType> selectedThemeType,
  Value<TimeDisplayFormat> timeDisplayFormat,
  Value<ItemClickAction> itemClickAction,
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
  Value<ThemeType> selectedThemeType,
  Value<TimeDisplayFormat> timeDisplayFormat,
  Value<ItemClickAction> itemClickAction,
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

  ColumnWithTypeConverterFilters<ThemeType, ThemeType, int>
      get selectedThemeType => $composableBuilder(
          column: $table.selectedThemeType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<TimeDisplayFormat, TimeDisplayFormat, int>
      get timeDisplayFormat => $composableBuilder(
          column: $table.timeDisplayFormat,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ItemClickAction, ItemClickAction, int>
      get itemClickAction => $composableBuilder(
          column: $table.itemClickAction,
          builder: (column) => ColumnWithTypeConverterFilters(column));

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

  ColumnOrderings<int> get selectedThemeType => $composableBuilder(
      column: $table.selectedThemeType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeDisplayFormat => $composableBuilder(
      column: $table.timeDisplayFormat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get itemClickAction => $composableBuilder(
      column: $table.itemClickAction,
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

  GeneratedColumnWithTypeConverter<ThemeType, int> get selectedThemeType =>
      $composableBuilder(
          column: $table.selectedThemeType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TimeDisplayFormat, int>
      get timeDisplayFormat => $composableBuilder(
          column: $table.timeDisplayFormat, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ItemClickAction, int> get itemClickAction =>
      $composableBuilder(
          column: $table.itemClickAction, builder: (column) => column);

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
    PrefetchHooks Function({bool userThemesRefs, bool backupSettingsRefs})> {
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
            Value<ThemeType> selectedThemeType = const Value.absent(),
            Value<TimeDisplayFormat> timeDisplayFormat = const Value.absent(),
            Value<ItemClickAction> itemClickAction = const Value.absent(),
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
            Value<ThemeType> selectedThemeType = const Value.absent(),
            Value<TimeDisplayFormat> timeDisplayFormat = const Value.absent(),
            Value<ItemClickAction> itemClickAction = const Value.absent(),
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
              {userThemesRefs = false, backupSettingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userThemesRefs) db.userThemes,
                if (backupSettingsRefs) db.backupSettings
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
    PrefetchHooks Function({bool userThemesRefs, bool backupSettingsRefs})>;
typedef $$UserThemesTableCreateCompanionBuilder = UserThemesCompanion Function({
  required String id,
  required String userConfigId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required String name,
  required int primaryColor,
  required int secondaryColor,
  Value<int?> tertiaryColor,
  Value<SeedType> seedType,
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
  Value<SeedType> seedType,
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

  ColumnWithTypeConverterFilters<SeedType, SeedType, int> get seedType =>
      $composableBuilder(
          column: $table.seedType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

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

  ColumnOrderings<int> get seedType => $composableBuilder(
      column: $table.seedType, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumnWithTypeConverter<SeedType, int> get seedType =>
      $composableBuilder(column: $table.seedType, builder: (column) => column);

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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> primaryColor = const Value.absent(),
            Value<int> secondaryColor = const Value.absent(),
            Value<int?> tertiaryColor = const Value.absent(),
            Value<SeedType> seedType = const Value.absent(),
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
            Value<SeedType> seedType = const Value.absent(),
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

class $ConfigDatabaseManager {
  final _$ConfigDatabase _db;
  $ConfigDatabaseManager(this._db);
  $$UserConfigsTableTableManager get userConfigs =>
      $$UserConfigsTableTableManager(_db, _db.userConfigs);
  $$UserThemesTableTableManager get userThemes =>
      $$UserThemesTableTableManager(_db, _db.userThemes);
  $$BackupSettingsTableTableManager get backupSettings =>
      $$BackupSettingsTableTableManager(_db, _db.backupSettings);
}
