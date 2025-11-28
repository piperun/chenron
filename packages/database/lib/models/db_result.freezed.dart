// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'db_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DbResult {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is DbResult);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'DbResult()';
  }
}

/// @nodoc
class $DbResultCopyWith<$Res> {
  $DbResultCopyWith(DbResult _, $Res Function(DbResult) __);
}

/// Adds pattern-matching-related methods to [DbResult].
extension DbResultPatterns on DbResult {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FolderResult value)? folder,
    TResult Function(LinkResult value)? link,
    TResult Function(DocumentResult value)? document,
    TResult Function(TagResult value)? tag,
    TResult Function(UserConfigResult value)? userConfig,
    TResult Function(UserThemeResult value)? userTheme,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case FolderResult() when folder != null:
        return folder(_that);
      case LinkResult() when link != null:
        return link(_that);
      case DocumentResult() when document != null:
        return document(_that);
      case TagResult() when tag != null:
        return tag(_that);
      case UserConfigResult() when userConfig != null:
        return userConfig(_that);
      case UserThemeResult() when userTheme != null:
        return userTheme(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FolderResult value) folder,
    required TResult Function(LinkResult value) link,
    required TResult Function(DocumentResult value) document,
    required TResult Function(TagResult value) tag,
    required TResult Function(UserConfigResult value) userConfig,
    required TResult Function(UserThemeResult value) userTheme,
  }) {
    final _that = this;
    switch (_that) {
      case FolderResult():
        return folder(_that);
      case LinkResult():
        return link(_that);
      case DocumentResult():
        return document(_that);
      case TagResult():
        return tag(_that);
      case UserConfigResult():
        return userConfig(_that);
      case UserThemeResult():
        return userTheme(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FolderResult value)? folder,
    TResult? Function(LinkResult value)? link,
    TResult? Function(DocumentResult value)? document,
    TResult? Function(TagResult value)? tag,
    TResult? Function(UserConfigResult value)? userConfig,
    TResult? Function(UserThemeResult value)? userTheme,
  }) {
    final _that = this;
    switch (_that) {
      case FolderResult() when folder != null:
        return folder(_that);
      case LinkResult() when link != null:
        return link(_that);
      case DocumentResult() when document != null:
        return document(_that);
      case TagResult() when tag != null:
        return tag(_that);
      case UserConfigResult() when userConfig != null:
        return userConfig(_that);
      case UserThemeResult() when userTheme != null:
        return userTheme(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Folder data, List<Tag> tags, List<FolderItem> items)?
        folder,
    TResult Function(Link data, List<Tag> tags)? link,
    TResult Function(String title, String filePath, DocumentFileType fileType,
            List<Tag>? tags)?
        document,
    TResult Function(String name, int? color, List<String>? relatedFolderIds,
            List<String>? relatedLinkIds, List<String>? relatedDocumentIds)?
        tag,
    TResult Function(UserConfig data, List<UserTheme>? userThemes,
            BackupSetting? backupSettings)?
        userConfig,
    TResult Function(
            UserTheme data, String? userConfigId, List<String>? sharedUserIds)?
        userTheme,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case FolderResult() when folder != null:
        return folder(_that.data, _that.tags, _that.items);
      case LinkResult() when link != null:
        return link(_that.data, _that.tags);
      case DocumentResult() when document != null:
        return document(
            _that.title, _that.filePath, _that.fileType, _that.tags);
      case TagResult() when tag != null:
        return tag(_that.name, _that.color, _that.relatedFolderIds,
            _that.relatedLinkIds, _that.relatedDocumentIds);
      case UserConfigResult() when userConfig != null:
        return userConfig(_that.data, _that.userThemes, _that.backupSettings);
      case UserThemeResult() when userTheme != null:
        return userTheme(_that.data, _that.userConfigId, _that.sharedUserIds);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            Folder data, List<Tag> tags, List<FolderItem> items)
        folder,
    required TResult Function(Link data, List<Tag> tags) link,
    required TResult Function(String title, String filePath,
            DocumentFileType fileType, List<Tag>? tags)
        document,
    required TResult Function(
            String name,
            int? color,
            List<String>? relatedFolderIds,
            List<String>? relatedLinkIds,
            List<String>? relatedDocumentIds)
        tag,
    required TResult Function(UserConfig data, List<UserTheme>? userThemes,
            BackupSetting? backupSettings)
        userConfig,
    required TResult Function(
            UserTheme data, String? userConfigId, List<String>? sharedUserIds)
        userTheme,
  }) {
    final _that = this;
    switch (_that) {
      case FolderResult():
        return folder(_that.data, _that.tags, _that.items);
      case LinkResult():
        return link(_that.data, _that.tags);
      case DocumentResult():
        return document(
            _that.title, _that.filePath, _that.fileType, _that.tags);
      case TagResult():
        return tag(_that.name, _that.color, _that.relatedFolderIds,
            _that.relatedLinkIds, _that.relatedDocumentIds);
      case UserConfigResult():
        return userConfig(_that.data, _that.userThemes, _that.backupSettings);
      case UserThemeResult():
        return userTheme(_that.data, _that.userConfigId, _that.sharedUserIds);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Folder data, List<Tag> tags, List<FolderItem> items)?
        folder,
    TResult? Function(Link data, List<Tag> tags)? link,
    TResult? Function(String title, String filePath, DocumentFileType fileType,
            List<Tag>? tags)?
        document,
    TResult? Function(String name, int? color, List<String>? relatedFolderIds,
            List<String>? relatedLinkIds, List<String>? relatedDocumentIds)?
        tag,
    TResult? Function(UserConfig data, List<UserTheme>? userThemes,
            BackupSetting? backupSettings)?
        userConfig,
    TResult? Function(
            UserTheme data, String? userConfigId, List<String>? sharedUserIds)?
        userTheme,
  }) {
    final _that = this;
    switch (_that) {
      case FolderResult() when folder != null:
        return folder(_that.data, _that.tags, _that.items);
      case LinkResult() when link != null:
        return link(_that.data, _that.tags);
      case DocumentResult() when document != null:
        return document(
            _that.title, _that.filePath, _that.fileType, _that.tags);
      case TagResult() when tag != null:
        return tag(_that.name, _that.color, _that.relatedFolderIds,
            _that.relatedLinkIds, _that.relatedDocumentIds);
      case UserConfigResult() when userConfig != null:
        return userConfig(_that.data, _that.userThemes, _that.backupSettings);
      case UserThemeResult() when userTheme != null:
        return userTheme(_that.data, _that.userConfigId, _that.sharedUserIds);
      case _:
        return null;
    }
  }
}

