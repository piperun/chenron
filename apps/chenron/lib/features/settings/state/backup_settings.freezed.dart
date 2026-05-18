// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BackupPreferences {
  String? get backupInterval;
  String? get backupPath;

  /// Create a copy of BackupPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BackupPreferencesCopyWith<BackupPreferences> get copyWith =>
      _$BackupPreferencesCopyWithImpl<BackupPreferences>(
          this as BackupPreferences, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BackupPreferences &&
            (identical(other.backupInterval, backupInterval) ||
                other.backupInterval == backupInterval) &&
            (identical(other.backupPath, backupPath) ||
                other.backupPath == backupPath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, backupInterval, backupPath);

  @override
  String toString() {
    return 'BackupPreferences(backupInterval: $backupInterval, backupPath: $backupPath)';
  }
}

/// @nodoc
abstract mixin class $BackupPreferencesCopyWith<$Res> {
  factory $BackupPreferencesCopyWith(
          BackupPreferences value, $Res Function(BackupPreferences) _then) =
      _$BackupPreferencesCopyWithImpl;
  @useResult
  $Res call({String? backupInterval, String? backupPath});
}

/// @nodoc
class _$BackupPreferencesCopyWithImpl<$Res>
    implements $BackupPreferencesCopyWith<$Res> {
  _$BackupPreferencesCopyWithImpl(this._self, this._then);

  final BackupPreferences _self;
  final $Res Function(BackupPreferences) _then;

  /// Create a copy of BackupPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? backupInterval = freezed,
    Object? backupPath = freezed,
  }) {
    return _then(_self.copyWith(
      backupInterval: freezed == backupInterval
          ? _self.backupInterval
          : backupInterval // ignore: cast_nullable_to_non_nullable
              as String?,
      backupPath: freezed == backupPath
          ? _self.backupPath
          : backupPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [BackupPreferences].
extension BackupPreferencesPatterns on BackupPreferences {
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
    TResult Function(_BackupPreferences value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BackupPreferences() when $default != null:
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
    TResult Function(_BackupPreferences value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BackupPreferences():
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
    TResult? Function(_BackupPreferences value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BackupPreferences() when $default != null:
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
    TResult Function(String? backupInterval, String? backupPath)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BackupPreferences() when $default != null:
        return $default(_that.backupInterval, _that.backupPath);
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
    TResult Function(String? backupInterval, String? backupPath) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BackupPreferences():
        return $default(_that.backupInterval, _that.backupPath);
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
    TResult? Function(String? backupInterval, String? backupPath)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BackupPreferences() when $default != null:
        return $default(_that.backupInterval, _that.backupPath);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _BackupPreferences implements BackupPreferences {
  const _BackupPreferences({this.backupInterval, this.backupPath});

  @override
  final String? backupInterval;
  @override
  final String? backupPath;

  /// Create a copy of BackupPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BackupPreferencesCopyWith<_BackupPreferences> get copyWith =>
      __$BackupPreferencesCopyWithImpl<_BackupPreferences>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BackupPreferences &&
            (identical(other.backupInterval, backupInterval) ||
                other.backupInterval == backupInterval) &&
            (identical(other.backupPath, backupPath) ||
                other.backupPath == backupPath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, backupInterval, backupPath);

  @override
  String toString() {
    return 'BackupPreferences(backupInterval: $backupInterval, backupPath: $backupPath)';
  }
}

/// @nodoc
abstract mixin class _$BackupPreferencesCopyWith<$Res>
    implements $BackupPreferencesCopyWith<$Res> {
  factory _$BackupPreferencesCopyWith(
          _BackupPreferences value, $Res Function(_BackupPreferences) _then) =
      __$BackupPreferencesCopyWithImpl;
  @override
  @useResult
  $Res call({String? backupInterval, String? backupPath});
}

/// @nodoc
class __$BackupPreferencesCopyWithImpl<$Res>
    implements _$BackupPreferencesCopyWith<$Res> {
  __$BackupPreferencesCopyWithImpl(this._self, this._then);

  final _BackupPreferences _self;
  final $Res Function(_BackupPreferences) _then;

  /// Create a copy of BackupPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? backupInterval = freezed,
    Object? backupPath = freezed,
  }) {
    return _then(_BackupPreferences(
      backupInterval: freezed == backupInterval
          ? _self.backupInterval
          : backupInterval // ignore: cast_nullable_to_non_nullable
              as String?,
      backupPath: freezed == backupPath
          ? _self.backupPath
          : backupPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
