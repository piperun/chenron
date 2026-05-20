// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Metadata {
  String get url;
  String? get title;
  String? get description;
  String? get imageUrl;
  DateTime get fetchedAt;
  int get ttlDays;
  String? get etag;
  String? get contentHash;
  int get consecutiveUnchanged;

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MetadataCopyWith<Metadata> get copyWith =>
      _$MetadataCopyWithImpl<Metadata>(this as Metadata, _$identity);

  /// Serializes this Metadata to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Metadata &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.fetchedAt, fetchedAt) ||
                other.fetchedAt == fetchedAt) &&
            (identical(other.ttlDays, ttlDays) || other.ttlDays == ttlDays) &&
            (identical(other.etag, etag) || other.etag == etag) &&
            (identical(other.contentHash, contentHash) ||
                other.contentHash == contentHash) &&
            (identical(other.consecutiveUnchanged, consecutiveUnchanged) ||
                other.consecutiveUnchanged == consecutiveUnchanged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, title, description,
      imageUrl, fetchedAt, ttlDays, etag, contentHash, consecutiveUnchanged);

  @override
  String toString() {
    return 'Metadata(url: $url, title: $title, description: $description, imageUrl: $imageUrl, fetchedAt: $fetchedAt, ttlDays: $ttlDays, etag: $etag, contentHash: $contentHash, consecutiveUnchanged: $consecutiveUnchanged)';
  }
}

/// @nodoc
abstract mixin class $MetadataCopyWith<$Res> {
  factory $MetadataCopyWith(Metadata value, $Res Function(Metadata) _then) =
      _$MetadataCopyWithImpl;
  @useResult
  $Res call(
      {String url,
      String? title,
      String? description,
      String? imageUrl,
      DateTime fetchedAt,
      int ttlDays,
      String? etag,
      String? contentHash,
      int consecutiveUnchanged});
}

/// @nodoc
class _$MetadataCopyWithImpl<$Res> implements $MetadataCopyWith<$Res> {
  _$MetadataCopyWithImpl(this._self, this._then);

