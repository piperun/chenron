import "package:chenron/shared/themes/nier/_archived/nier_colors.dart";
import "package:chenron/features/theme/model/_archived/app_theme.dart";
import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

/// The [NierTheme] defines light and dark themes for the app,
/// inspired by the NieR: Automata UI.
///
final class NierTheme extends BaseAppTheme {
  @override
  String get key => "nier";

  static const String _name = "Nier";
  @override
  String get name => _name;

  @override
  String get description => "Color scheme based on Nier: Automata UI";

  // ───────────────────────── Scheme data ─────────────────────────
  static final FlexSchemeData _nierScheme = FlexSchemeData(
    name: _name,
    description: "Color scheme based on Nier: Automata UI",
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

  @override
  FlexSchemeData get schemeData => _nierScheme;

  // Expose semantic colours for backward compatibility
  static FlexSchemeColor get light => _nierScheme.light;
  static FlexSchemeColor get dark => _nierScheme.dark;

  static final FlexSubThemesData _subThemeData = FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    blendOnColors: true,
    useM2StyleDividerInM3: true,
    inputDecoratorIsFilled: true,
    inputDecoratorBackgroundAlpha: 20,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    outlinedButtonSchemeColor: SchemeColor.secondary,
    outlinedButtonOutlineSchemeColor: SchemeColor.tertiary,
    listTileTileSchemeColor: SchemeColor.tertiary,
    searchBarBackgroundSchemeColor: SchemeColor.tertiary,
    alignedDropdown: true,
    navigationRailUseIndicator: true,
    navigationRailSelectedLabelSchemeColor: SchemeColor.secondary,
    navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
    navigationRailSelectedIconSchemeColor: SchemeColor.surface,
    navigationRailUnselectedIconSchemeColor: SchemeColor.onSurfaceVariant,
    navigationRailIndicatorSchemeColor: SchemeColor.secondary,
    // Do not force label type; allow app state (extended) to control labels
    searchBarShadowColor: NierColors.yorha.outlineGrey,
    // Let scaffoldBackground (from the ThemeData) control the page background
  );

  @override
  FlexSubThemesData get subThemeData => _subThemeData;

  @override
  ThemeData get lightTheme {
    final base = super.lightTheme;
    return base.copyWith(
      scaffoldBackgroundColor: NierColors.yorha.canvasBeige,
      cardColor: NierColors.yorha.surfaceOffWhite,
      cardTheme: CardThemeData(color: NierColors.yorha.surfaceOffWhite),
      colorScheme: base.colorScheme.copyWith(
        surface: NierColors.yorha.canvasBeige,
        surfaceContainerLow: NierColors.yorha.surfaceOffWhite,
        surfaceContainer: NierColors.yorha.surfaceOffWhite,
      ),
    );
  }

  @override
  ThemeData get darkTheme {
    return FlexThemeData.dark(
      colors: darkColors,
      surfaceMode: FlexSurfaceMode.level,
      blendLevel: 15,
      subThemesData: subThemeData,
      surface: NierColors.yorha.textBrownGrey,
      dialogBackground: NierColors.yorha.textBrownDarker,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    );
  }

  // Static getters for backward compatibility
  static ThemeData get staticLightTheme => NierTheme().lightTheme;
  static ThemeData get staticDarkTheme => NierTheme().darkTheme;
}

