import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:vibe/src/spec/theme_spec.dart';
import 'package:vibe/src/specs/flex_theme_spec.dart';
import 'package:vibe/src/themes/nier/colors.dart';

/// Nier: Automata themed implementation
class NierTheme extends FlexThemeSpec {
  @override
  ThemeId get id => const ThemeId('nier');

  @override
  ThemeMetadata get metadata => const ThemeMetadata(
        name: 'Nier: Automata',
        description: 'Color scheme based on Nier: Automata UI',
        author: 'YorHa',
        version: '1.0.0',
        tags: <String>['game', 'beige', 'minimal'],
      );

  @override
  FlexSchemeData get schemeData => FlexSchemeData(
        name: metadata.name,
        description: metadata.description,
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
  FlexSubThemesData get subThemes => FlexSubThemesData(
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

  @override
  ThemeVariants build() {
    final ThemeVariants base = super.build();

    // Apply Nier-specific tweaks
    return (
      light: base.light.copyWith(
        cardTheme: CardThemeData(color: NierColors.yorha.surfaceOffWhite),
        // Fix DropdownMenu to use theme colors
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: TextStyle(color: base.light.colorScheme.secondary),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: base.light.colorScheme.primary,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: base.light.colorScheme.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: base.light.colorScheme.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: base.light.colorScheme.primary, width: 2),
            ),
          ),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
                base.light.colorScheme.primaryContainer),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: base.light.colorScheme.secondary,
            foregroundColor: base.light.colorScheme.primary,
          ),
        ),
      ),
      dark: base.dark.copyWith(
        colorScheme: base.dark.colorScheme.copyWith(
          surface: NierColors.yorha.textBrownGrey,
        ),
        dialogTheme:
            DialogThemeData(backgroundColor: NierColors.yorha.textBrownDarker),
        // Fix DropdownMenu to use theme colors
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: TextStyle(
            color: base.dark.colorScheme.onSurface,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: NierColors.yorha.textBrownDarker,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: base.dark.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: base.dark.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: base.dark.colorScheme.primary, width: 2),
            ),
          ),
          menuStyle: MenuStyle(
            backgroundColor:
                WidgetStatePropertyAll<Color>(NierColors.yorha.textBrownDarker),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: base.light.colorScheme.primary,
            foregroundColor: base.light.colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}

/// Legacy builder function for backward compatibility
/// @Deprecated('Use NierTheme() instead')
ThemeVariants buildNierTheme({
  FlexSubThemesData? subThemes,
  bool useMaterial3 = true,
}) {
  return NierTheme().build();
}
