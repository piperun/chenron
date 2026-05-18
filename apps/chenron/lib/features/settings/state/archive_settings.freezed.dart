// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'archive_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ArchiveSettings {
  bool get defaultArchiveIs;
  bool get defaultArchiveOrg;
  String? get archiveOrgS3AccessKey;
  String? get archiveOrgS3SecretKey;

  /// Create a copy of ArchiveSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ArchiveSettingsCopyWith<ArchiveSettings> get copyWith =>
      _$ArchiveSettingsCopyWithImpl<ArchiveSettings>(
          this as ArchiveSettings, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ArchiveSettings &&
            (identical(other.defaultArchiveIs, defaultArchiveIs) ||
                other.defaultArchiveIs == defaultArchiveIs) &&
            (identical(other.defaultArchiveOrg, defaultArchiveOrg) ||
                other.defaultArchiveOrg == defaultArchiveOrg) &&
            (identical(other.archiveOrgS3AccessKey, archiveOrgS3AccessKey) ||
                other.archiveOrgS3AccessKey == archiveOrgS3AccessKey) &&
            (identical(other.archiveOrgS3SecretKey, archiveOrgS3SecretKey) ||
                other.archiveOrgS3SecretKey == archiveOrgS3SecretKey));
  }

  @override
  int get hashCode => Object.hash(runtimeType, defaultArchiveIs,
      defaultArchiveOrg, archiveOrgS3AccessKey, archiveOrgS3SecretKey);

  @override
  String toString() {
    return 'ArchiveSettings(defaultArchiveIs: $defaultArchiveIs, defaultArchiveOrg: $defaultArchiveOrg, archiveOrgS3AccessKey: $archiveOrgS3AccessKey, archiveOrgS3SecretKey: $archiveOrgS3SecretKey)';
  }
}

/// @nodoc
abstract mixin class $ArchiveSettingsCopyWith<$Res> {
  factory $ArchiveSettingsCopyWith(
          ArchiveSettings value, $Res Function(ArchiveSettings) _then) =
      _$ArchiveSettingsCopyWithImpl;
  @useResult
  $Res call(
      {bool defaultArchiveIs,
      bool defaultArchiveOrg,
      String? archiveOrgS3AccessKey,
      String? archiveOrgS3SecretKey});
}

