import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:database/models/item.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/unified_item.dart";

enum PreviewMode {
  card,
  list,
}

class ViewerItem extends StatelessWidget {
  final FolderItem item;
  final PreviewMode mode;
  final VoidCallback? onTap;
  final DisplayMode displayMode;

  // Override parameters (take precedence over displayMode)
  final int? titleLinesOverride;
  final int? descriptionLinesOverride;
  final int? maxTagsOverride;
  final bool? showImageOverride;
  final bool? showUrlBarOverride;

  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;
  final ValueChanged<String>? onTagFilterTap;

  const ViewerItem({
    super.key,
    required this.item,
    this.mode = PreviewMode.card,
    this.onTap,
    this.displayMode = DisplayMode.standard,
    this.titleLinesOverride,
    this.descriptionLinesOverride,
    this.maxTagsOverride,
    this.showImageOverride,
    this.showUrlBarOverride,
    this.includedTagNames = const {},
    this.excludedTagNames = const {},
    this.onTagFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final ConfigController config = locator.get<ConfigController>();

    return Watch((BuildContext context) {
      // Read config preferences (reactive via Watch)
      final bool configShowImages = config.showImages.value;
      final bool configShowDescription = config.showDescription.value;
      final bool configShowTags = config.showTags.value;

      // Resolve: explicit override > config preference > displayMode default
      final int resolvedTitleLines =
          titleLinesOverride ?? displayMode.titleLines;
      final int resolvedDescriptionLines = descriptionLinesOverride ??
          (configShowDescription ? displayMode.descriptionLines : 0);
      final int resolvedMaxTags =
          maxTagsOverride ?? (configShowTags ? displayMode.maxTags : 0);
      final bool resolvedShowImage =
          showImageOverride ?? (configShowImages && displayMode.showImage);

      return UnifiedItem(
        item: item,
        mode: mode,
        onTap: onTap,
        showImage: resolvedShowImage,
        maxTags: resolvedMaxTags,
        titleLines: resolvedTitleLines,
        descriptionLines: resolvedDescriptionLines,
        includedTagNames: includedTagNames,
        excludedTagNames: excludedTagNames,
        onTagFilterTap: onTagFilterTap,
      );
    });
  }
}

