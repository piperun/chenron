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
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is MetadataState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MetadataState()';
  }
}

/// @nodoc
class $MetadataStateCopyWith<$Res> {
  $MetadataStateCopyWith(MetadataState _, $Res Function(MetadataState) __);
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
    TResult Function(MetadataStateLoading value)? loading,
    TResult Function(MetadataStateReady value)? ready,
    TResult Function(MetadataStateFailed value)? failed,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case MetadataStateUnavailable() when unavailable != null:
        return unavailable(_that);
      case MetadataStateAvailable() when available != null:
        return available(_that);
      case MetadataStateLoading() when loading != null:
        return loading(_that);
      case MetadataStateReady() when ready != null:
        return ready(_that);
      case MetadataStateFailed() when failed != null:
        return failed(_that);
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
    required TResult Function(MetadataStateLoading value) loading,
    required TResult Function(MetadataStateReady value) ready,
    required TResult Function(MetadataStateFailed value) failed,
  }) {
    final _that = this;
    switch (_that) {
      case MetadataStateUnavailable():
        return unavailable(_that);
      case MetadataStateAvailable():
        return available(_that);
      case MetadataStateLoading():
        return loading(_that);
      case MetadataStateReady():
        return ready(_that);
      case MetadataStateFailed():
        return failed(_that);
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
    TResult? Function(MetadataStateLoading value)? loading,
    TResult? Function(MetadataStateReady value)? ready,
    TResult? Function(MetadataStateFailed value)? failed,
  }) {
    final _that = this;
    switch (_that) {
      case MetadataStateUnavailable() when unavailable != null:
        return unavailable(_that);
      case MetadataStateAvailable() when available != null:
        return available(_that);
      case MetadataStateLoading() when loading != null:
        return loading(_that);
      case MetadataStateReady() when ready != null:
        return ready(_that);
      case MetadataStateFailed() when failed != null:
        return failed(_that);
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
    TResult Function()? loading,
    TResult Function(Metadata data)? ready,
    TResult Function(String reason, int attemptCount)? failed,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case MetadataStateUnavailable() when unavailable != null:
        return unavailable(_that.refreshPhase, _that.lastFailure);
      case MetadataStateAvailable() when available != null:
        return available(
            _that.data, _that.freshness, _that.refreshPhase, _that.lastFailure);
      case MetadataStateLoading() when loading != null:
        return loading();
      case MetadataStateReady() when ready != null:
        return ready(_that.data);
      case MetadataStateFailed() when failed != null:
        return failed(_that.reason, _that.attemptCount);
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
    required TResult Function() loading,
    required TResult Function(Metadata data) ready,
    required TResult Function(String reason, int attemptCount) failed,
  }) {
    final _that = this;
    switch (_that) {
      case MetadataStateUnavailable():
        return unavailable(_that.refreshPhase, _that.lastFailure);
      case MetadataStateAvailable():
        return available(
            _that.data, _that.freshness, _that.refreshPhase, _that.lastFailure);
      case MetadataStateLoading():
        return loading();
      case MetadataStateReady():
        return ready(_that.data);
      case MetadataStateFailed():
        return failed(_that.reason, _that.attemptCount);
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
    TResult? Function()? loading,
    TResult? Function(Metadata data)? ready,
    TResult? Function(String reason, int attemptCount)? failed,
  }) {
    final _that = this;
    switch (_that) {
      case MetadataStateUnavailable() when unavailable != null:
        return unavailable(_that.refreshPhase, _that.lastFailure);
      case MetadataStateAvailable() when available != null:
        return available(
            _that.data, _that.freshness, _that.refreshPhase, _that.lastFailure);
      case MetadataStateLoading() when loading != null:
        return loading();
      case MetadataStateReady() when ready != null:
        return ready(_that.data);
      case MetadataStateFailed() when failed != null:
        return failed(_that.reason, _that.attemptCount);
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

  @JsonKey()
  final MetadataRefreshPhase refreshPhase;
  final MetadataRefreshFailure? lastFailure;

  /// Create a copy of MetadataState
  /// with the given fields replaced by the non-null parameter values.
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
  @JsonKey()
  final MetadataRefreshPhase refreshPhase;
  final MetadataRefreshFailure? lastFailure;

  /// Create a copy of MetadataState
  /// with the given fields replaced by the non-null parameter values.
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

/// @nodoc

@Deprecated("Use MetadataState.unavailable instead.")
class MetadataStateLoading extends MetadataState {
  const MetadataStateLoading() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is MetadataStateLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MetadataState.loading()';
  }
}

/// @nodoc

@Deprecated("Use MetadataState.available instead.")
class MetadataStateReady extends MetadataState {
  const MetadataStateReady(this.data) : super._();

  final Metadata data;

  /// Create a copy of MetadataState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MetadataStateReadyCopyWith<MetadataStateReady> get copyWith =>
      _$MetadataStateReadyCopyWithImpl<MetadataStateReady>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MetadataStateReady &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @override
  String toString() {
    return 'MetadataState.ready(data: $data)';
  }
}

/// @nodoc
abstract mixin class $MetadataStateReadyCopyWith<$Res>
    implements $MetadataStateCopyWith<$Res> {
  factory $MetadataStateReadyCopyWith(
          MetadataStateReady value, $Res Function(MetadataStateReady) _then) =
      _$MetadataStateReadyCopyWithImpl;
  @useResult
  $Res call({Metadata data});

  $MetadataCopyWith<$Res> get data;
}

/// @nodoc
class _$MetadataStateReadyCopyWithImpl<$Res>
    implements $MetadataStateReadyCopyWith<$Res> {
  _$MetadataStateReadyCopyWithImpl(this._self, this._then);

  final MetadataStateReady _self;
  final $Res Function(MetadataStateReady) _then;

  /// Create a copy of MetadataState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
  }) {
    return _then(MetadataStateReady(
      null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as Metadata,
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

/// @nodoc

@Deprecated("Use availability plus MetadataRefreshPhase.failed instead.")
class MetadataStateFailed extends MetadataState {
  const MetadataStateFailed(this.reason, this.attemptCount) : super._();

  final String reason;
  final int attemptCount;

  /// Create a copy of MetadataState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MetadataStateFailedCopyWith<MetadataStateFailed> get copyWith =>
      _$MetadataStateFailedCopyWithImpl<MetadataStateFailed>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MetadataStateFailed &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.attemptCount, attemptCount) ||
                other.attemptCount == attemptCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, reason, attemptCount);

  @override
  String toString() {
    return 'MetadataState.failed(reason: $reason, attemptCount: $attemptCount)';
  }
}

/// @nodoc
abstract mixin class $MetadataStateFailedCopyWith<$Res>
    implements $MetadataStateCopyWith<$Res> {
  factory $MetadataStateFailedCopyWith(
          MetadataStateFailed value, $Res Function(MetadataStateFailed) _then) =
      _$MetadataStateFailedCopyWithImpl;
  @useResult
  $Res call({String reason, int attemptCount});
}

/// @nodoc
class _$MetadataStateFailedCopyWithImpl<$Res>
    implements $MetadataStateFailedCopyWith<$Res> {
  _$MetadataStateFailedCopyWithImpl(this._self, this._then);

  final MetadataStateFailed _self;
  final $Res Function(MetadataStateFailed) _then;

  /// Create a copy of MetadataState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? reason = null,
    Object? attemptCount = null,
  }) {
    return _then(MetadataStateFailed(
      null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      null == attemptCount
          ? _self.attemptCount
          : attemptCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
