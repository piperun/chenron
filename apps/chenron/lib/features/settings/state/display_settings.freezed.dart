// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'display_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisplaySettings {
  int get timeDisplayFormat;
  int get itemClickAction;
  String? get cacheDirectory;
  bool get showDescription;
  bool get showImages;
  bool get showTags;
  bool get showCopyLink;

  /// Create a copy of DisplaySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DisplaySettingsCopyWith<DisplaySettings> get copyWith =>
      _$DisplaySettingsCopyWithImpl<DisplaySettings>(
          this as DisplaySettings, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DisplaySettings &&
            (identical(other.timeDisplayFormat, timeDisplayFormat) ||
                other.timeDisplayFormat == timeDisplayFormat) &&
            (identical(other.itemClickAction, itemClickAction) ||
                other.itemClickAction == itemClickAction) &&
            (identical(other.cacheDirectory, cacheDirectory) ||
                other.cacheDirectory == cacheDirectory) &&
            (identical(other.showDescription, showDescription) ||
                other.showDescription == showDescription) &&
            (identical(other.showImages, showImages) ||
                other.showImages == showImages) &&
            (identical(other.showTags, showTags) ||
                other.showTags == showTags) &&
            (identical(other.showCopyLink, showCopyLink) ||
                other.showCopyLink == showCopyLink));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      timeDisplayFormat,
      itemClickAction,
      cacheDirectory,
      showDescription,
      showImages,
      showTags,
      showCopyLink);

  @override
  String toString() {
    return 'DisplaySettings(timeDisplayFormat: $timeDisplayFormat, itemClickAction: $itemClickAction, cacheDirectory: $cacheDirectory, showDescription: $showDescription, showImages: $showImages, showTags: $showTags, showCopyLink: $showCopyLink)';
  }
}

/// @nodoc
abstract mixin class $DisplaySettingsCopyWith<$Res> {
  factory $DisplaySettingsCopyWith(
          DisplaySettings value, $Res Function(DisplaySettings) _then) =
      _$DisplaySettingsCopyWithImpl;
  @useResult
  $Res call(
      {int timeDisplayFormat,
      int itemClickAction,
      String? cacheDirectory,
      bool showDescription,
      bool showImages,
      bool showTags,
      bool showCopyLink});
}

