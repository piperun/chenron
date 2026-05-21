import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:vibe/src/flex/flex_theme.dart';
import 'package:vibe/src/theme.dart';
import 'package:vibe/src/themes/button_tokens.dart';
import 'package:vibe/src/themes/chart_palette.dart';
import 'package:vibe/src/themes/frame_tokens.dart';
import 'package:vibe/src/themes/nier/minor_button.dart';
import 'package:vibe/src/themes/nier/page_frame.dart';
import 'package:vibe/src/themes/nier/palette.dart';
import 'package:vibe/src/themes/nier/super_button.dart';
import 'package:vibe/src/themes/shape_tokens.dart';
import 'package:vibe/src/themes/theme_setting.dart';
import 'package:vibe/src/themes/typography_tokens.dart';

/// Nier: Automata themed implementation (Tier 4 — full control).
///
/// Uses Material-correct mapping where `primary` is the interactive
/// accent color and backgrounds are set explicitly via `build()`.
///
/// Light: primary = brown (interactive), backgrounds = beige
/// Dark:  primary = beige (interactive), backgrounds = brown
class NierTheme extends FlexVibeTheme {
  /// SharedPreferences sub-key for the graph-paper grid overlay toggle.
  static const String optGrid = 'gridOverlay';

  /// SharedPreferences sub-key for the corner-decor (circle + hatch)
  /// toggle.
  static const String optCornerDecor = 'cornerDecor';

  @override
  String get id => 'nier';

  @override
  String get name => 'Nier: Automata';

