import "package:flutter/material.dart";

/// NieR:Automata – raw YorHa palette
///
/// Field names describe *what the colour is for in‑game*,
/// not its Material role.
///
/// Comment format:
///   HexCode – < ≤ 50 chars describing purpose>
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
});

abstract final class NierColors {
  NierColors._();

  // ──────────────────────  YorHa palette  ──────────────────────
  static const YorhaColors yorha = (
    /// 0xFFCCC8B1 – background grid lines
    gridLineBeige: Color(0xFFCCC8B1),

    /// 0xFF454138 – primary text / borders
    textBrownGrey: Color(0xFF454138),

    /// 0xFF3B372E – darker contrast for textBrownGrey
    textBrownDarker: Color(0xFF3B372E),

    /// 0xFF2E2922 – darker outline variant of textBrownGrey
    textBrownDarkOutline: Color(0xFF5C584F),

    /// 0xFFBAB5A1 – outlines & dividers
    outlineGrey: Color(0xFFBAB5A1),

    /// 0xFFD1CDB7 – main canvas background
    canvasBeige: Color(0xFFD1CDB7),

    /// 0xFFDCD8C0 – component backgrounds
    surfaceOffWhite: Color(0xFFDCD8C0),

    /// 0xFF444444 – icon glyphs
    iconGrey: Color(0xFF444444),

    /// 0xFFCE664D – HUD error / danger accent
    hudRed: Color(0xFFCE664D),

    /// 0xFF38AAA1 – HUD teal accent
    hudTeal: Color(0xFF38AAA1),

    /// 0xFFE0D9AB – HUD yellow / warning accent
    hudYellow: Color(0xFFE0D9AB),

    /// 0xFFE6E7E6 – HUD platinum highlight
    hudPlatinum: Color(0xFFE6E7E6),
  );
}
