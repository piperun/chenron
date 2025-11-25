import "dart:async";

class Debouncer<T> {
  final Duration duration;
  Timer? _timer;
  Completer<void>? _completer;

  Debouncer({this.duration = const Duration(milliseconds: 500)});

  Future<T?> call(Future<T> Function() action) async {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
      _completer?.completeError(const CancelException());
    }

    _completer = Completer<void>();
    _timer = Timer(duration, () {
      _completer?.complete();
    });

    try {
      await _completer?.future;
      return await action();
    } catch (error) {
      if (error is CancelException) {
        return null;
      }
      rethrow;
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}

class CancelException implements Exception {
  const CancelException();
}

