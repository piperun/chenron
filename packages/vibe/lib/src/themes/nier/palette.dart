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
});

/// NierColors copied from the application so theme output matches current app.
abstract final class NierColors {
  NierColors._();

  /// YorHa palette colors used to derive Nier theme roles.
  static const YorhaColors yorha = (
    gridLineBeige: Color(0xFFCCC8B1),
    textBrownGrey: Color(0xFF454138),
    textBrownDarker: Color(0xFF3B372E),
    textBrownDarkOutline: Color(0xFF5C584F),
    outlineGrey: Color(0xFFBAB5A1),
    canvasBeige: Color(0xFFD1CDB7),
    surfaceOffWhite: Color(0xFFDCD8C0),
    iconGrey: Color(0xFF444444),
    hudRed: Color(0xFFCE664D),
    hudTeal: Color(0xFF38AAA1),
    hudYellow: Color(0xFFE0D9AB),
    hudPlatinum: Color(0xFFE6E7E6),
  );
}
