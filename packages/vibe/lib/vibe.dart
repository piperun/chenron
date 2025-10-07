// Re-export vibe_core for convenience
export 'package:vibe_core/vibe_core.dart';

// Vibe-specific exports
export 'package:vibe/src/builders/flex_builders.dart';
export 'package:vibe/src/controller.dart';
export 'package:vibe/src/specs/flex_theme_spec.dart';
export 'package:vibe/src/themes/index.dart';

// Export only non-conflicting types from vibe's old types.dart
export 'package:vibe/src/types.dart' show ThemeModePref, ThemeColors;
