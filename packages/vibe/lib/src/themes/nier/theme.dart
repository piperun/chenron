import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:vibe/src/flex/flex_theme.dart';
import 'package:vibe/src/theme.dart';
import 'package:vibe/src/themes/nier/palette.dart';

/// Nier: Automata themed implementation (Tier 4 — full control).
///
/// Uses Material-correct mapping where `primary` is the interactive
/// accent color and backgrounds are set explicitly via `build()`.
///
/// Light: primary = brown (interactive), backgrounds = beige
/// Dark:  primary = beige (interactive), backgrounds = brown
class NierTheme extends FlexVibeTheme {
  @override
  String get id => 'nier';

  @override
  String get name => 'Nier: Automata';

  @override
  FlexSchemeColor get lightColors => FlexSchemeColor(
        primary: NierColors.yorha.textBrownGrey,
        primaryContainer: NierColors.yorha.textBrownDarker,
        secondary: NierColors.yorha.outlineGrey,
        secondaryContainer: NierColors.yorha.gridLineBeige,
        tertiary: NierColors.yorha.textBrownDarkOutline,
        tertiaryContainer: NierColors.yorha.outlineGrey,
        error: NierColors.yorha.hudRed,
        errorContainer: NierColors.yorha.hudTeal,
      );

  @override
  FlexSchemeColor get darkColors => FlexSchemeColor(
        primary: NierColors.yorha.canvasBeige,
        primaryContainer: NierColors.yorha.surfaceOffWhite,
        secondary: NierColors.yorha.outlineGrey,
        secondaryContainer: NierColors.yorha.gridLineBeige,
        tertiary: NierColors.yorha.textBrownDarkOutline,
        tertiaryContainer: NierColors.yorha.outlineGrey,
        error: NierColors.yorha.hudRed,
        errorContainer: NierColors.yorha.hudTeal,
      );

