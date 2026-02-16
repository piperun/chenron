import "dart:ui";

import "package:shared_preferences/shared_preferences.dart";
import "package:app_logger/app_logger.dart";

const _kWindowWidthKey = "window_width";
const _kWindowHeightKey = "window_height";

const double _kMinWidth = 400;
const double _kMinHeight = 300;
const double _kDefaultScreenFraction = 0.8;

class WindowService {
  final SharedPreferences _prefs;

  WindowService(this._prefs);

  Size? getSavedWindowSize() {
    final w = _prefs.getDouble(_kWindowWidthKey);
    final h = _prefs.getDouble(_kWindowHeightKey);
    if (w == null || h == null) return null;
    return Size(w, h);
  }

  Future<void> saveWindowSize(Size size) async {
    await _prefs.setDouble(_kWindowWidthKey, size.width);
    await _prefs.setDouble(_kWindowHeightKey, size.height);
    loggerGlobal.fine(
        "WindowService", "Saved window size: ${size.width}x${size.height}");
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