/// @nodoc

class FolderResult implements DbResult {
  const FolderResult(
      {required this.data,
      required final List<Tag> tags,
      required final List<FolderItem> items})
      : _tags = tags,
        _items = items;

  final Folder data;
  final List<Tag> _tags;
  List<Tag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<FolderItem> _items;
  List<FolderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// Create a copy of DbResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FolderResultCopyWith<FolderResult> get copyWith =>
      _$FolderResultCopyWithImpl<FolderResult>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FolderResult &&
            (identical(other.data, data) || other.data == data) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      data,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_items));

  @override
  String toString() {
    return 'DbResult.folder(data: $data, tags: $tags, items: $items)';
  }
}

/// @nodoc
abstract mixin class $FolderResultCopyWith<$Res>
    implements $DbResultCopyWith<$Res> {
  factory $FolderResultCopyWith(
          FolderResult value, $Res Function(FolderResult) _then) =
      _$FolderResultCopyWithImpl;
  @useResult
  $Res call({Folder data, List<Tag> tags, List<FolderItem> items});
}

/// @nodoc
class _$FolderResultCopyWithImpl<$Res> implements $FolderResultCopyWith<$Res> {
  _$FolderResultCopyWithImpl(this._self, this._then);

  final FolderResult _self;
  final $Res Function(FolderResult) _then;

