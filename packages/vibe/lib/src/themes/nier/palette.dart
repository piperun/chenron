import 'package:flutter/material.dart';

/// NieR:Automata – raw YorHa palette
///
/// Field names describe what the colour is for in‑game,
/// not its Material role.
///
/// Comment format:
///   HexCode – short description
typedef YorhaColors = ({
  Color gridLineBeige,
  Color textBrownGrey,
  Color textBrownDarker,
  Color textBrownDarkOutline,
  Color outlineGrey,
  Color canvasBeige,
  Color surfaceOffWhite,
  Color iconGrey,
  Color hudRed,
  Color hudTeal,
  Color hudYellow,
  Color hudPlatinum,
  Color dominantBeige,
  Color selectedAccent,
});

/// Color tokens lifted verbatim from `automato_theme`'s default Nier
/// theme map (MIT-licensed,
/// https://github.com/Vluurie/automato_theme). Their semantics are
/// theme-role oriented (primary / brown / hoverBrown / tan / bright)
/// rather than literal in-game element names, which is what `NierTheme`
/// uses to drive the Material 3 ColorScheme + widget theme defaults.
typedef AutomatoColors = ({
  Color primary,
  Color brown,
  Color brown25,
  Color brown15,
  Color brown025,
  Color darkBrown,
  Color hoverBrown,
  Color tan,
  Color bright,
  Color dangerZone,
  Color saveZone,
  Color selected,
  Color gradient,
});

/// NierColors copied from the application so theme output matches current app.
abstract final class NierColors {
  NierColors._();

  /// YorHa palette colors used to derive Nier theme roles. Values
  /// are sourced from the in-game color database (catalogued in
  /// `memory/reference_nier_palette.md`); deviations from the
  /// catalog get a one-line note explaining why.
  static const YorhaColors yorha = (
    // #BAB39D Orange Dark Pastel sits between this and outlineGrey
    // in-game; #CCC8B1 lands closer to the lighter separator-line
    // tone YorHa actually uses.
    gridLineBeige: Color(0xFFCCC8B1),
    // #434038 Orange Dark Charcoal — primary text/accent in-game.
    textBrownGrey: Color(0xFF434038),
    // #413F3A Orange Near-Black — deeper accent/shadow tone.
    textBrownDarker: Color(0xFF413F3A),
    // #777565 Yellow Charcoal — mid-tone used for borders + hover
    // overlays in-game (7.3 % of UI pixels).
    textBrownDarkOutline: Color(0xFF777565),
    outlineGrey: Color(0xFFBAB5A1),
    // #D7D0B9 Orange Light Pastel — the cream surface tone in-game.
    canvasBeige: Color(0xFFD7D0B9),
    surfaceOffWhite: Color(0xFFDCD8C0),
    iconGrey: Color(0xFF444444),
    // #AE553F Amber Deep — iconic in-game rust/warning accent.
    hudRed: Color(0xFFAE553F),
    // #32968C Teal Deep — iconic in-game utility/icon teal.
    hudTeal: Color(0xFF32968C),
    hudYellow: Color(0xFFE0D9AB),
    hudPlatinum: Color(0xFFE6E7E6),
    // #B0AC94 Yellow Dark Pastel — the most-common in-game color
    // (24.5 % of UI pixels). Used for unselected button surfaces.
    dominantBeige: Color(0xFFB0AC94),
    // #FF8800 — orange selection accent (also in automato_theme's
    // `selected` token; matches in-game selection-highlight orange
    // used on map markers + chip selection).
    selectedAccent: Color(0xFFFF8800),
  );

  /// `automato_theme`'s default Nier color set. The Material 3 theme
  /// mapping in `NierTheme` reads from here so the rendered look is
  /// 1:1 with what the original package produces.
  static const AutomatoColors automato = (
    primary: Color.fromARGB(255, 191, 178, 148),
    brown: Color.fromRGBO(72, 70, 61, 1),
    brown25: Color.fromRGBO(72, 70, 61, 0.25),
    brown15: Color.fromRGBO(72, 70, 61, 0.15),
    brown025: Color.fromRGBO(72, 70, 61, 0.025),
    darkBrown: Color.fromRGBO(69, 67, 58, 1),
    hoverBrown: Color.fromRGBO(119, 116, 98, 1),
    tan: Color.fromRGBO(194, 189, 166, 1),
    bright: Color.fromARGB(255, 223, 221, 216),
    dangerZone: Color.fromRGBO(255, 0, 0, 1),
    saveZone: Color.fromRGBO(0, 255, 0, 1),
    selected: Color.fromRGBO(255, 136, 0, 1),
    gradient: Color.fromARGB(255, 221, 219, 212),
  );
}
