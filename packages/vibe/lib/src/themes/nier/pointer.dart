import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The YorHa selection-arrow pointer that sits to the left of the
/// currently-highlighted dialog option / menu row. SVG ported verbatim
/// from MIT-licensed `automato_theme`'s `automatoSvgStrPointer`
/// (https://github.com/Vluurie/automato_theme), embedded inline so no
/// asset wiring is required. Recoloured via [ColorFilter] so the
/// hardcoded `#48463d` fill inside the SVG follows the active theme's
/// foreground tone.
///
/// Shared by [NierMinorButton] and [NierSuperButton]; library-internal
/// to the Nier theme (not exported from the package barrel).
class NierPointer extends StatelessWidget {
  /// Build the YorHa selection pointer tinted with [color].
  const NierPointer({super.key, required this.color});

  /// Reserved layout width for the pointer slot. Matches
  /// `ThemeDimensions.pointerSvgWidth` (32) from `automato_theme`.
  static const double width = 32;

  /// Layout height derived from the SVG's native aspect ratio
  /// (367.705 × 234.894 ≈ 1.565 : 1). Pre-computed rather than letting
  /// `BoxFit.contain` figure it out so callers can lay the slot out
  /// against a known constant.
  static const double height = 20;

  /// Stroke/fill tint applied to the otherwise-black SVG via a
  /// `srcIn` [ColorFilter] — set to the active theme's foreground.
  final Color color;

  static const String _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="367.705" height="234.894" viewBox="0 0 367.705 234.894">
  <path fill="black" d="M0,117.447l90.7,90.7,272.151-90.7L90.7,26.747Zm105.983,0a17.3,17.3,0,1,1-17.3-17.3A17.3,17.3,0,0,1,105.983,117.447Z"/>
  <rect fill="black" x="340.658" y="207.848" width="27.046" height="27.046" transform="translate(132.81 575.553) rotate(-90)"/>
  <rect fill="black" x="340.658" width="27.046" height="27.046" transform="translate(340.658 367.705) rotate(-90)"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      fit: BoxFit.contain,
    );
  }
}
