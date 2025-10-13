// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'created_ids.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreatedIds {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CreatedIds);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CreatedIds()';
  }
}

/// @nodoc
class $CreatedIdsCopyWith<$Res> {
  $CreatedIdsCopyWith(CreatedIds _, $Res Function(CreatedIds) __);
}

/// Adds pattern-matching-related methods to [CreatedIds].
extension CreatedIdsPatterns on CreatedIds {
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
    TResult Function(FolderResultIds value)? folder,
    TResult Function(LinkResultIds value)? link,
    TResult Function(DocumentResultIds value)? document,
    TResult Function(TagResultIds value)? tag,
    TResult Function(ItemResultIds value)? item,
    TResult Function(MetadataResultIds value)? metadata,
    TResult Function(UserConfigResultIds value)? userConfig,
    TResult Function(UserThemeResultIds value)? userTheme,
    TResult Function(BackupSettingsResultIds value)? backupSettings,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case FolderResultIds() when folder != null:
        return folder(_that);
      case LinkResultIds() when link != null:
        return link(_that);
      case DocumentResultIds() when document != null:
        return document(_that);
      case TagResultIds() when tag != null:
        return tag(_that);
      case ItemResultIds() when item != null:
        return item(_that);
      case MetadataResultIds() when metadata != null:
        return metadata(_that);
      case UserConfigResultIds() when userConfig != null:
        return userConfig(_that);
      case UserThemeResultIds() when userTheme != null:
        return userTheme(_that);
      case BackupSettingsResultIds() when backupSettings != null:
        return backupSettings(_that);
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
    required TResult Function(FolderResultIds value) folder,
    required TResult Function(LinkResultIds value) link,
    required TResult Function(DocumentResultIds value) document,
    required TResult Function(TagResultIds value) tag,
    required TResult Function(ItemResultIds value) item,
    required TResult Function(MetadataResultIds value) metadata,
    required TResult Function(UserConfigResultIds value) userConfig,
    required TResult Function(UserThemeResultIds value) userTheme,
    required TResult Function(BackupSettingsResultIds value) backupSettings,
  }) {
    final _that = this;
    switch (_that) {
      case FolderResultIds():
        return folder(_that);
      case LinkResultIds():
        return link(_that);
      case DocumentResultIds():
        return document(_that);
      case TagResultIds():
        return tag(_that);
      case ItemResultIds():
        return item(_that);
      case MetadataResultIds():
        return metadata(_that);
      case UserConfigResultIds():
        return userConfig(_that);
      case UserThemeResultIds():
        return userTheme(_that);
      case BackupSettingsResultIds():
        return backupSettings(_that);
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
    TResult? Function(FolderResultIds value)? folder,
    TResult? Function(LinkResultIds value)? link,
    TResult? Function(DocumentResultIds value)? document,
    TResult? Function(TagResultIds value)? tag,
    TResult? Function(ItemResultIds value)? item,
    TResult? Function(MetadataResultIds value)? metadata,
    TResult? Function(UserConfigResultIds value)? userConfig,
    TResult? Function(UserThemeResultIds value)? userTheme,
    TResult? Function(BackupSettingsResultIds value)? backupSettings,
  }) {
    final _that = this;
    switch (_that) {
      case FolderResultIds() when folder != null:
        return folder(_that);
      case LinkResultIds() when link != null:
        return link(_that);
      case DocumentResultIds() when document != null:
        return document(_that);
      case TagResultIds() when tag != null:
        return tag(_that);
      case ItemResultIds() when item != null:
        return item(_that);
      case MetadataResultIds() when metadata != null:
        return metadata(_that);
      case UserConfigResultIds() when userConfig != null:
        return userConfig(_that);
      case UserThemeResultIds() when userTheme != null:
        return userTheme(_that);
      case BackupSettingsResultIds() when backupSettings != null:
        return backupSettings(_that);
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
    TResult Function(String folderId, List<ItemResultIds>? itemIds,
            List<TagResultIds>? tagIds)?
        folder,
    TResult Function(String linkId, List<TagResultIds>? tagIds)? link,
    TResult Function(String documentId, List<String>? tagIds)? document,
    TResult Function(String tagId, List<String>? itemIds, bool wasCreated)? tag,
    TResult Function(
            String itemId, String folderId, String? linkId, String? documentId)?
        item,
    TResult Function(String metadataId, String itemId)? metadata,
    TResult Function(
            String userConfigId, List<UserThemeResultIds>? userThemesIds)?
        userConfig,
    TResult Function(String userThemeId, String userConfigId)? userTheme,
    TResult Function(String backupSettingsId, String userConfigId)?
        backupSettings,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case FolderResultIds() when folder != null:
        return folder(_that.folderId, _that.itemIds, _that.tagIds);
      case LinkResultIds() when link != null:
        return link(_that.linkId, _that.tagIds);
      case DocumentResultIds() when document != null:
        return document(_that.documentId, _that.tagIds);
      case TagResultIds() when tag != null:
        return tag(_that.tagId, _that.itemIds, _that.wasCreated);
      case ItemResultIds() when item != null:
        return item(
            _that.itemId, _that.folderId, _that.linkId, _that.documentId);
      case MetadataResultIds() when metadata != null:
        return metadata(_that.metadataId, _that.itemId);
      case UserConfigResultIds() when userConfig != null:
        return userConfig(_that.userConfigId, _that.userThemesIds);
      case UserThemeResultIds() when userTheme != null:
        return userTheme(_that.userThemeId, _that.userConfigId);
      case BackupSettingsResultIds() when backupSettings != null:
        return backupSettings(_that.backupSettingsId, _that.userConfigId);
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
    required TResult Function(String folderId, List<ItemResultIds>? itemIds,
            List<TagResultIds>? tagIds)
        folder,
    required TResult Function(String linkId, List<TagResultIds>? tagIds) link,
    required TResult Function(String documentId, List<String>? tagIds) document,
    required TResult Function(
            String tagId, List<String>? itemIds, bool wasCreated)
        tag,
    required TResult Function(
            String itemId, String folderId, String? linkId, String? documentId)
        item,
    required TResult Function(String metadataId, String itemId) metadata,
    required TResult Function(
            String userConfigId, List<UserThemeResultIds>? userThemesIds)
        userConfig,
    required TResult Function(String userThemeId, String userConfigId)
        userTheme,
    required TResult Function(String backupSettingsId, String userConfigId)
        backupSettings,
  }) {
    final _that = this;
    switch (_that) {
      case FolderResultIds():
        return folder(_that.folderId, _that.itemIds, _that.tagIds);
      case LinkResultIds():
        return link(_that.linkId, _that.tagIds);
      case DocumentResultIds():
        return document(_that.documentId, _that.tagIds);
      case TagResultIds():
        return tag(_that.tagId, _that.itemIds, _that.wasCreated);
      case ItemResultIds():
        return item(
            _that.itemId, _that.folderId, _that.linkId, _that.documentId);
      case MetadataResultIds():
        return metadata(_that.metadataId, _that.itemId);
      case UserConfigResultIds():
        return userConfig(_that.userConfigId, _that.userThemesIds);
      case UserThemeResultIds():
        return userTheme(_that.userThemeId, _that.userConfigId);
      case BackupSettingsResultIds():
        return backupSettings(_that.backupSettingsId, _that.userConfigId);
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
    TResult? Function(String folderId, List<ItemResultIds>? itemIds,
            List<TagResultIds>? tagIds)?
        folder,
    TResult? Function(String linkId, List<TagResultIds>? tagIds)? link,
    TResult? Function(String documentId, List<String>? tagIds)? document,
    TResult? Function(String tagId, List<String>? itemIds, bool wasCreated)?
        tag,
    TResult? Function(
            String itemId, String folderId, String? linkId, String? documentId)?
        item,
    TResult? Function(String metadataId, String itemId)? metadata,
    TResult? Function(
            String userConfigId, List<UserThemeResultIds>? userThemesIds)?
        userConfig,
    TResult? Function(String userThemeId, String userConfigId)? userTheme,
    TResult? Function(String backupSettingsId, String userConfigId)?
        backupSettings,
  }) {
    final _that = this;
    switch (_that) {
      case FolderResultIds() when folder != null:
        return folder(_that.folderId, _that.itemIds, _that.tagIds);
      case LinkResultIds() when link != null:
        return link(_that.linkId, _that.tagIds);
      case DocumentResultIds() when document != null:
        return document(_that.documentId, _that.tagIds);
      case TagResultIds() when tag != null:
        return tag(_that.tagId, _that.itemIds, _that.wasCreated);
      case ItemResultIds() when item != null:
        return item(
            _that.itemId, _that.folderId, _that.linkId, _that.documentId);
      case MetadataResultIds() when metadata != null:
        return metadata(_that.metadataId, _that.itemId);
      case UserConfigResultIds() when userConfig != null:
        return userConfig(_that.userConfigId, _that.userThemesIds);
      case UserThemeResultIds() when userTheme != null:
        return userTheme(_that.userThemeId, _that.userConfigId);
      case BackupSettingsResultIds() when backupSettings != null:
        return backupSettings(_that.backupSettingsId, _that.userConfigId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class FolderResultIds implements CreatedIds {
  const FolderResultIds(
      {required this.folderId,
      final List<ItemResultIds>? itemIds,
      final List<TagResultIds>? tagIds})
      : _itemIds = itemIds,
        _tagIds = tagIds;

  final String folderId;
  final List<ItemResultIds>? _itemIds;
  List<ItemResultIds>? get itemIds {
    final value = _itemIds;
    if (value == null) return null;
    if (_itemIds is EqualUnmodifiableListView) return _itemIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<TagResultIds>? _tagIds;
  List<TagResultIds>? get tagIds {
    final value = _tagIds;
    if (value == null) return null;
    if (_tagIds is EqualUnmodifiableListView) return _tagIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FolderResultIdsCopyWith<FolderResultIds> get copyWith =>
      _$FolderResultIdsCopyWithImpl<FolderResultIds>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FolderResultIds &&
            (identical(other.folderId, folderId) ||
                other.folderId == folderId) &&
            const DeepCollectionEquality().equals(other._itemIds, _itemIds) &&
            const DeepCollectionEquality().equals(other._tagIds, _tagIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      folderId,
      const DeepCollectionEquality().hash(_itemIds),
      const DeepCollectionEquality().hash(_tagIds));

  @override
  String toString() {
    return 'CreatedIds.folder(folderId: $folderId, itemIds: $itemIds, tagIds: $tagIds)';
  }
}

/// @nodoc
abstract mixin class $FolderResultIdsCopyWith<$Res>
    implements $CreatedIdsCopyWith<$Res> {
  factory $FolderResultIdsCopyWith(
          FolderResultIds value, $Res Function(FolderResultIds) _then) =
      _$FolderResultIdsCopyWithImpl;
  @useResult
  $Res call(
      {String folderId,
      List<ItemResultIds>? itemIds,
      List<TagResultIds>? tagIds});
}

/// @nodoc
class _$FolderResultIdsCopyWithImpl<$Res>
    implements $FolderResultIdsCopyWith<$Res> {
  _$FolderResultIdsCopyWithImpl(this._self, this._then);

  final FolderResultIds _self;
  final $Res Function(FolderResultIds) _then;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? folderId = null,
    Object? itemIds = freezed,
    Object? tagIds = freezed,
  }) {
    return _then(FolderResultIds(
      folderId: null == folderId
          ? _self.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
      itemIds: freezed == itemIds
          ? _self._itemIds
          : itemIds // ignore: cast_nullable_to_non_nullable
              as List<ItemResultIds>?,
      tagIds: freezed == tagIds
          ? _self._tagIds
          : tagIds // ignore: cast_nullable_to_non_nullable
              as List<TagResultIds>?,
    ));
  }
}

/// @nodoc

class LinkResultIds implements CreatedIds {
  const LinkResultIds({required this.linkId, final List<TagResultIds>? tagIds})
      : _tagIds = tagIds;

  final String linkId;
  final List<TagResultIds>? _tagIds;
  List<TagResultIds>? get tagIds {
    final value = _tagIds;
    if (value == null) return null;
    if (_tagIds is EqualUnmodifiableListView) return _tagIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LinkResultIdsCopyWith<LinkResultIds> get copyWith =>
      _$LinkResultIdsCopyWithImpl<LinkResultIds>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LinkResultIds &&
            (identical(other.linkId, linkId) || other.linkId == linkId) &&
            const DeepCollectionEquality().equals(other._tagIds, _tagIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, linkId, const DeepCollectionEquality().hash(_tagIds));

  @override
  String toString() {
    return 'CreatedIds.link(linkId: $linkId, tagIds: $tagIds)';
  }
}

/// @nodoc
abstract mixin class $LinkResultIdsCopyWith<$Res>
    implements $CreatedIdsCopyWith<$Res> {
  factory $LinkResultIdsCopyWith(
          LinkResultIds value, $Res Function(LinkResultIds) _then) =
      _$LinkResultIdsCopyWithImpl;
  @useResult
  $Res call({String linkId, List<TagResultIds>? tagIds});
}

/// @nodoc
class _$LinkResultIdsCopyWithImpl<$Res>
    implements $LinkResultIdsCopyWith<$Res> {
  _$LinkResultIdsCopyWithImpl(this._self, this._then);

  final LinkResultIds _self;
  final $Res Function(LinkResultIds) _then;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? linkId = null,
    Object? tagIds = freezed,
  }) {
    return _then(LinkResultIds(
      linkId: null == linkId
          ? _self.linkId
          : linkId // ignore: cast_nullable_to_non_nullable
              as String,
      tagIds: freezed == tagIds
          ? _self._tagIds
          : tagIds // ignore: cast_nullable_to_non_nullable
              as List<TagResultIds>?,
    ));
  }
}

/// @nodoc

class DocumentResultIds implements CreatedIds {
  const DocumentResultIds(
      {required this.documentId, final List<String>? tagIds})
      : _tagIds = tagIds;

  final String documentId;
  final List<String>? _tagIds;
  List<String>? get tagIds {
    final value = _tagIds;
    if (value == null) return null;
    if (_tagIds is EqualUnmodifiableListView) return _tagIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DocumentResultIdsCopyWith<DocumentResultIds> get copyWith =>
      _$DocumentResultIdsCopyWithImpl<DocumentResultIds>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DocumentResultIds &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId) &&
            const DeepCollectionEquality().equals(other._tagIds, _tagIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, documentId, const DeepCollectionEquality().hash(_tagIds));

  @override
  String toString() {
    return 'CreatedIds.document(documentId: $documentId, tagIds: $tagIds)';
  }
}

/// @nodoc
abstract mixin class $DocumentResultIdsCopyWith<$Res>
    implements $CreatedIdsCopyWith<$Res> {
  factory $DocumentResultIdsCopyWith(
          DocumentResultIds value, $Res Function(DocumentResultIds) _then) =
      _$DocumentResultIdsCopyWithImpl;
  @useResult
  $Res call({String documentId, List<String>? tagIds});
}

/// @nodoc
class _$DocumentResultIdsCopyWithImpl<$Res>
    implements $DocumentResultIdsCopyWith<$Res> {
  _$DocumentResultIdsCopyWithImpl(this._self, this._then);

  final DocumentResultIds _self;
  final $Res Function(DocumentResultIds) _then;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? documentId = null,
    Object? tagIds = freezed,
  }) {
    return _then(DocumentResultIds(
      documentId: null == documentId
          ? _self.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as String,
      tagIds: freezed == tagIds
          ? _self._tagIds
          : tagIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc

class TagResultIds implements CreatedIds {
  const TagResultIds(
      {required this.tagId,
      final List<String>? itemIds,
      this.wasCreated = false})
      : _itemIds = itemIds;

  final String tagId;
  final List<String>? _itemIds;
  List<String>? get itemIds {
    final value = _itemIds;
    if (value == null) return null;
    if (_itemIds is EqualUnmodifiableListView) return _itemIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @JsonKey()
  final bool wasCreated;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TagResultIdsCopyWith<TagResultIds> get copyWith =>
      _$TagResultIdsCopyWithImpl<TagResultIds>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TagResultIds &&
            (identical(other.tagId, tagId) || other.tagId == tagId) &&
            const DeepCollectionEquality().equals(other._itemIds, _itemIds) &&
            (identical(other.wasCreated, wasCreated) ||
                other.wasCreated == wasCreated));
  }

  @override
  int get hashCode => Object.hash(runtimeType, tagId,
      const DeepCollectionEquality().hash(_itemIds), wasCreated);

  @override
  String toString() {
    return 'CreatedIds.tag(tagId: $tagId, itemIds: $itemIds, wasCreated: $wasCreated)';
  }
}

/// @nodoc
abstract mixin class $TagResultIdsCopyWith<$Res>
    implements $CreatedIdsCopyWith<$Res> {
  factory $TagResultIdsCopyWith(
          TagResultIds value, $Res Function(TagResultIds) _then) =
      _$TagResultIdsCopyWithImpl;
  @useResult
  $Res call({String tagId, List<String>? itemIds, bool wasCreated});
}

/// @nodoc
class _$TagResultIdsCopyWithImpl<$Res> implements $TagResultIdsCopyWith<$Res> {
  _$TagResultIdsCopyWithImpl(this._self, this._then);

  final TagResultIds _self;
  final $Res Function(TagResultIds) _then;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? tagId = null,
    Object? itemIds = freezed,
    Object? wasCreated = null,
  }) {
    return _then(TagResultIds(
      tagId: null == tagId
          ? _self.tagId
          : tagId // ignore: cast_nullable_to_non_nullable
              as String,
      itemIds: freezed == itemIds
          ? _self._itemIds
          : itemIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      wasCreated: null == wasCreated
          ? _self.wasCreated
          : wasCreated // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class ItemResultIds implements CreatedIds {
  const ItemResultIds(
      {required this.itemId,
      required this.folderId,
      this.linkId,
      this.documentId});

  final String itemId;
  final String folderId;
  final String? linkId;
  final String? documentId;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ItemResultIdsCopyWith<ItemResultIds> get copyWith =>
      _$ItemResultIdsCopyWithImpl<ItemResultIds>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ItemResultIds &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.folderId, folderId) ||
                other.folderId == folderId) &&
            (identical(other.linkId, linkId) || other.linkId == linkId) &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, itemId, folderId, linkId, documentId);

  @override
  String toString() {
    return 'CreatedIds.item(itemId: $itemId, folderId: $folderId, linkId: $linkId, documentId: $documentId)';
  }
}

/// @nodoc
abstract mixin class $ItemResultIdsCopyWith<$Res>
    implements $CreatedIdsCopyWith<$Res> {
  factory $ItemResultIdsCopyWith(
          ItemResultIds value, $Res Function(ItemResultIds) _then) =
      _$ItemResultIdsCopyWithImpl;
  @useResult
  $Res call(
      {String itemId, String folderId, String? linkId, String? documentId});
}

/// @nodoc
class _$ItemResultIdsCopyWithImpl<$Res>
    implements $ItemResultIdsCopyWith<$Res> {
  _$ItemResultIdsCopyWithImpl(this._self, this._then);

  final ItemResultIds _self;
  final $Res Function(ItemResultIds) _then;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? itemId = null,
    Object? folderId = null,
    Object? linkId = freezed,
    Object? documentId = freezed,
  }) {
    return _then(ItemResultIds(
      itemId: null == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      folderId: null == folderId
          ? _self.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
      linkId: freezed == linkId
          ? _self.linkId
          : linkId // ignore: cast_nullable_to_non_nullable
              as String?,
      documentId: freezed == documentId
          ? _self.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class MetadataResultIds implements CreatedIds {
  const MetadataResultIds({required this.metadataId, required this.itemId});

  final String metadataId;
  final String itemId;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MetadataResultIdsCopyWith<MetadataResultIds> get copyWith =>
      _$MetadataResultIdsCopyWithImpl<MetadataResultIds>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MetadataResultIds &&
            (identical(other.metadataId, metadataId) ||
                other.metadataId == metadataId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, metadataId, itemId);

  @override
  String toString() {
    return 'CreatedIds.metadata(metadataId: $metadataId, itemId: $itemId)';
  }
}

/// @nodoc
abstract mixin class $MetadataResultIdsCopyWith<$Res>
    implements $CreatedIdsCopyWith<$Res> {
  factory $MetadataResultIdsCopyWith(
          MetadataResultIds value, $Res Function(MetadataResultIds) _then) =
      _$MetadataResultIdsCopyWithImpl;
  @useResult
  $Res call({String metadataId, String itemId});
}

/// @nodoc
class _$MetadataResultIdsCopyWithImpl<$Res>
    implements $MetadataResultIdsCopyWith<$Res> {
  _$MetadataResultIdsCopyWithImpl(this._self, this._then);

  final MetadataResultIds _self;
  final $Res Function(MetadataResultIds) _then;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? metadataId = null,
    Object? itemId = null,
  }) {
    return _then(MetadataResultIds(
      metadataId: null == metadataId
          ? _self.metadataId
          : metadataId // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class UserConfigResultIds implements CreatedIds {
  const UserConfigResultIds(
      {required this.userConfigId,
      final List<UserThemeResultIds>? userThemesIds})
      : _userThemesIds = userThemesIds;

  final String userConfigId;
  final List<UserThemeResultIds>? _userThemesIds;
  List<UserThemeResultIds>? get userThemesIds {
    final value = _userThemesIds;
    if (value == null) return null;
    if (_userThemesIds is EqualUnmodifiableListView) return _userThemesIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserConfigResultIdsCopyWith<UserConfigResultIds> get copyWith =>
      _$UserConfigResultIdsCopyWithImpl<UserConfigResultIds>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserConfigResultIds &&
            (identical(other.userConfigId, userConfigId) ||
                other.userConfigId == userConfigId) &&
            const DeepCollectionEquality()
                .equals(other._userThemesIds, _userThemesIds));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userConfigId,
      const DeepCollectionEquality().hash(_userThemesIds));

  @override
  String toString() {
    return 'CreatedIds.userConfig(userConfigId: $userConfigId, userThemesIds: $userThemesIds)';
  }
}

/// @nodoc
abstract mixin class $UserConfigResultIdsCopyWith<$Res>
    implements $CreatedIdsCopyWith<$Res> {
  factory $UserConfigResultIdsCopyWith(
          UserConfigResultIds value, $Res Function(UserConfigResultIds) _then) =
      _$UserConfigResultIdsCopyWithImpl;
  @useResult
  $Res call({String userConfigId, List<UserThemeResultIds>? userThemesIds});
}

/// @nodoc
class _$UserConfigResultIdsCopyWithImpl<$Res>
    implements $UserConfigResultIdsCopyWith<$Res> {
  _$UserConfigResultIdsCopyWithImpl(this._self, this._then);

  final UserConfigResultIds _self;
  final $Res Function(UserConfigResultIds) _then;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? userConfigId = null,
    Object? userThemesIds = freezed,
  }) {
    return _then(UserConfigResultIds(
      userConfigId: null == userConfigId
          ? _self.userConfigId
          : userConfigId // ignore: cast_nullable_to_non_nullable
              as String,
      userThemesIds: freezed == userThemesIds
          ? _self._userThemesIds
          : userThemesIds // ignore: cast_nullable_to_non_nullable
              as List<UserThemeResultIds>?,
    ));
  }
}

/// @nodoc

class UserThemeResultIds implements CreatedIds {
  const UserThemeResultIds(
      {required this.userThemeId, required this.userConfigId});

  final String userThemeId;
  final String userConfigId;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserThemeResultIdsCopyWith<UserThemeResultIds> get copyWith =>
      _$UserThemeResultIdsCopyWithImpl<UserThemeResultIds>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserThemeResultIds &&
            (identical(other.userThemeId, userThemeId) ||
                other.userThemeId == userThemeId) &&
            (identical(other.userConfigId, userConfigId) ||
                other.userConfigId == userConfigId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userThemeId, userConfigId);

  @override
  String toString() {
    return 'CreatedIds.userTheme(userThemeId: $userThemeId, userConfigId: $userConfigId)';
  }
}

/// @nodoc
abstract mixin class $UserThemeResultIdsCopyWith<$Res>
    implements $CreatedIdsCopyWith<$Res> {
  factory $UserThemeResultIdsCopyWith(
          UserThemeResultIds value, $Res Function(UserThemeResultIds) _then) =
      _$UserThemeResultIdsCopyWithImpl;
  @useResult
  $Res call({String userThemeId, String userConfigId});
}

/// @nodoc
class _$UserThemeResultIdsCopyWithImpl<$Res>
    implements $UserThemeResultIdsCopyWith<$Res> {
  _$UserThemeResultIdsCopyWithImpl(this._self, this._then);

  final UserThemeResultIds _self;
  final $Res Function(UserThemeResultIds) _then;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? userThemeId = null,
    Object? userConfigId = null,
  }) {
    return _then(UserThemeResultIds(
      userThemeId: null == userThemeId
          ? _self.userThemeId
          : userThemeId // ignore: cast_nullable_to_non_nullable
              as String,
      userConfigId: null == userConfigId
          ? _self.userConfigId
          : userConfigId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class BackupSettingsResultIds implements CreatedIds {
  const BackupSettingsResultIds(
      {required this.backupSettingsId, required this.userConfigId});

  final String backupSettingsId;
  final String userConfigId;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BackupSettingsResultIdsCopyWith<BackupSettingsResultIds> get copyWith =>
      _$BackupSettingsResultIdsCopyWithImpl<BackupSettingsResultIds>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BackupSettingsResultIds &&
            (identical(other.backupSettingsId, backupSettingsId) ||
                other.backupSettingsId == backupSettingsId) &&
            (identical(other.userConfigId, userConfigId) ||
                other.userConfigId == userConfigId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, backupSettingsId, userConfigId);

  @override
  String toString() {
    return 'CreatedIds.backupSettings(backupSettingsId: $backupSettingsId, userConfigId: $userConfigId)';
  }
}

/// @nodoc
abstract mixin class $BackupSettingsResultIdsCopyWith<$Res>
    implements $CreatedIdsCopyWith<$Res> {
  factory $BackupSettingsResultIdsCopyWith(BackupSettingsResultIds value,
          $Res Function(BackupSettingsResultIds) _then) =
      _$BackupSettingsResultIdsCopyWithImpl;
  @useResult
  $Res call({String backupSettingsId, String userConfigId});
}

/// @nodoc
class _$BackupSettingsResultIdsCopyWithImpl<$Res>
    implements $BackupSettingsResultIdsCopyWith<$Res> {
  _$BackupSettingsResultIdsCopyWithImpl(this._self, this._then);

  final BackupSettingsResultIds _self;
  final $Res Function(BackupSettingsResultIds) _then;

  /// Create a copy of CreatedIds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? backupSettingsId = null,
    Object? userConfigId = null,
  }) {
    return _then(BackupSettingsResultIds(
      backupSettingsId: null == backupSettingsId
          ? _self.backupSettingsId
          : backupSettingsId // ignore: cast_nullable_to_non_nullable
              as String,
      userConfigId: null == userConfigId
          ? _self.userConfigId
          : userConfigId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
