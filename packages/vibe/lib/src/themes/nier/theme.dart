import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show CardThemeData, DialogThemeData, ThemeData;
import 'package:vibe/src/themes/nier/colors.dart';
import 'package:vibe/src/types.dart';

/// Build Nier theme variants using FlexSchemeColor for light/dark
ThemeVariants buildNierTheme(
    {FlexSubThemesData? subThemes, bool useMaterial3 = true}) {
  final FlexSubThemesData sub = subThemes ??
      FlexSubThemesData(
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
        navigationRailSelectedIconSchemeColor: SchemeColor.primary,
        navigationRailUnselectedIconSchemeColor: SchemeColor.onSurfaceVariant,
        navigationRailIndicatorSchemeColor: SchemeColor.secondary,
        navigationRailBackgroundSchemeColor: SchemeColor.primary,
        searchBarShadowColor: NierColors.yorha.outlineGrey,
        scaffoldBackgroundSchemeColor: SchemeColor.primary,
        textButtonSchemeColor: SchemeColor.tertiary,
        appBarBackgroundSchemeColor: SchemeColor.primary,
        elevatedButtonSchemeColor: SchemeColor.tertiary,
        filledButtonSchemeColor: SchemeColor.secondary,
      );

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

// Build light theme and apply legacy card background
  final ThemeData light = FlexColorScheme.light(
    colors: scheme.light,
    surfaceMode: FlexSurfaceMode.level,
    blendLevel: 8,
    subThemesData: sub,
    useMaterial3: useMaterial3,
  ).toTheme.copyWith(
        cardTheme: CardThemeData(color: NierColors.yorha.surfaceOffWhite),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
      );

  // Build dark theme with legacy tweaks
  final ThemeData darkBase = FlexColorScheme.dark(
    colors: scheme.dark,
    surfaceMode: FlexSurfaceMode.level,
    blendLevel: 15,
    subThemesData: sub,
    useMaterial3: useMaterial3,
  ).toTheme;

  final ThemeData dark = darkBase.copyWith(
    // Adjust surface tone and dialog background to match legacy
    colorScheme: darkBase.colorScheme.copyWith(
      surface: NierColors.yorha.textBrownGrey,
    ),
    dialogTheme:
        DialogThemeData(backgroundColor: NierColors.yorha.textBrownDarker),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  return (
    light: light,
    dark: dark,
  );
}
