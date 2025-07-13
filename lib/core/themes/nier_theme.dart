import "package:chenron/core/themes/nier_colors.dart";
import "package:chenron/core/theme/model/app_theme.dart";
import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

/// The [NierTheme] defines light and dark themes for the app,
/// inspired by the NieR: Automata UI.
///
abstract final class NierTheme implements BaseAppTheme {
  @override
  String get key => "nier";

  static const String _name = "Nier";
  @override
  String get name => _name;
  static const String description = "Color scheme based on Nier: Automata UI";

  // ───────────────────────── Scheme data ─────────────────────────
  // Keep this as static final, it's just color definitions
  static final FlexSchemeData _nierScheme = FlexSchemeData(
    name: NierTheme._name,
    description: NierTheme.description,
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

  // Expose semantic colours (can remain static final if not changing dynamically)
  static final FlexSchemeColor light = _nierScheme.light;
  static final FlexSchemeColor dark = _nierScheme.dark;

  static final FlexSubThemesData subThemeData = FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    blendOnColors: true,
    useM2StyleDividerInM3: true,
    inputDecoratorIsFilled: true,
    inputDecoratorBackgroundAlpha: 20,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    listTileTileSchemeColor: SchemeColor.tertiary,
    searchBarBackgroundSchemeColor: SchemeColor.tertiary,
    alignedDropdown: true,
    navigationRailUseIndicator: true,
    navigationRailSelectedLabelSchemeColor: SchemeColor.secondary,
    navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
    navigationRailSelectedIconSchemeColor: SchemeColor.surface,
    navigationRailUnselectedIconSchemeColor: SchemeColor.onSurfaceVariant,
    navigationRailIndicatorSchemeColor: SchemeColor.secondary,
    navigationRailLabelType: NavigationRailLabelType.all,
    searchBarShadowColor: NierColors.yorha.outlineGrey,
    scaffoldBackgroundSchemeColor: SchemeColor.surface,
  );

  static final lightTheme = FlexThemeData.light(
    colors: light,
    surfaceMode: FlexSurfaceMode.level,
    blendLevel: 8,
    subThemesData: subThemeData,
    surface: NierColors.yorha.canvasBeige,
    dialogBackground: NierColors.yorha.surfaceOffWhite,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  ).copyWith(
    cardTheme: CardThemeData(color: NierColors.yorha.surfaceOffWhite),
  );
  static final darkTheme = FlexThemeData.dark(
    colors: dark,
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
