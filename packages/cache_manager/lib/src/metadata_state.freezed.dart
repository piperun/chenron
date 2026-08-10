// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metadata_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MetadataState {
  MetadataRefreshPhase get refreshPhase;
  MetadataRefreshFailure? get lastFailure;

  /// Create a copy of MetadataState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MetadataStateCopyWith<MetadataState> get copyWith =>
      _$MetadataStateCopyWithImpl<MetadataState>(
          this as MetadataState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MetadataState &&
            (identical(other.refreshPhase, refreshPhase) ||
                other.refreshPhase == refreshPhase) &&
            (identical(other.lastFailure, lastFailure) ||
                other.lastFailure == lastFailure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, refreshPhase, lastFailure);

  @override
  String toString() {
    return 'MetadataState(refreshPhase: $refreshPhase, lastFailure: $lastFailure)';
  }
}

/// @nodoc
abstract mixin class $MetadataStateCopyWith<$Res> {
  factory $MetadataStateCopyWith(
          MetadataState value, $Res Function(MetadataState) _then) =
      _$MetadataStateCopyWithImpl;
  @useResult
  $Res call(
      {MetadataRefreshPhase refreshPhase, MetadataRefreshFailure? lastFailure});
}

/// @nodoc
class _$MetadataStateCopyWithImpl<$Res>
    implements $MetadataStateCopyWith<$Res> {
  _$MetadataStateCopyWithImpl(this._self, this._then);

  final MetadataState _self;
  final $Res Function(MetadataState) _then;

  /// Create a copy of MetadataState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refreshPhase = null,
    Object? lastFailure = freezed,
  }) {
    return _then(_self.copyWith(
      refreshPhase: null == refreshPhase
          ? _self.refreshPhase
          : refreshPhase // ignore: cast_nullable_to_non_nullable
              as MetadataRefreshPhase,
      lastFailure: freezed == lastFailure
          ? _self.lastFailure
          : lastFailure // ignore: cast_nullable_to_non_nullable
              as MetadataRefreshFailure?,
    ));
  }
}

/// Adds pattern-matching-related methods to [MetadataState].
extension MetadataStatePatterns on MetadataState {
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
    TResult Function(MetadataStateUnavailable value)? unavailable,
    TResult Function(MetadataStateAvailable value)? available,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case MetadataStateUnavailable() when unavailable != null:
        return unavailable(_that);
      case MetadataStateAvailable() when available != null:
        return available(_that);
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
    required TResult Function(MetadataStateUnavailable value) unavailable,
    required TResult Function(MetadataStateAvailable value) available,
  }) {
    final _that = this;
    switch (_that) {
      case MetadataStateUnavailable():
        return unavailable(_that);
      case MetadataStateAvailable():
        return available(_that);
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
    TResult? Function(MetadataStateUnavailable value)? unavailable,
    TResult? Function(MetadataStateAvailable value)? available,
  }) {
    final _that = this;
    switch (_that) {
      case MetadataStateUnavailable() when unavailable != null:
        return unavailable(_that);
      case MetadataStateAvailable() when available != null:
        return available(_that);
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
    TResult Function(MetadataRefreshPhase refreshPhase,
            MetadataRefreshFailure? lastFailure)?
        unavailable,
    TResult Function(
            Metadata data,
            MetadataFreshness freshness,
            MetadataRefreshPhase refreshPhase,
            MetadataRefreshFailure? lastFailure)?
        available,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case MetadataStateUnavailable() when unavailable != null:
        return unavailable(_that.refreshPhase, _that.lastFailure);
      case MetadataStateAvailable() when available != null:
        return available(
            _that.data, _that.freshness, _that.refreshPhase, _that.lastFailure);
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
    required TResult Function(MetadataRefreshPhase refreshPhase,
            MetadataRefreshFailure? lastFailure)
        unavailable,
    required TResult Function(
            Metadata data,
            MetadataFreshness freshness,
            MetadataRefreshPhase refreshPhase,
            MetadataRefreshFailure? lastFailure)
        available,
  }) {
    final _that = this;
    switch (_that) {
      case MetadataStateUnavailable():
        return unavailable(_that.refreshPhase, _that.lastFailure);
      case MetadataStateAvailable():
        return available(
            _that.data, _that.freshness, _that.refreshPhase, _that.lastFailure);
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
    TResult? Function(MetadataRefreshPhase refreshPhase,
            MetadataRefreshFailure? lastFailure)?
        unavailable,
    TResult? Function(
            Metadata data,
            MetadataFreshness freshness,
            MetadataRefreshPhase refreshPhase,
            MetadataRefreshFailure? lastFailure)?
        available,
  }) {
    final _that = this;
    switch (_that) {
      case MetadataStateUnavailable() when unavailable != null:
        return unavailable(_that.refreshPhase, _that.lastFailure);
      case MetadataStateAvailable() when available != null:
        return available(
            _that.data, _that.freshness, _that.refreshPhase, _that.lastFailure);
      case _:
        return null;
    }
  }
}

/// @nodoc

class MetadataStateUnavailable extends MetadataState {
  const MetadataStateUnavailable(
      {this.refreshPhase = MetadataRefreshPhase.idle, this.lastFailure})
      : super._();

