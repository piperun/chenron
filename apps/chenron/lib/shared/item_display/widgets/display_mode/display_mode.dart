/// Display mode presets for customizing item appearance in grid and list views.
///
/// DisplayMode provides preset configurations for how items are displayed,
/// controlling the number of lines shown for title/description, tag count,
/// and visibility of images and URL bar.
///
/// **Preset Modes:**
/// - [compact]: Minimal display with reduced information
/// - [standard]: Balanced display suitable for most use cases (default)
/// - [extended]: Full display with maximum information
///
/// **Usage:**
/// ```dart
/// ViewerItem(
///   item: folderItem,
///   displayMode: DisplayMode.compact,  // Use preset
/// )
/// ```
///
/// You can also override individual properties:
/// ```dart
/// ViewerItem(
///   item: folderItem,
///   displayMode: DisplayMode.standard,
///   titleLinesOverride: 3,  // Override just the title lines
/// )
/// ```
enum DisplayMode {
  /// Compact mode: Minimal information display
  ///
  /// Configuration:
  /// - Title: 1 line
  /// - Description: 1 line
  /// - Max tags: 1
  /// - Image: Hidden
  /// - URL bar: Hidden
  ///
  /// Best for: Dense lists, mobile views, quick scanning
  compact(
    titleLines: 1,
    descriptionLines: 1,
    maxTags: 1,
    showImage: false,
    showUrlBar: false,
    maxCrossAxisExtent: 220.0,
    aspectRatio: 1.6,
  ),

  /// Standard mode: Balanced information display (default)
  ///
  /// Configuration:
  /// - Title: 2 lines
  /// - Description: 2 lines
  /// - Max tags: 3
  /// - Image: Visible
  /// - URL bar: Visible
  ///
  /// Best for: General use, balanced information density
  standard(
    titleLines: 2,
    descriptionLines: 3,
    maxTags: 3,
    showImage: true,
    showUrlBar: true,
    maxCrossAxisExtent: 320.0,
    aspectRatio: 0.72,
  ),

  /// Extended mode: Maximum information display
  ///
  /// Configuration:
  /// - Title: 2 lines
  /// - Description: 3 lines
  /// - Max tags: 5
  /// - Image: Visible
  /// - URL bar: Visible
  ///
  /// Best for: Detailed view, larger screens, focused browsing
  extended(
    titleLines: 4,
    descriptionLines: 5,
    maxTags: 100,
    showImage: true,
    showUrlBar: true,
    maxCrossAxisExtent: 380.0,
    aspectRatio: 0.65,
  );

  /// Maximum number of lines to display for the title
  final int titleLines;

  /// Maximum number of lines to display for the description
  final int descriptionLines;

  /// Maximum number of tags to display
  final int maxTags;

  /// Whether to show thumbnail/header images
  final bool showImage;

  /// Whether to show the URL bar with copy button
  final bool showUrlBar;

  /// Maximum width for grid items (in logical pixels)
  final double maxCrossAxisExtent;

  /// Aspect ratio for grid items (width/height)
  final double aspectRatio;

  const DisplayMode({
    required this.titleLines,
    required this.descriptionLines,
    required this.maxTags,
    required this.showImage,
    required this.showUrlBar,
    required this.maxCrossAxisExtent,
    required this.aspectRatio,
  });
}
