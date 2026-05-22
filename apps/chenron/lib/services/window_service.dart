import "dart:ui";

import "package:shared_preferences/shared_preferences.dart";
import "package:app_logger/app_logger.dart";

const _kWindowWidthKey = "window_width";
const _kWindowHeightKey = "window_height";
const _kWindowMaximizedKey = "window_maximized";

const double _kMinWidth = 400;
const double _kMinHeight = 300;
// window_manager.getSize() on Linux/GTK occasionally returns garbage
// (huge or negative values). Reject anything outside a sane upper
// bound before persisting so a single bad reading can't poison prefs.
const double _kMaxReasonableDimension = 16384;
const double _kDefaultScreenFraction = 0.8;

bool _isSaneDimension(double v) =>
    v.isFinite && v >= _kMinHeight && v <= _kMaxReasonableDimension;

class WindowService {
  final SharedPreferences _prefs;

  WindowService(this._prefs);

  Size? getSavedWindowSize() {
    final w = _prefs.getDouble(_kWindowWidthKey);
    final h = _prefs.getDouble(_kWindowHeightKey);
    if (w == null || h == null) return null;
    if (!_isSaneDimension(w) || !_isSaneDimension(h)) {
      loggerGlobal.warning(
          "WindowService", "Discarding insane saved size: ${w}x$h");
      return null;
    }
    return Size(w, h);
  }

  bool getSavedMaximized() => _prefs.getBool(_kWindowMaximizedKey) ?? false;

  Future<void> saveWindowSize(Size size) async {
    if (!_isSaneDimension(size.width) || !_isSaneDimension(size.height)) {
      loggerGlobal.warning("WindowService",
          "Refusing to save insane size: ${size.width}x${size.height}");
      return;
    }
    await _prefs.setDouble(_kWindowWidthKey, size.width);
    await _prefs.setDouble(_kWindowHeightKey, size.height);
    loggerGlobal.fine(
        "WindowService", "Saved window size: ${size.width}x${size.height}");
  }

  Future<void> saveMaximized({required bool maximized}) async {
    await _prefs.setBool(_kWindowMaximizedKey, maximized);
  }

  /// Computes the target window size based on saved preferences and screen.
  ///
  /// If a saved size exists, it is clamped to `[minWidth..screenWidth]` and
  /// `[minHeight..screenHeight]`. Otherwise returns 80% of screen size.
  static Size computeTargetSize({
    required Size? savedSize,
    required Size screenSize,
  }) {
    if (savedSize != null) {
      return Size(
        savedSize.width.clamp(_kMinWidth, screenSize.width),
        savedSize.height.clamp(_kMinHeight, screenSize.height),
      );
    }
    return Size(
      screenSize.width * _kDefaultScreenFraction,
      screenSize.height * _kDefaultScreenFraction,
    );
  }
}
