import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/card_view.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/row_item.dart";

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
  });

  @override
  Widget build(BuildContext context) {
    // Resolve final values: override > displayMode default
    final resolvedTitleLines = titleLinesOverride ?? displayMode.titleLines;
    final resolvedDescriptionLines =
        descriptionLinesOverride ?? displayMode.descriptionLines;
    final resolvedMaxTags = maxTagsOverride ?? displayMode.maxTags;
    final resolvedShowImage = showImageOverride ?? displayMode.showImage;
    final resolvedShowUrlBar = showUrlBarOverride ?? displayMode.showUrlBar;

    return mode == PreviewMode.card
        ? CardItem(
            item: item,
            onTap: onTap,
            showImage: resolvedShowImage,
            maxTags: resolvedMaxTags,
            titleLines: resolvedTitleLines,
            descriptionLines: resolvedDescriptionLines,
            showUrlBar: resolvedShowUrlBar,
            includedTagNames: includedTagNames,
            excludedTagNames: excludedTagNames,
          )
        : RowItem(
            item: item,
            onTap: onTap,
            showImage: resolvedShowImage,
            maxTags: resolvedMaxTags,
            titleLines: resolvedTitleLines,
            descriptionLines: resolvedDescriptionLines,
            showUrlBar: resolvedShowUrlBar,
            includedTagNames: includedTagNames,
            excludedTagNames: excludedTagNames,
          );
  }
}

