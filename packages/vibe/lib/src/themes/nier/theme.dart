import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:vibe/src/builders/flex_builders.dart';
import 'package:vibe/src/themes/nier/colors.dart';
import 'package:vibe/src/types.dart';

/// Build Nier theme variants using FlexSchemeColor for light/dark
ThemeVariants buildNierTheme({FlexSubThemesData? subThemes, bool useMaterial3 = true}) {
  final FlexSchemeData scheme = FlexSchemeData(
    name: 'Nier',
    description: 'Color scheme based on Nier: Automata UI',
    light: FlexSchemeColor(
      primary: NierColors.yorha.canvasBeige,
      primaryContainer: NierColors.yorha.surfaceOffWhite,
      secondary: NierColors.yorha.textBrownGrey,
      secondaryContainer: NierColors.yorha.textBrownDarker,
      tertiary: NierColors.yorha.outlineGrey,
      tertiaryContainer: NierColors.yorha.textBrownGrey,
      error: NierColors.yorha.hudRed,
      errorContainer: NierColors.yorha.hudTeal,
    ),
    dark: FlexSchemeColor(
      primary: NierColors.yorha.textBrownGrey,
      primaryContainer: NierColors.yorha.textBrownDarker,
      secondary: NierColors.yorha.canvasBeige,
      secondaryContainer: NierColors.yorha.surfaceOffWhite,
      tertiary: NierColors.yorha.textBrownDarkOutline,
      tertiaryContainer: NierColors.yorha.outlineGrey,
      error: NierColors.yorha.hudRed,
      errorContainer: NierColors.yorha.hudTeal,
    ),
  );

  return buildVariantsFromFlexSchemeData(
    scheme,
    subThemes: subThemes,
    useMaterial3: useMaterial3,
  );
}
