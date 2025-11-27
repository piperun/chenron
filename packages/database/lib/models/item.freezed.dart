// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FolderItem {
  String? get id;
  String? get itemId;
  DateTime? get createdAt;
  List<Tag> get tags;

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FolderItemCopyWith<FolderItem> get copyWith =>
      _$FolderItemCopyWithImpl<FolderItem>(this as FolderItem, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FolderItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other.tags, tags));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, itemId, createdAt,
      const DeepCollectionEquality().hash(tags));

  @override
  String toString() {
    return 'FolderItem(id: $id, itemId: $itemId, createdAt: $createdAt, tags: $tags)';
  }
}

/// @nodoc
abstract mixin class $FolderItemCopyWith<$Res> {
  factory $FolderItemCopyWith(
          FolderItem value, $Res Function(FolderItem) _then) =
      _$FolderItemCopyWithImpl;
  @useResult
  $Res call({String? id, String? itemId, DateTime? createdAt, List<Tag> tags});
}

/// @nodoc
class _$FolderItemCopyWithImpl<$Res> implements $FolderItemCopyWith<$Res> {
  _$FolderItemCopyWithImpl(this._self, this._then);

  final FolderItem _self;
  final $Res Function(FolderItem) _then;

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? itemId = freezed,
    Object? createdAt = freezed,
    Object? tags = null,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      itemId: freezed == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>,
    ));
  }
}

/// Adds pattern-matching-related methods to [FolderItem].
extension FolderItemPatterns on FolderItem {
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
    TResult Function(LinkItem value)? link,
    TResult Function(DocumentItem value)? document,
    TResult Function(FolderItemNested value)? folder,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case LinkItem() when link != null:
        return link(_that);
      case DocumentItem() when document != null:
        return document(_that);
      case FolderItemNested() when folder != null:
        return folder(_that);
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
    required TResult Function(LinkItem value) link,
    required TResult Function(DocumentItem value) document,
    required TResult Function(FolderItemNested value) folder,
  }) {
    final _that = this;
    switch (_that) {
      case LinkItem():
        return link(_that);
      case DocumentItem():
        return document(_that);
      case FolderItemNested():
        return folder(_that);
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
    TResult? Function(LinkItem value)? link,
    TResult? Function(DocumentItem value)? document,
    TResult? Function(FolderItemNested value)? folder,
  }) {
    final _that = this;
    switch (_that) {
      case LinkItem() when link != null:
        return link(_that);
      case DocumentItem() when document != null:
        return document(_that);
      case FolderItemNested() when folder != null:
        return folder(_that);
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
    TResult Function(String? id, String? itemId, String url, String? archiveOrg,
            String? archiveIs, DateTime? createdAt, List<Tag> tags)?
        link,
    TResult Function(
            String? id,
            String? itemId,
            String title,
            String filePath,
            String mimeType,
            int? fileSize,
            String? checksum,
            DateTime? createdAt,
            DateTime? updatedAt,
            List<Tag> tags)?
        document,
    TResult Function(
            String? id,
            String? itemId,
            String folderId,
            String title,
            String? description,
            DateTime? createdAt,
            DateTime? updatedAt,
            List<Tag> tags)?
        folder,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case LinkItem() when link != null:
        return link(_that.id, _that.itemId, _that.url, _that.archiveOrg,
            _that.archiveIs, _that.createdAt, _that.tags);
      case DocumentItem() when document != null:
        return document(
            _that.id,
            _that.itemId,
            _that.title,
            _that.filePath,
            _that.mimeType,
            _that.fileSize,
            _that.checksum,
            _that.createdAt,
            _that.updatedAt,
            _that.tags);
      case FolderItemNested() when folder != null:
        return folder(_that.id, _that.itemId, _that.folderId, _that.title,
            _that.description, _that.createdAt, _that.updatedAt, _that.tags);
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
            String? id,
            String? itemId,
            String url,
            String? archiveOrg,
            String? archiveIs,
            DateTime? createdAt,
            List<Tag> tags)
        link,
    required TResult Function(
            String? id,
            String? itemId,
            String title,
            String filePath,
            String mimeType,
            int? fileSize,
            String? checksum,
            DateTime? createdAt,
            DateTime? updatedAt,
            List<Tag> tags)
        document,
    required TResult Function(
            String? id,
            String? itemId,
            String folderId,
            String title,
            String? description,
            DateTime? createdAt,
            DateTime? updatedAt,
            List<Tag> tags)
        folder,
  }) {
    final _that = this;
    switch (_that) {
      case LinkItem():
        return link(_that.id, _that.itemId, _that.url, _that.archiveOrg,
            _that.archiveIs, _that.createdAt, _that.tags);
      case DocumentItem():
        return document(
            _that.id,
            _that.itemId,
            _that.title,
            _that.filePath,
            _that.mimeType,
            _that.fileSize,
            _that.checksum,
            _that.createdAt,
            _that.updatedAt,
            _that.tags);
      case FolderItemNested():
        return folder(_that.id, _that.itemId, _that.folderId, _that.title,
            _that.description, _that.createdAt, _that.updatedAt, _that.tags);
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
    TResult? Function(
            String? id,
            String? itemId,
            String url,
            String? archiveOrg,
            String? archiveIs,
            DateTime? createdAt,
            List<Tag> tags)?
        link,
    TResult? Function(
            String? id,
            String? itemId,
            String title,
            String filePath,
            String mimeType,
            int? fileSize,
            String? checksum,
            DateTime? createdAt,
            DateTime? updatedAt,
            List<Tag> tags)?
        document,
    TResult? Function(
            String? id,
            String? itemId,
            String folderId,
            String title,
            String? description,
            DateTime? createdAt,
            DateTime? updatedAt,
            List<Tag> tags)?
        folder,
  }) {
    final _that = this;
    switch (_that) {
      case LinkItem() when link != null:
        return link(_that.id, _that.itemId, _that.url, _that.archiveOrg,
            _that.archiveIs, _that.createdAt, _that.tags);
      case DocumentItem() when document != null:
        return document(
            _that.id,
            _that.itemId,
            _that.title,
            _that.filePath,
            _that.mimeType,
            _that.fileSize,
            _that.checksum,
            _that.createdAt,
            _that.updatedAt,
            _that.tags);
      case FolderItemNested() when folder != null:
        return folder(_that.id, _that.itemId, _that.folderId, _that.title,
            _that.description, _that.createdAt, _that.updatedAt, _that.tags);
      case _:
        return null;
    }
  }
}