  /// Create a copy of DbResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
    Object? tags = null,
    Object? items = null,
  }) {
    return _then(FolderResult(
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as Folder,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>,
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<FolderItem>,
    ));
  }
}

/// @nodoc

class LinkResult implements DbResult {
  const LinkResult({required this.data, required final List<Tag> tags})
      : _tags = tags;

  final Link data;
  final List<Tag> _tags;
  List<Tag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Create a copy of DbResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LinkResultCopyWith<LinkResult> get copyWith =>
      _$LinkResultCopyWithImpl<LinkResult>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LinkResult &&
            (identical(other.data, data) || other.data == data) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, data, const DeepCollectionEquality().hash(_tags));

  @override
  String toString() {
    return 'DbResult.link(data: $data, tags: $tags)';
  }
}

/// @nodoc
abstract mixin class $LinkResultCopyWith<$Res>
    implements $DbResultCopyWith<$Res> {
  factory $LinkResultCopyWith(
          LinkResult value, $Res Function(LinkResult) _then) =
      _$LinkResultCopyWithImpl;
  @useResult
  $Res call({Link data, List<Tag> tags});
}

/// @nodoc
class _$LinkResultCopyWithImpl<$Res> implements $LinkResultCopyWith<$Res> {
  _$LinkResultCopyWithImpl(this._self, this._then);

  final LinkResult _self;
  final $Res Function(LinkResult) _then;

  /// Create a copy of DbResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
    Object? tags = null,
  }) {
    return _then(LinkResult(
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as Link,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>,
    ));
  }
}

/// @nodoc

class DocumentResult implements DbResult {
  const DocumentResult(
      {required this.title,
      required this.filePath,
      required this.fileType,
      final List<Tag>? tags})
      : _tags = tags;

  final String title;
  final String filePath;
  final DocumentFileType fileType;
  final List<Tag>? _tags;
  List<Tag>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of DbResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DocumentResultCopyWith<DocumentResult> get copyWith =>
      _$DocumentResultCopyWithImpl<DocumentResult>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DocumentResult &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            const DeepCollectionEquality().equals(other.fileType, fileType) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      filePath,
      const DeepCollectionEquality().hash(fileType),
      const DeepCollectionEquality().hash(_tags));

  @override
  String toString() {
    return 'DbResult.document(title: $title, filePath: $filePath, fileType: $fileType, tags: $tags)';
  }
}

/// @nodoc
abstract mixin class $DocumentResultCopyWith<$Res>
    implements $DbResultCopyWith<$Res> {
  factory $DocumentResultCopyWith(
          DocumentResult value, $Res Function(DocumentResult) _then) =
      _$DocumentResultCopyWithImpl;
  @useResult
  $Res call(
      {String title,
      String filePath,
      DocumentFileType fileType,
      List<Tag>? tags});
}

/// @nodoc
class _$DocumentResultCopyWithImpl<$Res>
    implements $DocumentResultCopyWith<$Res> {
  _$DocumentResultCopyWithImpl(this._self, this._then);

  final DocumentResult _self;
  final $Res Function(DocumentResult) _then;

  /// Create a copy of DbResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? title = null,
    Object? filePath = null,
    Object? fileType = freezed,
    Object? tags = freezed,
  }) {
    return _then(DocumentResult(
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      filePath: null == filePath
          ? _self.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileType: freezed == fileType
          ? _self.fileType
          : fileType // ignore: cast_nullable_to_non_nullable
              as DocumentFileType,
      tags: freezed == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>?,
    ));
  }
}

/// @nodoc

class TagResult implements DbResult {
  const TagResult(
      {required this.name,
      this.color,
      final List<String>? relatedFolderIds,
      final List<String>? relatedLinkIds,
      final List<String>? relatedDocumentIds})
      : _relatedFolderIds = relatedFolderIds,
        _relatedLinkIds = relatedLinkIds,
        _relatedDocumentIds = relatedDocumentIds;