  @override
  List<ThemeSetting<Object?>> get settings => const <ThemeSetting<Object?>>[
        BoolThemeSetting(
          key: optGrid,
          label: 'Grid overlay',
          description: 'Fine graph-paper wash behind page content',
          defaultValue: true,
        ),
        BoolThemeSetting(
          key: optCornerDecor,
          label: 'Corner decor',
          description: 'Faded YorHa circle + diagonal hatching motif',
          defaultValue: true,
        ),
      ];

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
  ThemeVariants build([
    Map<String, Object?> options = const <String, Object?>{},
  ]) {
    final bool showGrid = options[optGrid] as bool? ?? true;
    final bool showCorner = options[optCornerDecor] as bool? ?? true;
    final ThemeVariants base = super.build();

    return (
      light: base.light.copyWith(
        // Attach the YorHa-derived ChartPalette so statistics charts
        // render in Nier hues (rust / dark-brown / outline-grey / teal)
        // instead of falling back to vivid Material defaults.
        extensions: <ThemeExtension<dynamic>>[
          ChartPalette.nier,
          ShapeTokens.nier,
          TypographyTokens.nier,
          FrameTokens(
            wrap: (Widget child) => NierPageFrame(
              showGrid: showGrid,
              showCorner: showCorner,
              child: child,
            ),
          ),
          ButtonTokens(
            buildMinor: ({
              required String label,
              required VoidCallback? onPressed,
              IconData? icon,
              bool destructive = false,
              bool selected = false,
            }) =>
                NierMinorButton(
                  label: label,
                  onPressed: onPressed,
                  icon: icon,
                  destructive: destructive,
                  selected: selected,
                ),
            buildSuper: ({
              required String label,
              required VoidCallback? onPressed,
              IconData? icon,
              bool destructive = false,
              bool selected = false,
            }) =>
                NierSuperButton(
                  label: label,
                  onPressed: onPressed,
                  icon: icon,
                  destructive: destructive,
                  selected: selected,
                ),
          ),
        ],
        // ThemeData.hoverColor is the global hover overlay that many
        // Material widgets fall back to. Material 3's default is
        // Colors.black/white * 0.04 — the white in dark mode reads as a
        // bright wash on Nier's dark-brown surfaces. Force a Nier-toned
        // mid-tone here so every widget without a specific overlay
        // stays inside the palette.
        hoverColor: NierColors.yorha.textBrownGrey.withValues(alpha: 0.06),
        textTheme: base.light.textTheme.apply(
          bodyColor: NierColors.yorha.textBrownGrey,
          displayColor: NierColors.yorha.textBrownGrey,
        ),
        // Scaffold is transparent so the Nier decoration layers
        // (corner decor SVG + grid lines) painted inside
        // NierPageFrame show through. The visible page background is
        // provided by NierPageFrame's outer ColoredBox using the
        // theme's surface color.
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: base.light.colorScheme.copyWith(
          surface: NierColors.yorha.canvasBeige,
          surfaceContainerLowest: NierColors.yorha.surfaceOffWhite,
          surfaceContainerLow: NierColors.yorha.surfaceOffWhite,
          surfaceContainer: NierColors.yorha.surfaceOffWhite,
          surfaceContainerHigh: NierColors.yorha.gridLineBeige,
          surfaceContainerHighest: NierColors.yorha.gridLineBeige,
          onSurface: NierColors.yorha.textBrownGrey,
          onSurfaceVariant: NierColors.yorha.textBrownDarkOutline,
          // Material 3 auto-derives onPrimary as white when not set,
          // which surfaces as white text on FilledButton (primary bg).
          // Nier has no white in its palette — explicitly map to
          // canvasBeige so filled-button labels read as the in-game
          // cream-on-brown pairing.
          onPrimary: NierColors.yorha.canvasBeige,
          onPrimaryContainer: NierColors.yorha.canvasBeige,
          onSecondaryContainer: NierColors.yorha.textBrownGrey,
          onTertiaryContainer: NierColors.yorha.textBrownGrey,
          outline: NierColors.yorha.outlineGrey,
          outlineVariant: NierColors.yorha.gridLineBeige,
        ),
        cardColor: NierColors.yorha.surfaceOffWhite,
        cardTheme: CardThemeData(
          color: NierColors.yorha.surfaceOffWhite,
          // Square corners — Nier UI panels are hard rectangles.
          shape: const RoundedRectangleBorder(),
        ),
        inputDecorationTheme: base.light.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: NierColors.yorha.surfaceOffWhite,
          // Default Material 3 hover overlay is onSurface * 0.08 — on
          // Nier's pale surfaceOffWhite fill it visibly washes toward a
          // near-white tint, which doesn't exist in the game palette.
          // Use a subtle outlineGrey wash instead so hover stays in the
          // beige/brown family.
          hoverColor: NierColors.yorha.outlineGrey.withValues(alpha: 0.06),
          // Square the OutlineInputBorder (default radius is 4) so
          // text fields match Nier's hard-rectangular input panels.
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: NierColors.yorha.outlineGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: NierColors.yorha.outlineGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide:
                BorderSide(color: NierColors.yorha.textBrownGrey, width: 2),
          ),
        ),
        dialogTheme: const DialogThemeData(
          shape: RoundedRectangleBorder(),
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
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: NierColors.yorha.outlineGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: NierColors.yorha.outlineGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
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
        // Filled + elevated + outlined buttons follow the in-game
        // YorHa choice-button pattern: lighter `dominantBeige`
        // surface when idle, `textBrownGrey` (dark) when hovered /
        // focused / pressed / selected. Foreground inverts so
        // contrast stays legible. Drop shadow is handled by wrapping
        // the button in `OffsetShadow` at the call site (Material's
        // elevation always blurs; Nier needs hard offset).
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: _nierButtonStyle(
            idleBg: NierColors.yorha.dominantBeige,
            idleFg: NierColors.yorha.textBrownGrey,
            activeBg: NierColors.yorha.textBrownGrey,
            activeFg: NierColors.yorha.canvasBeige,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: _nierButtonStyle(
            idleBg: NierColors.yorha.dominantBeige,
            idleFg: NierColors.yorha.textBrownGrey,
            activeBg: NierColors.yorha.textBrownGrey,
            activeFg: NierColors.yorha.canvasBeige,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: _nierButtonStyle(
            idleBg: NierColors.yorha.dominantBeige,
            idleFg: NierColors.yorha.textBrownGrey,
            activeBg: NierColors.yorha.textBrownGrey,
            activeFg: NierColors.yorha.canvasBeige,
          ),
        ),
      ),
      dark: base.dark.copyWith(
        // Same chart palette as light mode — Nier's chart hues read
        // the same in either mode.
        extensions: <ThemeExtension<dynamic>>[
          ChartPalette.nier,
          ShapeTokens.nier,
          TypographyTokens.nier,
          FrameTokens(
            wrap: (Widget child) => NierPageFrame(
              showGrid: showGrid,
              showCorner: showCorner,
              child: child,
            ),
          ),
          ButtonTokens(
            buildMinor: ({
              required String label,
              required VoidCallback? onPressed,
              IconData? icon,
              bool destructive = false,
              bool selected = false,
            }) =>
                NierMinorButton(
                  label: label,
                  onPressed: onPressed,
                  icon: icon,
                  destructive: destructive,
                  selected: selected,
                ),
            buildSuper: ({
              required String label,
              required VoidCallback? onPressed,
              IconData? icon,
              bool destructive = false,
              bool selected = false,
            }) =>
                NierSuperButton(
                  label: label,
                  onPressed: onPressed,
                  icon: icon,
                  destructive: destructive,
                  selected: selected,
                ),
          ),
        ],
        // See light comment. In dark Nier the Material 3 default
        // overlay (onSurface = canvasBeige cream at low alpha) lifts
        // the dark-brown surface visibly toward "white" on hover. Use
        // gridLineBeige (more saturated mid-tone) so the hover wash
        // still reads as Nier-beige rather than diluted-cream.
        hoverColor: NierColors.yorha.gridLineBeige.withValues(alpha: 0.08),
        textTheme: base.dark.textTheme.apply(
          bodyColor: NierColors.yorha.canvasBeige,
          displayColor: NierColors.yorha.canvasBeige,
        ),
        // See light comment.
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: base.dark.colorScheme.copyWith(
          surface: NierColors.yorha.textBrownGrey,
          surfaceContainerLowest: NierColors.yorha.textBrownDarker,
          surfaceContainerLow: NierColors.yorha.textBrownDarker,
          surfaceContainer: NierColors.yorha.textBrownDarker,
          surfaceContainerHigh: NierColors.yorha.textBrownDarkOutline,
          surfaceContainerHighest: NierColors.yorha.textBrownDarkOutline,
          onSurface: NierColors.yorha.canvasBeige,
          onSurfaceVariant: NierColors.yorha.outlineGrey,
          // Dark Nier primary is canvasBeige; default-derived onPrimary
          // would be near-black. Pin it to textBrownGrey so the
          // brown-on-beige in-game pairing renders on filled buttons.
          onPrimary: NierColors.yorha.textBrownGrey,
          onPrimaryContainer: NierColors.yorha.textBrownGrey,
          onSecondaryContainer: NierColors.yorha.textBrownGrey,
          onTertiaryContainer: NierColors.yorha.textBrownGrey,
          outline: NierColors.yorha.textBrownDarkOutline,
          outlineVariant: NierColors.yorha.textBrownDarker,
        ),
        cardColor: NierColors.yorha.textBrownDarker,
        cardTheme: CardThemeData(
          color: NierColors.yorha.textBrownDarker,
          shape: const RoundedRectangleBorder(),
        ),
        inputDecorationTheme: base.dark.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: NierColors.yorha.textBrownDarker,
          // Dark-mode hover would otherwise paint canvasBeige (onSurface)
          // at 8% over the dark fill — a cream tint that reads as
          // "almost white" against textBrownDarker. Override with the
          // outline mid-tone so hover stays inside the brown family.
          hoverColor: NierColors.yorha.outlineGrey.withValues(alpha: 0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: NierColors.yorha.textBrownDarkOutline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: NierColors.yorha.textBrownDarkOutline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide:
                BorderSide(color: NierColors.yorha.canvasBeige, width: 2),
          ),
        ),
        appBarTheme: base.dark.appBarTheme.copyWith(
          backgroundColor: NierColors.yorha.textBrownGrey,
          foregroundColor: NierColors.yorha.canvasBeige,
        ),
        navigationRailTheme: base.dark.navigationRailTheme.copyWith(
          backgroundColor: NierColors.yorha.textBrownGrey,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: NierColors.yorha.textBrownDarker,
          shape: const RoundedRectangleBorder(),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: TextStyle(color: NierColors.yorha.canvasBeige),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: NierColors.yorha.textBrownDarker,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide:
                  BorderSide(color: NierColors.yorha.textBrownDarkOutline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide:
                  BorderSide(color: NierColors.yorha.textBrownDarkOutline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
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
        // Dark-mode counterpart of the YorHa choice-button pattern:
        // textBrownDarker (deeper brown) when idle, canvasBeige
        // (cream) when active. Foreground inverts.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: _nierButtonStyle(
            idleBg: NierColors.yorha.textBrownDarker,
            idleFg: NierColors.yorha.canvasBeige,
            activeBg: NierColors.yorha.canvasBeige,
            activeFg: NierColors.yorha.textBrownGrey,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: _nierButtonStyle(
            idleBg: NierColors.yorha.textBrownDarker,
            idleFg: NierColors.yorha.canvasBeige,
            activeBg: NierColors.yorha.canvasBeige,
            activeFg: NierColors.yorha.textBrownGrey,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: _nierButtonStyle(
            idleBg: NierColors.yorha.textBrownDarker,
            idleFg: NierColors.yorha.canvasBeige,
            activeBg: NierColors.yorha.canvasBeige,
            activeFg: NierColors.yorha.textBrownGrey,
          ),
        ),
      ),
    );
  }
}

/// Shared button style for the in-game YorHa "lighter idle, darker
/// active" choice pattern. Returns a [ButtonStyle] whose background
/// + foreground each swap between the idle and active pair based on
/// `WidgetState.hovered`, `focused`, `pressed`, or `selected`. Shape
/// is forced square to match `ShapeTokens.nier`.
ButtonStyle _nierButtonStyle({
  required Color idleBg,
  required Color idleFg,
  required Color activeBg,
  required Color activeFg,
}) {
  const Set<WidgetState> activeStates = <WidgetState>{
    WidgetState.hovered,
    WidgetState.focused,
    WidgetState.pressed,
    WidgetState.selected,
  };
  bool isActive(Set<WidgetState> states) =>
      states.any(activeStates.contains);
  return ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) => isActive(states) ? activeBg : idleBg,
    ),
    foregroundColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) => isActive(states) ? activeFg : idleFg,
    ),
    shape: const WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(),
    ),
  );
}
