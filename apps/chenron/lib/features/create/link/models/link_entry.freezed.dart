// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LinkEntry implements DiagnosticableTreeMixin {
  Key get key;
  String get url;
  List<String> get tags;
  List<String> get folderIds;
  bool get isArchived;
  String? get comment;
  LinkValidationStatus get validationStatus;
  String? get validationMessage;
  int? get validationStatusCode;

  /// Create a copy of LinkEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LinkEntryCopyWith<LinkEntry> get copyWith =>
      _$LinkEntryCopyWithImpl<LinkEntry>(this as LinkEntry, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'LinkEntry'))
      ..add(DiagnosticsProperty('key', key))
      ..add(DiagnosticsProperty('url', url))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('folderIds', folderIds))
      ..add(DiagnosticsProperty('isArchived', isArchived))
      ..add(DiagnosticsProperty('comment', comment))
      ..add(DiagnosticsProperty('validationStatus', validationStatus))
      ..add(DiagnosticsProperty('validationMessage', validationMessage))
      ..add(DiagnosticsProperty('validationStatusCode', validationStatusCode));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LinkEntry &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality().equals(other.folderIds, folderIds) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.validationStatus, validationStatus) ||
                other.validationStatus == validationStatus) &&
            (identical(other.validationMessage, validationMessage) ||
                other.validationMessage == validationMessage) &&
            (identical(other.validationStatusCode, validationStatusCode) ||
                other.validationStatusCode == validationStatusCode));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      key,
      url,
      const DeepCollectionEquality().hash(tags),
      const DeepCollectionEquality().hash(folderIds),
      isArchived,
      comment,
      validationStatus,
      validationMessage,
      validationStatusCode);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LinkEntry(key: $key, url: $url, tags: $tags, folderIds: $folderIds, isArchived: $isArchived, comment: $comment, validationStatus: $validationStatus, validationMessage: $validationMessage, validationStatusCode: $validationStatusCode)';
  }
}

/// @nodoc
abstract mixin class $LinkEntryCopyWith<$Res> {
  factory $LinkEntryCopyWith(LinkEntry value, $Res Function(LinkEntry) _then) =
      _$LinkEntryCopyWithImpl;
  @useResult
  $Res call(
      {Key key,
      String url,
      List<String> tags,
      List<String> folderIds,
      bool isArchived,
      String? comment,
      LinkValidationStatus validationStatus,
      String? validationMessage,
      int? validationStatusCode});
}

/// @nodoc
class _$LinkEntryCopyWithImpl<$Res> implements $LinkEntryCopyWith<$Res> {
  _$LinkEntryCopyWithImpl(this._self, this._then);

  final LinkEntry _self;
  final $Res Function(LinkEntry) _then;