  final String name;
  final int? color;
  final List<String>? _relatedFolderIds;
  List<String>? get relatedFolderIds {
    final value = _relatedFolderIds;
    if (value == null) return null;
    if (_relatedFolderIds is EqualUnmodifiableListView)
      return _relatedFolderIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _relatedLinkIds;
  List<String>? get relatedLinkIds {
    final value = _relatedLinkIds;
    if (value == null) return null;
    if (_relatedLinkIds is EqualUnmodifiableListView) return _relatedLinkIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _relatedDocumentIds;
  List<String>? get relatedDocumentIds {
    final value = _relatedDocumentIds;
    if (value == null) return null;
    if (_relatedDocumentIds is EqualUnmodifiableListView)
      return _relatedDocumentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of DbResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TagResultCopyWith<TagResult> get copyWith =>
      _$TagResultCopyWithImpl<TagResult>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TagResult &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.color, color) || other.color == color) &&
            const DeepCollectionEquality()
                .equals(other._relatedFolderIds, _relatedFolderIds) &&
            const DeepCollectionEquality()
                .equals(other._relatedLinkIds, _relatedLinkIds) &&
            const DeepCollectionEquality()
                .equals(other._relatedDocumentIds, _relatedDocumentIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      color,
      const DeepCollectionEquality().hash(_relatedFolderIds),
      const DeepCollectionEquality().hash(_relatedLinkIds),
      const DeepCollectionEquality().hash(_relatedDocumentIds));

  @override
  String toString() {
    return 'DbResult.tag(name: $name, color: $color, relatedFolderIds: $relatedFolderIds, relatedLinkIds: $relatedLinkIds, relatedDocumentIds: $relatedDocumentIds)';
  }
}

/// @nodoc
abstract mixin class $TagResultCopyWith<$Res>
    implements $DbResultCopyWith<$Res> {
  factory $TagResultCopyWith(TagResult value, $Res Function(TagResult) _then) =
      _$TagResultCopyWithImpl;
  @useResult
  $Res call(
      {String name,
      int? color,
      List<String>? relatedFolderIds,
      List<String>? relatedLinkIds,
      List<String>? relatedDocumentIds});
}

/// @nodoc
class _$TagResultCopyWithImpl<$Res> implements $TagResultCopyWith<$Res> {
  _$TagResultCopyWithImpl(this._self, this._then);

  final TagResult _self;
  final $Res Function(TagResult) _then;