  @override
  FlexSubThemesData get subThemes => const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        blendOnColors: true,
        useM2StyleDividerInM3: true,
        inputDecoratorIsFilled: true,
        inputDecoratorBackgroundAlpha: 20,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        outlinedButtonSchemeColor: SchemeColor.primary,
        outlinedButtonOutlineSchemeColor: SchemeColor.secondary,
        alignedDropdown: true,
        navigationRailUseIndicator: true,
        navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
        navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
        navigationRailSelectedIconSchemeColor: SchemeColor.primary,
        navigationRailUnselectedIconSchemeColor: SchemeColor.onSurfaceVariant,
        navigationRailIndicatorSchemeColor: SchemeColor.secondary,
        textButtonSchemeColor: SchemeColor.primary,
        elevatedButtonSchemeColor: SchemeColor.primary,
        filledButtonSchemeColor: SchemeColor.primary,
      );

  @override
  ThemeVariants build() {
    final ThemeVariants base = super.build();

    return (
      light: base.light.copyWith(
        textTheme: base.light.textTheme.apply(
          bodyColor: NierColors.yorha.textBrownGrey,
          displayColor: NierColors.yorha.textBrownGrey,
        ),
        scaffoldBackgroundColor: NierColors.yorha.canvasBeige,
        colorScheme: base.light.colorScheme.copyWith(
          surface: NierColors.yorha.canvasBeige,
          surfaceContainerLowest: NierColors.yorha.surfaceOffWhite,
          surfaceContainerLow: NierColors.yorha.surfaceOffWhite,
          surfaceContainer: NierColors.yorha.surfaceOffWhite,
          surfaceContainerHigh: NierColors.yorha.gridLineBeige,
          surfaceContainerHighest: NierColors.yorha.gridLineBeige,
          onSurface: NierColors.yorha.textBrownGrey,
          onSurfaceVariant: NierColors.yorha.textBrownDarkOutline,
          onPrimaryContainer: NierColors.yorha.canvasBeige,
          onSecondaryContainer: NierColors.yorha.textBrownGrey,
          onTertiaryContainer: NierColors.yorha.textBrownGrey,
          outline: NierColors.yorha.outlineGrey,
          outlineVariant: NierColors.yorha.gridLineBeige,
        ),
        cardColor: NierColors.yorha.surfaceOffWhite,
        cardTheme: CardThemeData(color: NierColors.yorha.surfaceOffWhite),
        inputDecorationTheme: base.light.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: NierColors.yorha.surfaceOffWhite,
        ),
        appBarTheme: base.light.appBarTheme.copyWith(
          backgroundColor: NierColors.yorha.canvasBeige,
          foregroundColor: NierColors.yorha.textBrownGrey,
        ),
        navigationRailTheme: base.light.navigationRailTheme.copyWith(
          backgroundColor: NierColors.yorha.canvasBeige,
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: TextStyle(color: NierColors.yorha.textBrownGrey),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: NierColors.yorha.canvasBeige,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: NierColors.yorha.outlineGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: NierColors.yorha.outlineGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: NierColors.yorha.textBrownGrey, width: 2),
            ),
          ),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
                NierColors.yorha.surfaceOffWhite),
          ),
        ),
        searchBarTheme: SearchBarThemeData(
          backgroundColor:
              WidgetStatePropertyAll<Color>(NierColors.yorha.surfaceOffWhite),
          shadowColor:
              WidgetStatePropertyAll<Color>(NierColors.yorha.outlineGrey),
          textStyle: WidgetStatePropertyAll<TextStyle>(
            TextStyle(color: NierColors.yorha.textBrownGrey),
          ),
          hintStyle: WidgetStatePropertyAll<TextStyle>(
            TextStyle(
              color: NierColors.yorha.textBrownDarkOutline
                  .withValues(alpha: 0.6),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: NierColors.yorha.textBrownGrey,
            foregroundColor: NierColors.yorha.canvasBeige,
          ),
        ),
      ),
      dark: base.dark.copyWith(
        textTheme: base.dark.textTheme.apply(
          bodyColor: NierColors.yorha.canvasBeige,
          displayColor: NierColors.yorha.canvasBeige,
        ),
        scaffoldBackgroundColor: NierColors.yorha.textBrownGrey,
        colorScheme: base.dark.colorScheme.copyWith(
          surface: NierColors.yorha.textBrownGrey,
          surfaceContainerLowest: NierColors.yorha.textBrownDarker,
          surfaceContainerLow: NierColors.yorha.textBrownDarker,
          surfaceContainer: NierColors.yorha.textBrownDarker,
          surfaceContainerHigh: NierColors.yorha.textBrownDarkOutline,
          surfaceContainerHighest: NierColors.yorha.textBrownDarkOutline,
          onSurface: NierColors.yorha.canvasBeige,
          onSurfaceVariant: NierColors.yorha.outlineGrey,
          onPrimaryContainer: NierColors.yorha.textBrownGrey,
          onSecondaryContainer: NierColors.yorha.textBrownGrey,
          onTertiaryContainer: NierColors.yorha.textBrownGrey,
          outline: NierColors.yorha.textBrownDarkOutline,
          outlineVariant: NierColors.yorha.textBrownDarker,
        ),
        cardColor: NierColors.yorha.textBrownDarker,
        cardTheme: CardThemeData(color: NierColors.yorha.textBrownDarker),
        inputDecorationTheme: base.dark.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: NierColors.yorha.textBrownDarker,
        ),
        appBarTheme: base.dark.appBarTheme.copyWith(
          backgroundColor: NierColors.yorha.textBrownGrey,
          foregroundColor: NierColors.yorha.canvasBeige,
        ),
        navigationRailTheme: base.dark.navigationRailTheme.copyWith(
          backgroundColor: NierColors.yorha.textBrownGrey,
        ),
        dialogTheme:
            DialogThemeData(backgroundColor: NierColors.yorha.textBrownDarker),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: TextStyle(color: NierColors.yorha.canvasBeige),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: NierColors.yorha.textBrownDarker,
            border: OutlineInputBorder(
              borderSide:
                  BorderSide(color: NierColors.yorha.textBrownDarkOutline),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: NierColors.yorha.textBrownDarkOutline),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: NierColors.yorha.canvasBeige, width: 2),
            ),
          ),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
                NierColors.yorha.textBrownDarker),
          ),
        ),
        searchBarTheme: SearchBarThemeData(
          backgroundColor:
              WidgetStatePropertyAll<Color>(NierColors.yorha.textBrownDarker),
          shadowColor: WidgetStatePropertyAll<Color>(
              NierColors.yorha.textBrownDarkOutline),
          textStyle: WidgetStatePropertyAll<TextStyle>(
            TextStyle(color: NierColors.yorha.canvasBeige),
          ),
          hintStyle: WidgetStatePropertyAll<TextStyle>(
            TextStyle(
              color: NierColors.yorha.outlineGrey.withValues(alpha: 0.6),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: NierColors.yorha.canvasBeige,
            foregroundColor: NierColors.yorha.textBrownGrey,
          ),
        ),
      ),
    );
  }
}