/// @nodoc
class _$ArchiveSettingsCopyWithImpl<$Res>
    implements $ArchiveSettingsCopyWith<$Res> {
  _$ArchiveSettingsCopyWithImpl(this._self, this._then);

  final ArchiveSettings _self;
  final $Res Function(ArchiveSettings) _then;

  /// Create a copy of ArchiveSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? defaultArchiveIs = null,
    Object? defaultArchiveOrg = null,
    Object? archiveOrgS3AccessKey = freezed,
    Object? archiveOrgS3SecretKey = freezed,
  }) {
    return _then(_self.copyWith(
      defaultArchiveIs: null == defaultArchiveIs
          ? _self.defaultArchiveIs
          : defaultArchiveIs // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultArchiveOrg: null == defaultArchiveOrg
          ? _self.defaultArchiveOrg
          : defaultArchiveOrg // ignore: cast_nullable_to_non_nullable
              as bool,
      archiveOrgS3AccessKey: freezed == archiveOrgS3AccessKey
          ? _self.archiveOrgS3AccessKey
          : archiveOrgS3AccessKey // ignore: cast_nullable_to_non_nullable
              as String?,
      archiveOrgS3SecretKey: freezed == archiveOrgS3SecretKey
          ? _self.archiveOrgS3SecretKey
          : archiveOrgS3SecretKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ArchiveSettings].
extension ArchiveSettingsPatterns on ArchiveSettings {
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
    TResult Function(_ArchiveSettings value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ArchiveSettings() when $default != null:
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
    TResult Function(_ArchiveSettings value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ArchiveSettings():
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
    TResult? Function(_ArchiveSettings value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ArchiveSettings() when $default != null:
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
    TResult Function(bool defaultArchiveIs, bool defaultArchiveOrg,
            String? archiveOrgS3AccessKey, String? archiveOrgS3SecretKey)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ArchiveSettings() when $default != null:
        return $default(_that.defaultArchiveIs, _that.defaultArchiveOrg,
            _that.archiveOrgS3AccessKey, _that.archiveOrgS3SecretKey);
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
    TResult Function(bool defaultArchiveIs, bool defaultArchiveOrg,
            String? archiveOrgS3AccessKey, String? archiveOrgS3SecretKey)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ArchiveSettings():
        return $default(_that.defaultArchiveIs, _that.defaultArchiveOrg,
            _that.archiveOrgS3AccessKey, _that.archiveOrgS3SecretKey);
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
    TResult? Function(bool defaultArchiveIs, bool defaultArchiveOrg,
            String? archiveOrgS3AccessKey, String? archiveOrgS3SecretKey)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ArchiveSettings() when $default != null:
        return $default(_that.defaultArchiveIs, _that.defaultArchiveOrg,
            _that.archiveOrgS3AccessKey, _that.archiveOrgS3SecretKey);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ArchiveSettings implements ArchiveSettings {
  const _ArchiveSettings(
      {this.defaultArchiveIs = false,
      this.defaultArchiveOrg = false,
      this.archiveOrgS3AccessKey,
      this.archiveOrgS3SecretKey});

  @override
  @JsonKey()
  final bool defaultArchiveIs;
  @override
  @JsonKey()
  final bool defaultArchiveOrg;
  @override
  final String? archiveOrgS3AccessKey;
  @override
  final String? archiveOrgS3SecretKey;

  /// Create a copy of ArchiveSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ArchiveSettingsCopyWith<_ArchiveSettings> get copyWith =>
      __$ArchiveSettingsCopyWithImpl<_ArchiveSettings>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ArchiveSettings &&
            (identical(other.defaultArchiveIs, defaultArchiveIs) ||
                other.defaultArchiveIs == defaultArchiveIs) &&
            (identical(other.defaultArchiveOrg, defaultArchiveOrg) ||
                other.defaultArchiveOrg == defaultArchiveOrg) &&
            (identical(other.archiveOrgS3AccessKey, archiveOrgS3AccessKey) ||
                other.archiveOrgS3AccessKey == archiveOrgS3AccessKey) &&
            (identical(other.archiveOrgS3SecretKey, archiveOrgS3SecretKey) ||
                other.archiveOrgS3SecretKey == archiveOrgS3SecretKey));
  }

  @override
  int get hashCode => Object.hash(runtimeType, defaultArchiveIs,
      defaultArchiveOrg, archiveOrgS3AccessKey, archiveOrgS3SecretKey);

  @override
  String toString() {
    return 'ArchiveSettings(defaultArchiveIs: $defaultArchiveIs, defaultArchiveOrg: $defaultArchiveOrg, archiveOrgS3AccessKey: $archiveOrgS3AccessKey, archiveOrgS3SecretKey: $archiveOrgS3SecretKey)';
  }
}

/// @nodoc
abstract mixin class _$ArchiveSettingsCopyWith<$Res>
    implements $ArchiveSettingsCopyWith<$Res> {
  factory _$ArchiveSettingsCopyWith(
          _ArchiveSettings value, $Res Function(_ArchiveSettings) _then) =
      __$ArchiveSettingsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool defaultArchiveIs,
      bool defaultArchiveOrg,
      String? archiveOrgS3AccessKey,
      String? archiveOrgS3SecretKey});
}

/// @nodoc
class __$ArchiveSettingsCopyWithImpl<$Res>
    implements _$ArchiveSettingsCopyWith<$Res> {
  __$ArchiveSettingsCopyWithImpl(this._self, this._then);

  final _ArchiveSettings _self;
  final $Res Function(_ArchiveSettings) _then;

  /// Create a copy of ArchiveSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? defaultArchiveIs = null,
    Object? defaultArchiveOrg = null,
    Object? archiveOrgS3AccessKey = freezed,
    Object? archiveOrgS3SecretKey = freezed,
  }) {
    return _then(_ArchiveSettings(
      defaultArchiveIs: null == defaultArchiveIs
          ? _self.defaultArchiveIs
          : defaultArchiveIs // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultArchiveOrg: null == defaultArchiveOrg
          ? _self.defaultArchiveOrg
          : defaultArchiveOrg // ignore: cast_nullable_to_non_nullable
              as bool,
      archiveOrgS3AccessKey: freezed == archiveOrgS3AccessKey
          ? _self.archiveOrgS3AccessKey
          : archiveOrgS3AccessKey // ignore: cast_nullable_to_non_nullable
              as String?,
      archiveOrgS3SecretKey: freezed == archiveOrgS3SecretKey
          ? _self.archiveOrgS3SecretKey
          : archiveOrgS3SecretKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