/// @nodoc
class _$DisplaySettingsCopyWithImpl<$Res>
    implements $DisplaySettingsCopyWith<$Res> {
  _$DisplaySettingsCopyWithImpl(this._self, this._then);

  final DisplaySettings _self;
  final $Res Function(DisplaySettings) _then;

  /// Create a copy of DisplaySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timeDisplayFormat = null,
    Object? itemClickAction = null,
    Object? cacheDirectory = freezed,
    Object? showDescription = null,
    Object? showImages = null,
    Object? showTags = null,
    Object? showCopyLink = null,
  }) {
    return _then(_self.copyWith(
      timeDisplayFormat: null == timeDisplayFormat
          ? _self.timeDisplayFormat
          : timeDisplayFormat // ignore: cast_nullable_to_non_nullable
              as int,
      itemClickAction: null == itemClickAction
          ? _self.itemClickAction
          : itemClickAction // ignore: cast_nullable_to_non_nullable
              as int,
      cacheDirectory: freezed == cacheDirectory
          ? _self.cacheDirectory
          : cacheDirectory // ignore: cast_nullable_to_non_nullable
              as String?,
      showDescription: null == showDescription
          ? _self.showDescription
          : showDescription // ignore: cast_nullable_to_non_nullable
              as bool,
      showImages: null == showImages
          ? _self.showImages
          : showImages // ignore: cast_nullable_to_non_nullable
              as bool,
      showTags: null == showTags
          ? _self.showTags
          : showTags // ignore: cast_nullable_to_non_nullable
              as bool,
      showCopyLink: null == showCopyLink
          ? _self.showCopyLink
          : showCopyLink // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [DisplaySettings].
extension DisplaySettingsPatterns on DisplaySettings {
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
    TResult Function(_DisplaySettings value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DisplaySettings() when $default != null:
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
    TResult Function(_DisplaySettings value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DisplaySettings():
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
    TResult? Function(_DisplaySettings value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DisplaySettings() when $default != null:
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
            int timeDisplayFormat,
            int itemClickAction,
            String? cacheDirectory,
            bool showDescription,
            bool showImages,
            bool showTags,
            bool showCopyLink)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DisplaySettings() when $default != null:
        return $default(
            _that.timeDisplayFormat,
            _that.itemClickAction,
            _that.cacheDirectory,
            _that.showDescription,
            _that.showImages,
            _that.showTags,
            _that.showCopyLink);
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
            int timeDisplayFormat,
            int itemClickAction,
            String? cacheDirectory,
            bool showDescription,
            bool showImages,
            bool showTags,
            bool showCopyLink)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DisplaySettings():
        return $default(
            _that.timeDisplayFormat,
            _that.itemClickAction,
            _that.cacheDirectory,
            _that.showDescription,
            _that.showImages,
            _that.showTags,
            _that.showCopyLink);
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
            int timeDisplayFormat,
            int itemClickAction,
            String? cacheDirectory,
            bool showDescription,
            bool showImages,
            bool showTags,
            bool showCopyLink)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DisplaySettings() when $default != null:
        return $default(
            _that.timeDisplayFormat,
            _that.itemClickAction,
            _that.cacheDirectory,
            _that.showDescription,
            _that.showImages,
            _that.showTags,
            _that.showCopyLink);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DisplaySettings implements DisplaySettings {
  const _DisplaySettings(
      {this.timeDisplayFormat = 0,
      this.itemClickAction = 0,
      this.cacheDirectory,
      this.showDescription = true,
      this.showImages = true,
      this.showTags = true,
      this.showCopyLink = true});

  @override
  @JsonKey()
  final int timeDisplayFormat;
  @override
  @JsonKey()
  final int itemClickAction;
  @override
  final String? cacheDirectory;
  @override
  @JsonKey()
  final bool showDescription;
  @override
  @JsonKey()
  final bool showImages;
  @override
  @JsonKey()
  final bool showTags;
  @override
  @JsonKey()
  final bool showCopyLink;

  /// Create a copy of DisplaySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DisplaySettingsCopyWith<_DisplaySettings> get copyWith =>
      __$DisplaySettingsCopyWithImpl<_DisplaySettings>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DisplaySettings &&
            (identical(other.timeDisplayFormat, timeDisplayFormat) ||
                other.timeDisplayFormat == timeDisplayFormat) &&
            (identical(other.itemClickAction, itemClickAction) ||
                other.itemClickAction == itemClickAction) &&
            (identical(other.cacheDirectory, cacheDirectory) ||
                other.cacheDirectory == cacheDirectory) &&
            (identical(other.showDescription, showDescription) ||
                other.showDescription == showDescription) &&
            (identical(other.showImages, showImages) ||
                other.showImages == showImages) &&
            (identical(other.showTags, showTags) ||
                other.showTags == showTags) &&
            (identical(other.showCopyLink, showCopyLink) ||
                other.showCopyLink == showCopyLink));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      timeDisplayFormat,
      itemClickAction,
      cacheDirectory,
      showDescription,
      showImages,
      showTags,
      showCopyLink);

  @override
  String toString() {
    return 'DisplaySettings(timeDisplayFormat: $timeDisplayFormat, itemClickAction: $itemClickAction, cacheDirectory: $cacheDirectory, showDescription: $showDescription, showImages: $showImages, showTags: $showTags, showCopyLink: $showCopyLink)';
  }
}

/// @nodoc
abstract mixin class _$DisplaySettingsCopyWith<$Res>
    implements $DisplaySettingsCopyWith<$Res> {
  factory _$DisplaySettingsCopyWith(
          _DisplaySettings value, $Res Function(_DisplaySettings) _then) =
      __$DisplaySettingsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int timeDisplayFormat,
      int itemClickAction,
      String? cacheDirectory,
      bool showDescription,
      bool showImages,
      bool showTags,
      bool showCopyLink});
}

/// @nodoc
class __$DisplaySettingsCopyWithImpl<$Res>
    implements _$DisplaySettingsCopyWith<$Res> {
  __$DisplaySettingsCopyWithImpl(this._self, this._then);

  final _DisplaySettings _self;
  final $Res Function(_DisplaySettings) _then;

  /// Create a copy of DisplaySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? timeDisplayFormat = null,
    Object? itemClickAction = null,
    Object? cacheDirectory = freezed,
    Object? showDescription = null,
    Object? showImages = null,
    Object? showTags = null,
    Object? showCopyLink = null,
  }) {
    return _then(_DisplaySettings(
      timeDisplayFormat: null == timeDisplayFormat
          ? _self.timeDisplayFormat
          : timeDisplayFormat // ignore: cast_nullable_to_non_nullable
              as int,
      itemClickAction: null == itemClickAction
          ? _self.itemClickAction
          : itemClickAction // ignore: cast_nullable_to_non_nullable
              as int,
      cacheDirectory: freezed == cacheDirectory
          ? _self.cacheDirectory
          : cacheDirectory // ignore: cast_nullable_to_non_nullable
              as String?,
      showDescription: null == showDescription
          ? _self.showDescription
          : showDescription // ignore: cast_nullable_to_non_nullable
              as bool,
      showImages: null == showImages
          ? _self.showImages
          : showImages // ignore: cast_nullable_to_non_nullable
              as bool,
      showTags: null == showTags
          ? _self.showTags
          : showTags // ignore: cast_nullable_to_non_nullable
              as bool,
      showCopyLink: null == showCopyLink
          ? _self.showCopyLink
          : showCopyLink // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
