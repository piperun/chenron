// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_detail_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemDetailData {
  String get itemId;
  FolderItemType get itemType;
  String get title;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  List<Tag> get tags;
  List<Folder> get parentFolders; // Link-specific
  String? get url;
  String? get domain;
  String? get archiveOrgUrl;
  String? get archiveIsUrl;
  String? get localArchivePath; // Document-specific
  DocumentFileType? get fileType;
  int? get fileSize;
  String? get filePath; // Folder-specific
  String? get description;
  int? get color;
  int get linkCount;
  int get documentCount;
  int get folderCount;

  /// Create a copy of ItemDetailData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ItemDetailDataCopyWith<ItemDetailData> get copyWith =>
      _$ItemDetailDataCopyWithImpl<ItemDetailData>(
          this as ItemDetailData, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ItemDetailData &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemType, itemType) ||
                other.itemType == itemType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality()
                .equals(other.parentFolders, parentFolders) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.domain, domain) || other.domain == domain) &&
            (identical(other.archiveOrgUrl, archiveOrgUrl) ||
                other.archiveOrgUrl == archiveOrgUrl) &&
            (identical(other.archiveIsUrl, archiveIsUrl) ||
                other.archiveIsUrl == archiveIsUrl) &&
            (identical(other.localArchivePath, localArchivePath) ||
                other.localArchivePath == localArchivePath) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.linkCount, linkCount) ||
                other.linkCount == linkCount) &&
            (identical(other.documentCount, documentCount) ||
                other.documentCount == documentCount) &&
            (identical(other.folderCount, folderCount) ||
                other.folderCount == folderCount));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        itemId,
        itemType,
        title,
        createdAt,
        updatedAt,
        const DeepCollectionEquality().hash(tags),
        const DeepCollectionEquality().hash(parentFolders),
        url,
        domain,
        archiveOrgUrl,
        archiveIsUrl,
        localArchivePath,
        fileType,
        fileSize,
        filePath,
        description,
        color,
        linkCount,
        documentCount,
        folderCount
      ]);

  @override
  String toString() {
    return 'ItemDetailData(itemId: $itemId, itemType: $itemType, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags, parentFolders: $parentFolders, url: $url, domain: $domain, archiveOrgUrl: $archiveOrgUrl, archiveIsUrl: $archiveIsUrl, localArchivePath: $localArchivePath, fileType: $fileType, fileSize: $fileSize, filePath: $filePath, description: $description, color: $color, linkCount: $linkCount, documentCount: $documentCount, folderCount: $folderCount)';
  }
}

/// @nodoc
abstract mixin class $ItemDetailDataCopyWith<$Res> {
  factory $ItemDetailDataCopyWith(
          ItemDetailData value, $Res Function(ItemDetailData) _then) =
      _$ItemDetailDataCopyWithImpl;
  @useResult
  $Res call(
      {String itemId,
      FolderItemType itemType,
      String title,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<Tag> tags,
      List<Folder> parentFolders,
      String? url,
      String? domain,
      String? archiveOrgUrl,
      String? archiveIsUrl,
      String? localArchivePath,
      DocumentFileType? fileType,
      int? fileSize,
      String? filePath,
      String? description,
      int? color,
      int linkCount,
      int documentCount,
      int folderCount});
}

