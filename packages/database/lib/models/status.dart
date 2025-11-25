/// Utility class that simplifies handling errors.
///
/// Return a [Result] from a function to indicate success or failure.
///
/// A [Result] is either an [Ok] with a value of type [T]
/// or an [Error] with an [Exception].
///
/// Use [Result.ok] to create a successful result with a value of type [T].
/// Use [Result.error] to create an error result with an [Exception].
sealed class Status<T> {
  const Status();

  /// Creates an instance of Status containing a value
  factory Status.ok(T value) => Ok(value);

  /// Create an instance of Status containing an error
  factory Status.error(Exception error) => Error(error);
}

/// Subclass of Status for values
final class Ok<T> extends Status<T> {
  const Ok(this.value);

  /// Returned value in result
  final T value;
}

/// Subclass of Result for errors
final class Error<T> extends Status<T> {
  const Error(this.error);

  /// Returned error in result
  final Exception error;
}


