// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'validation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ValidationError {
  ValidationErrorType get type;
  String get message;
  int? get startIndex;
  int? get endIndex;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ValidationErrorCopyWith<ValidationError> get copyWith =>
      _$ValidationErrorCopyWithImpl<ValidationError>(
          this as ValidationError, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ValidationError &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.startIndex, startIndex) ||
                other.startIndex == startIndex) &&
            (identical(other.endIndex, endIndex) ||
                other.endIndex == endIndex));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, type, message, startIndex, endIndex);
}

/// @nodoc
abstract mixin class $ValidationErrorCopyWith<$Res> {
  factory $ValidationErrorCopyWith(
          ValidationError value, $Res Function(ValidationError) _then) =
      _$ValidationErrorCopyWithImpl;
  @useResult
  $Res call(
      {ValidationErrorType type,
      String message,
      int? startIndex,
      int? endIndex});
}

/// @nodoc
class _$ValidationErrorCopyWithImpl<$Res>
    implements $ValidationErrorCopyWith<$Res> {
  _$ValidationErrorCopyWithImpl(this._self, this._then);

  final ValidationError _self;
  final $Res Function(ValidationError) _then;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? message = null,
    Object? startIndex = freezed,
    Object? endIndex = freezed,
  }) {
    return _then(_self.copyWith(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as ValidationErrorType,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      startIndex: freezed == startIndex
          ? _self.startIndex
          : startIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      endIndex: freezed == endIndex
          ? _self.endIndex
          : endIndex // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ValidationError].
extension ValidationErrorPatterns on ValidationError {
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
    TResult Function(_ValidationError value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ValidationError() when $default != null:
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
    TResult Function(_ValidationError value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ValidationError():
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
    TResult? Function(_ValidationError value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ValidationError() when $default != null:
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
    TResult Function(ValidationErrorType type, String message, int? startIndex,
            int? endIndex)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ValidationError() when $default != null:
        return $default(
            _that.type, _that.message, _that.startIndex, _that.endIndex);
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
    TResult Function(ValidationErrorType type, String message, int? startIndex,
            int? endIndex)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ValidationError():
        return $default(
            _that.type, _that.message, _that.startIndex, _that.endIndex);
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
    TResult? Function(ValidationErrorType type, String message, int? startIndex,
            int? endIndex)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ValidationError() when $default != null:
        return $default(
            _that.type, _that.message, _that.startIndex, _that.endIndex);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ValidationError extends ValidationError {
  const _ValidationError(
      {required this.type,
      required this.message,
      this.startIndex,
      this.endIndex})
      : super._();

  @override
  final ValidationErrorType type;
  @override
  final String message;
  @override
  final int? startIndex;
  @override
  final int? endIndex;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ValidationErrorCopyWith<_ValidationError> get copyWith =>
      __$ValidationErrorCopyWithImpl<_ValidationError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ValidationError &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.startIndex, startIndex) ||
                other.startIndex == startIndex) &&
            (identical(other.endIndex, endIndex) ||
                other.endIndex == endIndex));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, type, message, startIndex, endIndex);
}

/// @nodoc
abstract mixin class _$ValidationErrorCopyWith<$Res>
    implements $ValidationErrorCopyWith<$Res> {
  factory _$ValidationErrorCopyWith(
          _ValidationError value, $Res Function(_ValidationError) _then) =
      __$ValidationErrorCopyWithImpl;
  @override
  @useResult
  $Res call(
      {ValidationErrorType type,
      String message,
      int? startIndex,
      int? endIndex});
}

/// @nodoc
class __$ValidationErrorCopyWithImpl<$Res>
    implements _$ValidationErrorCopyWith<$Res> {
  __$ValidationErrorCopyWithImpl(this._self, this._then);

  final _ValidationError _self;
  final $Res Function(_ValidationError) _then;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? type = null,
    Object? message = null,
    Object? startIndex = freezed,
    Object? endIndex = freezed,
  }) {
    return _then(_ValidationError(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as ValidationErrorType,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      startIndex: freezed == startIndex
          ? _self.startIndex
          : startIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      endIndex: freezed == endIndex
          ? _self.endIndex
          : endIndex // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
mixin _$LineValidationResult {
  int get lineNumber;
  String get rawLine;
  String? get url;
  List<String>? get tags;
  bool get isValid;
  List<ValidationError> get errors;

  /// Create a copy of LineValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LineValidationResultCopyWith<LineValidationResult> get copyWith =>
      _$LineValidationResultCopyWithImpl<LineValidationResult>(
          this as LineValidationResult, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LineValidationResult &&
            (identical(other.lineNumber, lineNumber) ||
                other.lineNumber == lineNumber) &&
            (identical(other.rawLine, rawLine) || other.rawLine == rawLine) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            const DeepCollectionEquality().equals(other.errors, errors));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      lineNumber,
      rawLine,
      url,
      const DeepCollectionEquality().hash(tags),
      isValid,
      const DeepCollectionEquality().hash(errors));
}

/// @nodoc
abstract mixin class $LineValidationResultCopyWith<$Res> {
  factory $LineValidationResultCopyWith(LineValidationResult value,
          $Res Function(LineValidationResult) _then) =
      _$LineValidationResultCopyWithImpl;
  @useResult
  $Res call(
      {int lineNumber,
      String rawLine,
      String? url,
      List<String>? tags,
      bool isValid,
      List<ValidationError> errors});
}

/// @nodoc
class _$LineValidationResultCopyWithImpl<$Res>
    implements $LineValidationResultCopyWith<$Res> {
  _$LineValidationResultCopyWithImpl(this._self, this._then);

  final LineValidationResult _self;
  final $Res Function(LineValidationResult) _then;

  /// Create a copy of LineValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lineNumber = null,
    Object? rawLine = null,
    Object? url = freezed,
    Object? tags = freezed,
    Object? isValid = null,
    Object? errors = null,
  }) {
    return _then(_self.copyWith(
      lineNumber: null == lineNumber
          ? _self.lineNumber
          : lineNumber // ignore: cast_nullable_to_non_nullable
              as int,
      rawLine: null == rawLine
          ? _self.rawLine
          : rawLine // ignore: cast_nullable_to_non_nullable
              as String,
      url: freezed == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isValid: null == isValid
          ? _self.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      errors: null == errors
          ? _self.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<ValidationError>,
    ));
  }
}

/// Adds pattern-matching-related methods to [LineValidationResult].
extension LineValidationResultPatterns on LineValidationResult {
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
    TResult Function(_LineValidationResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LineValidationResult() when $default != null:
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
    TResult Function(_LineValidationResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LineValidationResult():
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
    TResult? Function(_LineValidationResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LineValidationResult() when $default != null:
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
    TResult Function(int lineNumber, String rawLine, String? url,
            List<String>? tags, bool isValid, List<ValidationError> errors)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LineValidationResult() when $default != null:
        return $default(_that.lineNumber, _that.rawLine, _that.url, _that.tags,
            _that.isValid, _that.errors);
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
    TResult Function(int lineNumber, String rawLine, String? url,
            List<String>? tags, bool isValid, List<ValidationError> errors)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LineValidationResult():
        return $default(_that.lineNumber, _that.rawLine, _that.url, _that.tags,
            _that.isValid, _that.errors);
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
    TResult? Function(int lineNumber, String rawLine, String? url,
            List<String>? tags, bool isValid, List<ValidationError> errors)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LineValidationResult() when $default != null:
        return $default(_that.lineNumber, _that.rawLine, _that.url, _that.tags,
            _that.isValid, _that.errors);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LineValidationResult extends LineValidationResult {
  const _LineValidationResult(
      {required this.lineNumber,
      required this.rawLine,
      this.url,
      final List<String>? tags,
      required this.isValid,
      final List<ValidationError> errors = const []})
      : _tags = tags,
        _errors = errors,
        super._();

  @override
  final int lineNumber;
  @override
  final String rawLine;
  @override
  final String? url;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool isValid;
  final List<ValidationError> _errors;
  @override
  @JsonKey()
  List<ValidationError> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  /// Create a copy of LineValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LineValidationResultCopyWith<_LineValidationResult> get copyWith =>
      __$LineValidationResultCopyWithImpl<_LineValidationResult>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LineValidationResult &&
            (identical(other.lineNumber, lineNumber) ||
                other.lineNumber == lineNumber) &&
            (identical(other.rawLine, rawLine) || other.rawLine == rawLine) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      lineNumber,
      rawLine,
      url,
      const DeepCollectionEquality().hash(_tags),
      isValid,
      const DeepCollectionEquality().hash(_errors));
}

/// @nodoc
abstract mixin class _$LineValidationResultCopyWith<$Res>
    implements $LineValidationResultCopyWith<$Res> {
  factory _$LineValidationResultCopyWith(_LineValidationResult value,
          $Res Function(_LineValidationResult) _then) =
      __$LineValidationResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int lineNumber,
      String rawLine,
      String? url,
      List<String>? tags,
      bool isValid,
      List<ValidationError> errors});
}

/// @nodoc
class __$LineValidationResultCopyWithImpl<$Res>
    implements _$LineValidationResultCopyWith<$Res> {
  __$LineValidationResultCopyWithImpl(this._self, this._then);

  final _LineValidationResult _self;
  final $Res Function(_LineValidationResult) _then;

  /// Create a copy of LineValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? lineNumber = null,
    Object? rawLine = null,
    Object? url = freezed,
    Object? tags = freezed,
    Object? isValid = null,
    Object? errors = null,
  }) {
    return _then(_LineValidationResult(
      lineNumber: null == lineNumber
          ? _self.lineNumber
          : lineNumber // ignore: cast_nullable_to_non_nullable
              as int,
      rawLine: null == rawLine
          ? _self.rawLine
          : rawLine // ignore: cast_nullable_to_non_nullable
              as String,
      url: freezed == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isValid: null == isValid
          ? _self.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      errors: null == errors
          ? _self._errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<ValidationError>,
    ));
  }
}

// dart format on