  @override
  @JsonKey()
  final MetadataRefreshPhase refreshPhase;
  @override
  final MetadataRefreshFailure? lastFailure;

  /// Create a copy of MetadataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MetadataStateUnavailableCopyWith<MetadataStateUnavailable> get copyWith =>
      _$MetadataStateUnavailableCopyWithImpl<MetadataStateUnavailable>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MetadataStateUnavailable &&
            (identical(other.refreshPhase, refreshPhase) ||
                other.refreshPhase == refreshPhase) &&
            (identical(other.lastFailure, lastFailure) ||
                other.lastFailure == lastFailure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, refreshPhase, lastFailure);

  @override
  String toString() {
    return 'MetadataState.unavailable(refreshPhase: $refreshPhase, lastFailure: $lastFailure)';
  }
}

/// @nodoc
abstract mixin class $MetadataStateUnavailableCopyWith<$Res>
    implements $MetadataStateCopyWith<$Res> {
  factory $MetadataStateUnavailableCopyWith(MetadataStateUnavailable value,
          $Res Function(MetadataStateUnavailable) _then) =
      _$MetadataStateUnavailableCopyWithImpl;
  @override
  @useResult
  $Res call(
      {MetadataRefreshPhase refreshPhase, MetadataRefreshFailure? lastFailure});
}

/// @nodoc
class _$MetadataStateUnavailableCopyWithImpl<$Res>
    implements $MetadataStateUnavailableCopyWith<$Res> {
  _$MetadataStateUnavailableCopyWithImpl(this._self, this._then);

  final MetadataStateUnavailable _self;
  final $Res Function(MetadataStateUnavailable) _then;

  /// Create a copy of MetadataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? refreshPhase = null,
    Object? lastFailure = freezed,
  }) {
    return _then(MetadataStateUnavailable(
      refreshPhase: null == refreshPhase
          ? _self.refreshPhase
          : refreshPhase // ignore: cast_nullable_to_non_nullable
              as MetadataRefreshPhase,
      lastFailure: freezed == lastFailure
          ? _self.lastFailure
          : lastFailure // ignore: cast_nullable_to_non_nullable
              as MetadataRefreshFailure?,
    ));
  }
}

/// @nodoc

class MetadataStateAvailable extends MetadataState {
  const MetadataStateAvailable(
      {required this.data,
      required this.freshness,
      this.refreshPhase = MetadataRefreshPhase.idle,
      this.lastFailure})
      : super._();

  final Metadata data;
  final MetadataFreshness freshness;
  @override
  @JsonKey()
  final MetadataRefreshPhase refreshPhase;
  @override
  final MetadataRefreshFailure? lastFailure;

  /// Create a copy of MetadataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MetadataStateAvailableCopyWith<MetadataStateAvailable> get copyWith =>
      _$MetadataStateAvailableCopyWithImpl<MetadataStateAvailable>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MetadataStateAvailable &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.freshness, freshness) ||
                other.freshness == freshness) &&
            (identical(other.refreshPhase, refreshPhase) ||
                other.refreshPhase == refreshPhase) &&
            (identical(other.lastFailure, lastFailure) ||
                other.lastFailure == lastFailure));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, data, freshness, refreshPhase, lastFailure);

  @override
  String toString() {
    return 'MetadataState.available(data: $data, freshness: $freshness, refreshPhase: $refreshPhase, lastFailure: $lastFailure)';
  }
}

/// @nodoc
abstract mixin class $MetadataStateAvailableCopyWith<$Res>
    implements $MetadataStateCopyWith<$Res> {
  factory $MetadataStateAvailableCopyWith(MetadataStateAvailable value,
          $Res Function(MetadataStateAvailable) _then) =
      _$MetadataStateAvailableCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Metadata data,
      MetadataFreshness freshness,
      MetadataRefreshPhase refreshPhase,
      MetadataRefreshFailure? lastFailure});

  $MetadataCopyWith<$Res> get data;
}

/// @nodoc
class _$MetadataStateAvailableCopyWithImpl<$Res>
    implements $MetadataStateAvailableCopyWith<$Res> {
  _$MetadataStateAvailableCopyWithImpl(this._self, this._then);

  final MetadataStateAvailable _self;
  final $Res Function(MetadataStateAvailable) _then;

  /// Create a copy of MetadataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
    Object? freshness = null,
    Object? refreshPhase = null,
    Object? lastFailure = freezed,
  }) {
    return _then(MetadataStateAvailable(
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as Metadata,
      freshness: null == freshness
          ? _self.freshness
          : freshness // ignore: cast_nullable_to_non_nullable
              as MetadataFreshness,
      refreshPhase: null == refreshPhase
          ? _self.refreshPhase
          : refreshPhase // ignore: cast_nullable_to_non_nullable
              as MetadataRefreshPhase,
      lastFailure: freezed == lastFailure
          ? _self.lastFailure
          : lastFailure // ignore: cast_nullable_to_non_nullable
              as MetadataRefreshFailure?,
    ));
  }

  /// Create a copy of MetadataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MetadataCopyWith<$Res> get data {
    return $MetadataCopyWith<$Res>(_self.data, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

// dart format on