  final Metadata _self;
  final $Res Function(Metadata) _then;

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? fetchedAt = null,
    Object? ttlDays = null,
    Object? etag = freezed,
    Object? contentHash = freezed,
    Object? consecutiveUnchanged = null,
  }) {
    return _then(_self.copyWith(
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fetchedAt: null == fetchedAt
          ? _self.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ttlDays: null == ttlDays
          ? _self.ttlDays
          : ttlDays // ignore: cast_nullable_to_non_nullable
              as int,
      etag: freezed == etag
          ? _self.etag
          : etag // ignore: cast_nullable_to_non_nullable
              as String?,
      contentHash: freezed == contentHash
          ? _self.contentHash
          : contentHash // ignore: cast_nullable_to_non_nullable
              as String?,
      consecutiveUnchanged: null == consecutiveUnchanged
          ? _self.consecutiveUnchanged
          : consecutiveUnchanged // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [Metadata].
extension MetadataPatterns on Metadata {
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
    TResult Function(_Metadata value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Metadata() when $default != null:
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
    TResult Function(_Metadata value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Metadata():
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
    TResult? Function(_Metadata value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Metadata() when $default != null:
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
            String url,
            String? title,
            String? description,
            String? imageUrl,
            DateTime fetchedAt,
            int ttlDays,
            String? etag,
            String? contentHash,
            int consecutiveUnchanged)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Metadata() when $default != null:
        return $default(
            _that.url,
            _that.title,
            _that.description,
            _that.imageUrl,
            _that.fetchedAt,
            _that.ttlDays,
            _that.etag,
            _that.contentHash,
            _that.consecutiveUnchanged);
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
            String url,
            String? title,
            String? description,
            String? imageUrl,
            DateTime fetchedAt,
            int ttlDays,
            String? etag,
            String? contentHash,
            int consecutiveUnchanged)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Metadata():
        return $default(
            _that.url,
            _that.title,
            _that.description,
            _that.imageUrl,
            _that.fetchedAt,
            _that.ttlDays,
            _that.etag,
            _that.contentHash,
            _that.consecutiveUnchanged);
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
            String url,
            String? title,
            String? description,
            String? imageUrl,
            DateTime fetchedAt,
            int ttlDays,
            String? etag,
            String? contentHash,
            int consecutiveUnchanged)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Metadata() when $default != null:
        return $default(
            _that.url,
            _that.title,
            _that.description,
            _that.imageUrl,
            _that.fetchedAt,
            _that.ttlDays,
            _that.etag,
            _that.contentHash,
            _that.consecutiveUnchanged);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Metadata implements Metadata {
  const _Metadata(
      {required this.url,
      this.title,
      this.description,
      this.imageUrl,
      required this.fetchedAt,
      this.ttlDays = 7,
      this.etag,
      this.contentHash,
      this.consecutiveUnchanged = 0});
  factory _Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);

  @override
  final String url;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? imageUrl;
  @override
  final DateTime fetchedAt;
  @override
  @JsonKey()
  final int ttlDays;
  @override
  final String? etag;
  @override
  final String? contentHash;
  @override
  @JsonKey()
  final int consecutiveUnchanged;

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MetadataCopyWith<_Metadata> get copyWith =>
      __$MetadataCopyWithImpl<_Metadata>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MetadataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Metadata &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.fetchedAt, fetchedAt) ||
                other.fetchedAt == fetchedAt) &&
            (identical(other.ttlDays, ttlDays) || other.ttlDays == ttlDays) &&
            (identical(other.etag, etag) || other.etag == etag) &&
            (identical(other.contentHash, contentHash) ||
                other.contentHash == contentHash) &&
            (identical(other.consecutiveUnchanged, consecutiveUnchanged) ||
                other.consecutiveUnchanged == consecutiveUnchanged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, title, description,
      imageUrl, fetchedAt, ttlDays, etag, contentHash, consecutiveUnchanged);

  @override
  String toString() {
    return 'Metadata(url: $url, title: $title, description: $description, imageUrl: $imageUrl, fetchedAt: $fetchedAt, ttlDays: $ttlDays, etag: $etag, contentHash: $contentHash, consecutiveUnchanged: $consecutiveUnchanged)';
  }
}

/// @nodoc
abstract mixin class _$MetadataCopyWith<$Res>
    implements $MetadataCopyWith<$Res> {
  factory _$MetadataCopyWith(_Metadata value, $Res Function(_Metadata) _then) =
      __$MetadataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String url,
      String? title,
      String? description,
      String? imageUrl,
      DateTime fetchedAt,
      int ttlDays,
      String? etag,
      String? contentHash,
      int consecutiveUnchanged});
}

/// @nodoc
class __$MetadataCopyWithImpl<$Res> implements _$MetadataCopyWith<$Res> {
  __$MetadataCopyWithImpl(this._self, this._then);

  final _Metadata _self;
  final $Res Function(_Metadata) _then;

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? url = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? fetchedAt = null,
    Object? ttlDays = null,
    Object? etag = freezed,
    Object? contentHash = freezed,
    Object? consecutiveUnchanged = null,
  }) {
    return _then(_Metadata(
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fetchedAt: null == fetchedAt
          ? _self.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ttlDays: null == ttlDays
          ? _self.ttlDays
          : ttlDays // ignore: cast_nullable_to_non_nullable
              as int,
      etag: freezed == etag
          ? _self.etag
          : etag // ignore: cast_nullable_to_non_nullable
              as String?,
      contentHash: freezed == contentHash
          ? _self.contentHash
          : contentHash // ignore: cast_nullable_to_non_nullable
              as String?,
      consecutiveUnchanged: null == consecutiveUnchanged
          ? _self.consecutiveUnchanged
          : consecutiveUnchanged // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