/// @nodoc
class _$ItemDetailDataCopyWithImpl<$Res>
    implements $ItemDetailDataCopyWith<$Res> {
  _$ItemDetailDataCopyWithImpl(this._self, this._then);

  final ItemDetailData _self;
  final $Res Function(ItemDetailData) _then;

  /// Create a copy of ItemDetailData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? itemType = null,
    Object? title = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? tags = null,
    Object? parentFolders = null,
    Object? url = freezed,
    Object? domain = freezed,
    Object? archiveOrgUrl = freezed,
    Object? archiveIsUrl = freezed,
    Object? localArchivePath = freezed,
    Object? fileType = freezed,
    Object? fileSize = freezed,
    Object? filePath = freezed,
    Object? description = freezed,
    Object? color = freezed,
    Object? linkCount = null,
    Object? documentCount = null,
    Object? folderCount = null,
  }) {
    return _then(_self.copyWith(
      itemId: null == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      itemType: null == itemType
          ? _self.itemType
          : itemType // ignore: cast_nullable_to_non_nullable
              as FolderItemType,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>,
      parentFolders: null == parentFolders
          ? _self.parentFolders
          : parentFolders // ignore: cast_nullable_to_non_nullable
              as List<Folder>,
      url: freezed == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      domain: freezed == domain
          ? _self.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String?,
      archiveOrgUrl: freezed == archiveOrgUrl
          ? _self.archiveOrgUrl
          : archiveOrgUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      archiveIsUrl: freezed == archiveIsUrl
          ? _self.archiveIsUrl
          : archiveIsUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      localArchivePath: freezed == localArchivePath
          ? _self.localArchivePath
          : localArchivePath // ignore: cast_nullable_to_non_nullable
              as String?,
      fileType: freezed == fileType
          ? _self.fileType
          : fileType // ignore: cast_nullable_to_non_nullable
              as DocumentFileType?,
      fileSize: freezed == fileSize
          ? _self.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      filePath: freezed == filePath
          ? _self.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as int?,
      linkCount: null == linkCount
          ? _self.linkCount
          : linkCount // ignore: cast_nullable_to_non_nullable
              as int,
      documentCount: null == documentCount
          ? _self.documentCount
          : documentCount // ignore: cast_nullable_to_non_nullable
              as int,
      folderCount: null == folderCount
          ? _self.folderCount
          : folderCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [ItemDetailData].
extension ItemDetailDataPatterns on ItemDetailData {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ItemDetailData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ItemDetailData() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_ItemDetailData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ItemDetailData():
        return $default(_that);
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ItemDetailData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ItemDetailData() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String itemId,
            FolderItemType itemType,
            String title,
            DateTime? createdAt,
            DateTime? updatedAt,
            List<Tag> tags,
            List<Folder> parentFolders,
            String? url,
            String? domain,
            String? archiveOrgUrl,
            String? archiveIsUrl,
            String? localArchivePath,
            DocumentFileType? fileType,
            int? fileSize,
            String? filePath,
            String? description,
            int? color,
            int linkCount,
            int documentCount,
            int folderCount)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ItemDetailData() when $default != null:
        return $default(
            _that.itemId,
            _that.itemType,
            _that.title,
            _that.createdAt,
            _that.updatedAt,
            _that.tags,
            _that.parentFolders,
            _that.url,
            _that.domain,
            _that.archiveOrgUrl,
            _that.archiveIsUrl,
            _that.localArchivePath,
            _that.fileType,
            _that.fileSize,
            _that.filePath,
            _that.description,
            _that.color,
            _that.linkCount,
            _that.documentCount,
            _that.folderCount);
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
  TResult when<TResult extends Object?>(
    TResult Function(
            String itemId,
            FolderItemType itemType,
            String title,
            DateTime? createdAt,
            DateTime? updatedAt,
            List<Tag> tags,
            List<Folder> parentFolders,
            String? url,
            String? domain,
            String? archiveOrgUrl,
            String? archiveIsUrl,
            String? localArchivePath,
            DocumentFileType? fileType,
            int? fileSize,
            String? filePath,
            String? description,
            int? color,
            int linkCount,
            int documentCount,
            int folderCount)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ItemDetailData():
        return $default(
            _that.itemId,
            _that.itemType,
            _that.title,
            _that.createdAt,
            _that.updatedAt,
            _that.tags,
            _that.parentFolders,
            _that.url,
            _that.domain,
            _that.archiveOrgUrl,
            _that.archiveIsUrl,
            _that.localArchivePath,
            _that.fileType,
            _that.fileSize,
            _that.filePath,
            _that.description,
            _that.color,
            _that.linkCount,
            _that.documentCount,
            _that.folderCount);
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String itemId,
            FolderItemType itemType,
            String title,
            DateTime? createdAt,
            DateTime? updatedAt,
            List<Tag> tags,
            List<Folder> parentFolders,
            String? url,
            String? domain,
            String? archiveOrgUrl,
            String? archiveIsUrl,
            String? localArchivePath,
            DocumentFileType? fileType,
            int? fileSize,
            String? filePath,
            String? description,
            int? color,
            int linkCount,
            int documentCount,
            int folderCount)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ItemDetailData() when $default != null:
        return $default(
            _that.itemId,
            _that.itemType,
            _that.title,
            _that.createdAt,
            _that.updatedAt,
            _that.tags,
            _that.parentFolders,
            _that.url,
            _that.domain,
            _that.archiveOrgUrl,
            _that.archiveIsUrl,
            _that.localArchivePath,
            _that.fileType,
            _that.fileSize,
            _that.filePath,
            _that.description,
            _that.color,
            _that.linkCount,
            _that.documentCount,
            _that.folderCount);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ItemDetailData implements ItemDetailData {
  const _ItemDetailData(
      {required this.itemId,
      required this.itemType,
      required this.title,
      this.createdAt,
      this.updatedAt,
      final List<Tag> tags = const [],
      final List<Folder> parentFolders = const [],
      this.url,
      this.domain,
      this.archiveOrgUrl,
      this.archiveIsUrl,
      this.localArchivePath,
      this.fileType,
      this.fileSize,
      this.filePath,
      this.description,
      this.color,
      this.linkCount = 0,
      this.documentCount = 0,
      this.folderCount = 0})
      : _tags = tags,
        _parentFolders = parentFolders;

  @override
  final String itemId;
  @override
  final FolderItemType itemType;
  @override
  final String title;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  final List<Tag> _tags;
  @override
  @JsonKey()
  List<Tag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<Folder> _parentFolders;
  @override
  @JsonKey()
  List<Folder> get parentFolders {
    if (_parentFolders is EqualUnmodifiableListView) return _parentFolders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_parentFolders);
  }

// Link-specific
  @override
  final String? url;
  @override
  final String? domain;
  @override
  final String? archiveOrgUrl;
  @override
  final String? archiveIsUrl;
  @override
  final String? localArchivePath;
// Document-specific
  @override
  final DocumentFileType? fileType;
  @override
  final int? fileSize;
  @override
  final String? filePath;
// Folder-specific
  @override
  final String? description;
  @override
  final int? color;
  @override
  @JsonKey()
  final int linkCount;
  @override
  @JsonKey()
  final int documentCount;
  @override
  @JsonKey()
  final int folderCount;

  /// Create a copy of ItemDetailData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ItemDetailDataCopyWith<_ItemDetailData> get copyWith =>
      __$ItemDetailDataCopyWithImpl<_ItemDetailData>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ItemDetailData &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemType, itemType) ||
                other.itemType == itemType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._parentFolders, _parentFolders) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.domain, domain) || other.domain == domain) &&
            (identical(other.archiveOrgUrl, archiveOrgUrl) ||
                other.archiveOrgUrl == archiveOrgUrl) &&
            (identical(other.archiveIsUrl, archiveIsUrl) ||
                other.archiveIsUrl == archiveIsUrl) &&
            (identical(other.localArchivePath, localArchivePath) ||
                other.localArchivePath == localArchivePath) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.linkCount, linkCount) ||
                other.linkCount == linkCount) &&
            (identical(other.documentCount, documentCount) ||
                other.documentCount == documentCount) &&
            (identical(other.folderCount, folderCount) ||
                other.folderCount == folderCount));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        itemId,
        itemType,
        title,
        createdAt,
        updatedAt,
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_parentFolders),
        url,
        domain,
        archiveOrgUrl,
        archiveIsUrl,
        localArchivePath,
        fileType,
        fileSize,
        filePath,
        description,
        color,
        linkCount,
        documentCount,
        folderCount
      ]);

  @override
  String toString() {
    return 'ItemDetailData(itemId: $itemId, itemType: $itemType, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags, parentFolders: $parentFolders, url: $url, domain: $domain, archiveOrgUrl: $archiveOrgUrl, archiveIsUrl: $archiveIsUrl, localArchivePath: $localArchivePath, fileType: $fileType, fileSize: $fileSize, filePath: $filePath, description: $description, color: $color, linkCount: $linkCount, documentCount: $documentCount, folderCount: $folderCount)';
  }
}