  /// Create a copy of DbResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? color = freezed,
    Object? relatedFolderIds = freezed,
    Object? relatedLinkIds = freezed,
    Object? relatedDocumentIds = freezed,
  }) {
    return _then(TagResult(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      color: freezed == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as int?,
      relatedFolderIds: freezed == relatedFolderIds
          ? _self._relatedFolderIds
          : relatedFolderIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      relatedLinkIds: freezed == relatedLinkIds
          ? _self._relatedLinkIds
          : relatedLinkIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      relatedDocumentIds: freezed == relatedDocumentIds
          ? _self._relatedDocumentIds
          : relatedDocumentIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc

class UserConfigResult implements DbResult {
  const UserConfigResult(
      {required this.data,
      final List<UserTheme>? userThemes,
      this.backupSettings})
      : _userThemes = userThemes;

  final UserConfig data;
  final List<UserTheme>? _userThemes;
  List<UserTheme>? get userThemes {
    final value = _userThemes;
    if (value == null) return null;
    if (_userThemes is EqualUnmodifiableListView) return _userThemes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final BackupSetting? backupSettings;

  /// Create a copy of DbResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserConfigResultCopyWith<UserConfigResult> get copyWith =>
      _$UserConfigResultCopyWithImpl<UserConfigResult>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserConfigResult &&
            (identical(other.data, data) || other.data == data) &&
            const DeepCollectionEquality()
                .equals(other._userThemes, _userThemes) &&
            (identical(other.backupSettings, backupSettings) ||
                other.backupSettings == backupSettings));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data,
      const DeepCollectionEquality().hash(_userThemes), backupSettings);

  @override
  String toString() {
    return 'DbResult.userConfig(data: $data, userThemes: $userThemes, backupSettings: $backupSettings)';
  }
}

/// @nodoc
abstract mixin class $UserConfigResultCopyWith<$Res>
    implements $DbResultCopyWith<$Res> {
  factory $UserConfigResultCopyWith(
          UserConfigResult value, $Res Function(UserConfigResult) _then) =
      _$UserConfigResultCopyWithImpl;
  @useResult
  $Res call(
      {UserConfig data,
      List<UserTheme>? userThemes,
      BackupSetting? backupSettings});
}

/// @nodoc
class _$UserConfigResultCopyWithImpl<$Res>
    implements $UserConfigResultCopyWith<$Res> {
  _$UserConfigResultCopyWithImpl(this._self, this._then);

  final UserConfigResult _self;
  final $Res Function(UserConfigResult) _then;

  /// Create a copy of DbResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
    Object? userThemes = freezed,
    Object? backupSettings = freezed,
  }) {
    return _then(UserConfigResult(
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as UserConfig,
      userThemes: freezed == userThemes
          ? _self._userThemes
          : userThemes // ignore: cast_nullable_to_non_nullable
              as List<UserTheme>?,
      backupSettings: freezed == backupSettings
          ? _self.backupSettings
          : backupSettings // ignore: cast_nullable_to_non_nullable
              as BackupSetting?,
    ));
  }
}

/// @nodoc

class UserThemeResult implements DbResult {
  const UserThemeResult(
      {required this.data,
      this.userConfigId,
      final List<String>? sharedUserIds})
      : _sharedUserIds = sharedUserIds;

  final UserTheme data;
//NOTE: This will most likely be remove in the future when we implement users
  final String? userConfigId;
  final List<String>? _sharedUserIds;
  List<String>? get sharedUserIds {
    final value = _sharedUserIds;
    if (value == null) return null;
    if (_sharedUserIds is EqualUnmodifiableListView) return _sharedUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of DbResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserThemeResultCopyWith<UserThemeResult> get copyWith =>
      _$UserThemeResultCopyWithImpl<UserThemeResult>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserThemeResult &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.userConfigId, userConfigId) ||
                other.userConfigId == userConfigId) &&
            const DeepCollectionEquality()
                .equals(other._sharedUserIds, _sharedUserIds));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data, userConfigId,
      const DeepCollectionEquality().hash(_sharedUserIds));

  @override
  String toString() {
    return 'DbResult.userTheme(data: $data, userConfigId: $userConfigId, sharedUserIds: $sharedUserIds)';
  }
}

/// @nodoc
abstract mixin class $UserThemeResultCopyWith<$Res>
    implements $DbResultCopyWith<$Res> {
  factory $UserThemeResultCopyWith(
          UserThemeResult value, $Res Function(UserThemeResult) _then) =
      _$UserThemeResultCopyWithImpl;
  @useResult
  $Res call(
      {UserTheme data, String? userConfigId, List<String>? sharedUserIds});
}

/// @nodoc
class _$UserThemeResultCopyWithImpl<$Res>
    implements $UserThemeResultCopyWith<$Res> {
  _$UserThemeResultCopyWithImpl(this._self, this._then);

  final UserThemeResult _self;
  final $Res Function(UserThemeResult) _then;

  /// Create a copy of DbResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
    Object? userConfigId = freezed,
    Object? sharedUserIds = freezed,
  }) {
    return _then(UserThemeResult(
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as UserTheme,
      userConfigId: freezed == userConfigId
          ? _self.userConfigId
          : userConfigId // ignore: cast_nullable_to_non_nullable
              as String?,
      sharedUserIds: freezed == sharedUserIds
          ? _self._sharedUserIds
          : sharedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

// dart format on