  /// Create a copy of LinkEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? url = null,
    Object? tags = null,
    Object? folderIds = null,
    Object? isArchived = null,
    Object? comment = freezed,
    Object? validationStatus = null,
    Object? validationMessage = freezed,
    Object? validationStatusCode = freezed,
  }) {
    return _then(_self.copyWith(
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as Key,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      folderIds: null == folderIds
          ? _self.folderIds
          : folderIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      comment: freezed == comment
          ? _self.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      validationStatus: null == validationStatus
          ? _self.validationStatus
          : validationStatus // ignore: cast_nullable_to_non_nullable
              as LinkValidationStatus,
      validationMessage: freezed == validationMessage
          ? _self.validationMessage
          : validationMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      validationStatusCode: freezed == validationStatusCode
          ? _self.validationStatusCode
          : validationStatusCode // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [LinkEntry].
extension LinkEntryPatterns on LinkEntry {
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
    TResult Function(_LinkEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LinkEntry() when $default != null:
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
    TResult Function(_LinkEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LinkEntry():
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
    TResult? Function(_LinkEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LinkEntry() when $default != null:
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
            Key key,
            String url,
            List<String> tags,
            List<String> folderIds,
            bool isArchived,
            String? comment,
            LinkValidationStatus validationStatus,
            String? validationMessage,
            int? validationStatusCode)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LinkEntry() when $default != null:
        return $default(
            _that.key,
            _that.url,
            _that.tags,
            _that.folderIds,
            _that.isArchived,
            _that.comment,
            _that.validationStatus,
            _that.validationMessage,
            _that.validationStatusCode);
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
            Key key,
            String url,
            List<String> tags,
            List<String> folderIds,
            bool isArchived,
            String? comment,
            LinkValidationStatus validationStatus,
            String? validationMessage,
            int? validationStatusCode)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LinkEntry():
        return $default(
            _that.key,
            _that.url,
            _that.tags,
            _that.folderIds,
            _that.isArchived,
            _that.comment,
            _that.validationStatus,
            _that.validationMessage,
            _that.validationStatusCode);
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
            Key key,
            String url,
            List<String> tags,
            List<String> folderIds,
            bool isArchived,
            String? comment,
            LinkValidationStatus validationStatus,
            String? validationMessage,
            int? validationStatusCode)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LinkEntry() when $default != null:
        return $default(
            _that.key,
            _that.url,
            _that.tags,
            _that.folderIds,
            _that.isArchived,
            _that.comment,
            _that.validationStatus,
            _that.validationMessage,
            _that.validationStatusCode);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LinkEntry with DiagnosticableTreeMixin implements LinkEntry {
  const _LinkEntry(
      {required this.key,
      required this.url,
      final List<String> tags = const [],
      final List<String> folderIds = const [],
      this.isArchived = false,
      this.comment,
      this.validationStatus = LinkValidationStatus.pending,
      this.validationMessage,
      this.validationStatusCode})
      : _tags = tags,
        _folderIds = folderIds;

  @override
  final Key key;
  @override
  final String url;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<String> _folderIds;
  @override
  @JsonKey()
  List<String> get folderIds {
    if (_folderIds is EqualUnmodifiableListView) return _folderIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_folderIds);
  }

  @override
  @JsonKey()
  final bool isArchived;
  @override
  final String? comment;
  @override
  @JsonKey()
  final LinkValidationStatus validationStatus;
  @override
  final String? validationMessage;
  @override
  final int? validationStatusCode;

  /// Create a copy of LinkEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LinkEntryCopyWith<_LinkEntry> get copyWith =>
      __$LinkEntryCopyWithImpl<_LinkEntry>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'LinkEntry'))
      ..add(DiagnosticsProperty('key', key))
      ..add(DiagnosticsProperty('url', url))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('folderIds', folderIds))
      ..add(DiagnosticsProperty('isArchived', isArchived))
      ..add(DiagnosticsProperty('comment', comment))
      ..add(DiagnosticsProperty('validationStatus', validationStatus))
      ..add(DiagnosticsProperty('validationMessage', validationMessage))
      ..add(DiagnosticsProperty('validationStatusCode', validationStatusCode));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LinkEntry &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._folderIds, _folderIds) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.validationStatus, validationStatus) ||
                other.validationStatus == validationStatus) &&
            (identical(other.validationMessage, validationMessage) ||
                other.validationMessage == validationMessage) &&
            (identical(other.validationStatusCode, validationStatusCode) ||
                other.validationStatusCode == validationStatusCode));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      key,
      url,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_folderIds),
      isArchived,
      comment,
      validationStatus,
      validationMessage,
      validationStatusCode);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LinkEntry(key: $key, url: $url, tags: $tags, folderIds: $folderIds, isArchived: $isArchived, comment: $comment, validationStatus: $validationStatus, validationMessage: $validationMessage, validationStatusCode: $validationStatusCode)';
  }
}

/// @nodoc
abstract mixin class _$LinkEntryCopyWith<$Res>
    implements $LinkEntryCopyWith<$Res> {
  factory _$LinkEntryCopyWith(
          _LinkEntry value, $Res Function(_LinkEntry) _then) =
      __$LinkEntryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Key key,
      String url,
      List<String> tags,
      List<String> folderIds,
      bool isArchived,
      String? comment,
      LinkValidationStatus validationStatus,
      String? validationMessage,
      int? validationStatusCode});
}

/// @nodoc
class __$LinkEntryCopyWithImpl<$Res> implements _$LinkEntryCopyWith<$Res> {
  __$LinkEntryCopyWithImpl(this._self, this._then);

  final _LinkEntry _self;
  final $Res Function(_LinkEntry) _then;

  /// Create a copy of LinkEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? key = null,
    Object? url = null,
    Object? tags = null,
    Object? folderIds = null,
    Object? isArchived = null,
    Object? comment = freezed,
    Object? validationStatus = null,
    Object? validationMessage = freezed,
    Object? validationStatusCode = freezed,
  }) {
    return _then(_LinkEntry(
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as Key,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      folderIds: null == folderIds
          ? _self._folderIds
          : folderIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      comment: freezed == comment
          ? _self.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      validationStatus: null == validationStatus
          ? _self.validationStatus
          : validationStatus // ignore: cast_nullable_to_non_nullable
              as LinkValidationStatus,
      validationMessage: freezed == validationMessage
          ? _self.validationMessage
          : validationMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      validationStatusCode: freezed == validationStatusCode
          ? _self.validationStatusCode
          : validationStatusCode // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