/// @nodoc
abstract mixin class _$ItemDetailDataCopyWith<$Res>
    implements $ItemDetailDataCopyWith<$Res> {
  factory _$ItemDetailDataCopyWith(
          _ItemDetailData value, $Res Function(_ItemDetailData) _then) =
      __$ItemDetailDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String itemId,
      FolderItemType itemType,
      String title,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<Tag> tags,
      List<Folder> parentFolders,
      String? url,
      String? domain,
      String? archiveOrgUrl,
      String? archiveIsUrl,
      String? localArchivePath,
      DocumentFileType? fileType,
      int? fileSize,
      String? filePath,
      String? description,
      int? color,
      int linkCount,
      int documentCount,
      int folderCount});
}

/// @nodoc
class __$ItemDetailDataCopyWithImpl<$Res>
    implements _$ItemDetailDataCopyWith<$Res> {
  __$ItemDetailDataCopyWithImpl(this._self, this._then);

  final _ItemDetailData _self;
  final $Res Function(_ItemDetailData) _then;

  /// Create a copy of ItemDetailData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? itemId = null,
    Object? itemType = null,
    Object? title = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? tags = null,
    Object? parentFolders = null,
    Object? url = freezed,
    Object? domain = freezed,
    Object? archiveOrgUrl = freezed,
    Object? archiveIsUrl = freezed,
    Object? localArchivePath = freezed,
    Object? fileType = freezed,
    Object? fileSize = freezed,
    Object? filePath = freezed,
    Object? description = freezed,
    Object? color = freezed,
    Object? linkCount = null,
    Object? documentCount = null,
    Object? folderCount = null,
  }) {
    return _then(_ItemDetailData(
      itemId: null == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      itemType: null == itemType
          ? _self.itemType
          : itemType // ignore: cast_nullable_to_non_nullable
              as FolderItemType,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>,
      parentFolders: null == parentFolders
          ? _self._parentFolders
          : parentFolders // ignore: cast_nullable_to_non_nullable
              as List<Folder>,
      url: freezed == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      domain: freezed == domain
          ? _self.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String?,
      archiveOrgUrl: freezed == archiveOrgUrl
          ? _self.archiveOrgUrl
          : archiveOrgUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      archiveIsUrl: freezed == archiveIsUrl
          ? _self.archiveIsUrl
          : archiveIsUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      localArchivePath: freezed == localArchivePath
          ? _self.localArchivePath
          : localArchivePath // ignore: cast_nullable_to_non_nullable
              as String?,
      fileType: freezed == fileType
          ? _self.fileType
          : fileType // ignore: cast_nullable_to_non_nullable
              as DocumentFileType?,
      fileSize: freezed == fileSize
          ? _self.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      filePath: freezed == filePath
          ? _self.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as int?,
      linkCount: null == linkCount
          ? _self.linkCount
          : linkCount // ignore: cast_nullable_to_non_nullable
              as int,
      documentCount: null == documentCount
          ? _self.documentCount
          : documentCount // ignore: cast_nullable_to_non_nullable
              as int,
      folderCount: null == folderCount
          ? _self.folderCount
          : folderCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