/// @nodoc

class LinkItem extends FolderItem {
  const LinkItem(
      {this.id,
      this.itemId,
      required this.url,
      this.archiveOrg,
      this.archiveIs,
      this.createdAt,
      final List<Tag> tags = const []})
      : _tags = tags,
        super._();

  @override
  final String? id;
  @override
  final String? itemId;
  final String url;
  final String? archiveOrg;
  final String? archiveIs;
  @override
  final DateTime? createdAt;
  final List<Tag> _tags;
  @override
  @JsonKey()
  List<Tag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LinkItemCopyWith<LinkItem> get copyWith =>
      _$LinkItemCopyWithImpl<LinkItem>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LinkItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.archiveOrg, archiveOrg) ||
                other.archiveOrg == archiveOrg) &&
            (identical(other.archiveIs, archiveIs) ||
                other.archiveIs == archiveIs) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, itemId, url, archiveOrg,
      archiveIs, createdAt, const DeepCollectionEquality().hash(_tags));

  @override
  String toString() {
    return 'FolderItem.link(id: $id, itemId: $itemId, url: $url, archiveOrg: $archiveOrg, archiveIs: $archiveIs, createdAt: $createdAt, tags: $tags)';
  }
}

/// @nodoc
abstract mixin class $LinkItemCopyWith<$Res>
    implements $FolderItemCopyWith<$Res> {
  factory $LinkItemCopyWith(LinkItem value, $Res Function(LinkItem) _then) =
      _$LinkItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      String? itemId,
      String url,
      String? archiveOrg,
      String? archiveIs,
      DateTime? createdAt,
      List<Tag> tags});
}

/// @nodoc
class _$LinkItemCopyWithImpl<$Res> implements $LinkItemCopyWith<$Res> {
  _$LinkItemCopyWithImpl(this._self, this._then);

  final LinkItem _self;
  final $Res Function(LinkItem) _then;

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? itemId = freezed,
    Object? url = null,
    Object? archiveOrg = freezed,
    Object? archiveIs = freezed,
    Object? createdAt = freezed,
    Object? tags = null,
  }) {
    return _then(LinkItem(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      itemId: freezed == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String?,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      archiveOrg: freezed == archiveOrg
          ? _self.archiveOrg
          : archiveOrg // ignore: cast_nullable_to_non_nullable
              as String?,
      archiveIs: freezed == archiveIs
          ? _self.archiveIs
          : archiveIs // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>,
    ));
  }
}

/// @nodoc

class DocumentItem extends FolderItem {
  const DocumentItem(
      {this.id,
      this.itemId,
      required this.title,
      required this.filePath,
      this.mimeType = 'text/markdown',
      this.fileSize,
      this.checksum,
      this.createdAt,
      this.updatedAt,
      final List<Tag> tags = const []})
      : _tags = tags,
        super._();

  @override
  final String? id;
  @override
  final String? itemId;
  final String title;
  final String filePath;
  @JsonKey()
  final String mimeType;
  final int? fileSize;
  final String? checksum;
  @override
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Tag> _tags;
  @override
  @JsonKey()
  List<Tag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DocumentItemCopyWith<DocumentItem> get copyWith =>
      _$DocumentItemCopyWithImpl<DocumentItem>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DocumentItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.checksum, checksum) ||
                other.checksum == checksum) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      itemId,
      title,
      filePath,
      mimeType,
      fileSize,
      checksum,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_tags));

  @override
  String toString() {
    return 'FolderItem.document(id: $id, itemId: $itemId, title: $title, filePath: $filePath, mimeType: $mimeType, fileSize: $fileSize, checksum: $checksum, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags)';
  }
}

/// @nodoc
abstract mixin class $DocumentItemCopyWith<$Res>
    implements $FolderItemCopyWith<$Res> {
  factory $DocumentItemCopyWith(
          DocumentItem value, $Res Function(DocumentItem) _then) =
      _$DocumentItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      String? itemId,
      String title,
      String filePath,
      String mimeType,
      int? fileSize,
      String? checksum,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<Tag> tags});
}

/// @nodoc
class _$DocumentItemCopyWithImpl<$Res> implements $DocumentItemCopyWith<$Res> {
  _$DocumentItemCopyWithImpl(this._self, this._then);

  final DocumentItem _self;
  final $Res Function(DocumentItem) _then;

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? itemId = freezed,
    Object? title = null,
    Object? filePath = null,
    Object? mimeType = null,
    Object? fileSize = freezed,
    Object? checksum = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? tags = null,
  }) {
    return _then(DocumentItem(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      itemId: freezed == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      filePath: null == filePath
          ? _self.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _self.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: freezed == fileSize
          ? _self.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      checksum: freezed == checksum
          ? _self.checksum
          : checksum // ignore: cast_nullable_to_non_nullable
              as String?,
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
    ));
  }
}

/// @nodoc

class FolderItemNested extends FolderItem {
  const FolderItemNested(
      {this.id,
      this.itemId,
      required this.folderId,
      required this.title,
      this.description,
      this.createdAt,
      this.updatedAt,
      final List<Tag> tags = const []})
      : _tags = tags,
        super._();

  @override
  final String? id;
  @override
  final String? itemId;
  final String folderId;
  final String title;
  final String? description;
  @override
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Tag> _tags;
  @override
  @JsonKey()
  List<Tag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FolderItemNestedCopyWith<FolderItemNested> get copyWith =>
      _$FolderItemNestedCopyWithImpl<FolderItemNested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FolderItemNested &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.folderId, folderId) ||
                other.folderId == folderId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      itemId,
      folderId,
      title,
      description,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_tags));

  @override
  String toString() {
    return 'FolderItem.folder(id: $id, itemId: $itemId, folderId: $folderId, title: $title, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags)';
  }
}

/// @nodoc
abstract mixin class $FolderItemNestedCopyWith<$Res>
    implements $FolderItemCopyWith<$Res> {
  factory $FolderItemNestedCopyWith(
          FolderItemNested value, $Res Function(FolderItemNested) _then) =
      _$FolderItemNestedCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      String? itemId,
      String folderId,
      String title,
      String? description,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<Tag> tags});
}

/// @nodoc
class _$FolderItemNestedCopyWithImpl<$Res>
    implements $FolderItemNestedCopyWith<$Res> {
  _$FolderItemNestedCopyWithImpl(this._self, this._then);

  final FolderItemNested _self;
  final $Res Function(FolderItemNested) _then;

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? itemId = freezed,
    Object? folderId = null,
    Object? title = null,
    Object? description = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? tags = null,
  }) {
    return _then(FolderItemNested(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      itemId: freezed == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String?,
      folderId: null == folderId
          ? _self.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
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
    ));
  }
}

// dart format on
