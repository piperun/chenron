import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders the Nier in-game HUD-style frame at the very top and
/// very bottom of a page, with the page content sandwiched in
/// between.
///
/// Each band is the SVG glyph below tiled horizontally to fill the
/// page width. The glyph itself is taken from the MIT-licensed
/// `automato_theme` Flutter package
/// (https://github.com/Vluurie/automato_theme), which extracted it
/// directly from the in-game YorHa HUD chrome. We embed it as an
/// inline string so no asset wiring or font shipping is needed.
///
/// Color is overridden via `colorFilter` so the same SVG can render
/// brown on cream (light Nier) or cream on brown (dark Nier).
///
/// Attached to the Nier theme via `FrameTokens.nier`; consumed at
/// the `MaterialApp.builder` level so every route gets framed.
class NierPageFrame extends StatelessWidget {
  /// Build a page-frame wrapper around [child].
  const NierPageFrame({
    super.key,
    required this.child,
    this.showGrid = true,
    this.showCorner = true,
  });

  /// The active page content. Drawn between the top and bottom HUD
  /// bands.
  final Widget child;

  /// Whether the fine graph-paper grid wash renders behind the page.
  /// Themed via the Nier `gridOverlay` user setting.
  final bool showGrid;

  /// Whether the oversized YorHa circle + diagonal hatching decor
  /// renders behind the page. Themed via the Nier `cornerDecor` user
  /// setting.
  final bool showCorner;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // YorHa-extracted chrome tones: `textBrownGrey` for light-mode
    // strokes on cream surfaces, `canvasBeige` for dark-mode strokes
    // on brown surfaces.
    final Color color = theme.brightness == Brightness.light
        ? const Color(0xFF454138)
        : const Color(0xFFD1CDB7);
    // Layered composition matching `automato_theme`'s
    // `AutomatoBackground` build order. Everything stacks; the page
    // content sits on top, bands are inset 20 px from the edges
    // (`borderSvgFillPositionTop: top 20` / `bottom 20`), and the
    // background decorations span the full Stack.
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Stack(
        children: <Widget>[
          // 1. Corner decor SVG — oversized via negative `Positioned`
          //    offsets so the SVG's circles bleed off-screen and only
          //    fragments of diagonal hatching cross the visible page.
          //    Matches `backgroundSvgFillPosition: top -500, bottom
          //    -500, left -250, right -250`.
          if (showCorner)
            Positioned(
              top: -500,
              bottom: -500,
              left: -250,
              right: -250,
              child: _NierMenuDecor(color: color),
            ),
          // 2. Grid lines (axis-aligned vertical + horizontal at low
          //    opacity — `LinePainter` defaults: spacing 6, stroke 1,
          //    opacity 0.1).
          if (showGrid) Positioned.fill(child: _NierGridLines(color: color)),
          // 3. Page content — inset so it stops at the bands rather
          //    than extending behind them. `20` is the band offset
          //    from the screen edge, `14` is the band height (matches
          //    `automato_theme`'s `ThemeDimensions.borderHeight`).
          Positioned(
            top: 34,
            bottom: 34,
            left: 0,
            right: 0,
            child: child,
          ),
          // 4. Top band — 20 px from top edge.
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: _NierBand(color: color, mirrored: false),
          ),
          // 5. Bottom band — 20 px from bottom edge, mirrored so the
          //    solid edge line sits at its bottom.
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _NierBand(color: color, mirrored: true),
          ),
        ],
      ),
    );
  }
}

/// The faint two-corner motif behind every Nier menu page — a small
/// circle in the top-left + diagonal hatching, mirrored bottom-right.
/// SVG taken from the MIT-licensed `automato_theme` package
/// (https://github.com/Vluurie/automato_theme), which extracted it
/// from the YorHa menu chrome.
class _NierMenuDecor extends StatelessWidget {
  const _NierMenuDecor({required this.color});

  final Color color;

  // Opacity-groups at 0.1 match `automato_theme`'s default. With
  // the oversized `Positioned(top: -500, ...)` placement, the
  // SVG's diagonal lines stretch across the whole visible page and
  // 10 % is enough — bumping higher made them dominate when scaled
  // small, but at oversized scale the lines paint over a much
  // bigger area so the same alpha reads bolder.
  static const String _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="476.994" height="477.506" viewBox="0 0 476.994 477.506">
  <g opacity="0.1">
    <circle fill="none" stroke="black" stroke-miterlimit="10" cx="112.349" cy="112.747" r="105.767"/>
  </g>
  <g opacity="0.1">
    <line fill="none" stroke="black" stroke-miterlimit="10" x1="22.982" y1="7.896" x2="218.935" y2="203.849"/>
    <line fill="none" stroke="black" stroke-miterlimit="10" x1="7.896" y1="22.982" x2="203.849" y2="218.935"/>
    <line fill="none" stroke="black" stroke-miterlimit="10" x1="0.354" y1="0.354" x2="226.478" y2="226.478"/>
  </g>
  <g opacity="0.1">
    <circle fill="none" stroke="black" stroke-miterlimit="10" cx="362.511" cy="363.421" r="105.767"/>
  </g>
  <g opacity="0.1">
    <line fill="none" stroke="black" stroke-miterlimit="10" x1="273.144" y1="258.571" x2="469.098" y2="454.524"/>
    <line fill="none" stroke="black" stroke-miterlimit="10" x1="258.059" y1="273.656" x2="454.012" y2="469.609"/>
    <line fill="none" stroke="black" stroke-miterlimit="10" x1="250.516" y1="251.028" x2="476.64" y2="477.152"/>
  </g>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg,
      // Fill the page area entirely. Stretches the SVG's 1:1 viewBox
      // to the actual aspect ratio — circles become slight ovals at
      // non-square aspect ratios; matches the in-game behavior where
      // the corner motifs adapt to screen shape rather than tile.
      fit: BoxFit.fill,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

/// Axis-aligned grid overlay — verticals + horizontals at low alpha.
/// Mirrors `automato_theme`'s `LinePainter` (MIT) which Nier's
/// in-game menus use as a "graph paper" wash behind page content.
class _NierGridLines extends StatelessWidget {
  const _NierGridLines({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridLinePainter(color: color),
    );
  }
}

class _GridLinePainter extends CustomPainter {
  _GridLinePainter({required this.color});

  final Color color;

  // Ported from `automato_theme`'s `LinesConfig` defaults: spacing 6
  // px, stroke 1 px, opacity 0.1. Reads as fine graph-paper rather
  // than a sparse grid — matches the in-game YorHa menu background.
  static const double _spacing = 6;
  static const double _strokeWidth = 1;
  static const double _opacity = 0.1;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withValues(alpha: _opacity)
      ..strokeWidth = _strokeWidth;
    for (double x = 0; x < size.width; x += _spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += _spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Single repeating band — either the top frame (line above, glyphs
/// below) or the bottom frame ([mirrored] = true, which flips the
/// SVG vertically so the line ends up at the band's bottom edge).
class _NierBand extends StatelessWidget {
  const _NierBand({required this.color, required this.mirrored});

  final Color color;
  final bool mirrored;

  // Tile dimensions match `automato_theme`'s `ThemeDimensions.svgWidth = 64`
  // and `borderHeight = 14`. The SVG's own `width` attribute is 64.932
  // and `height` is 15.759; rendering into a 64×14 box compresses the
  // glyphs slightly — the same compression `automato_theme` applies in
  // `AutomatoBorderSVG` + `buildRepeatingBorderSVG`.
  static const double _tileWidth = 64;
  static const double _tileHeight = 14;

  static const String _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="64.932" height="15.759" viewBox="0 0 75.932 15.759">
  <line fill="none" stroke="black" stroke-miterlimit="10" y1="0.5" x2="75.932" y2="0.5"/>
  <rect fill="black" x="55.072" y="0.959" width="9.86" height="4.762"/>
  <ellipse fill="black" cx="23.12" cy="6.041" rx="2.308" ry="2.365"/>
  <ellipse fill="black" cx="31.809" cy="6.041" rx="2.308" ry="2.365"/>
  <ellipse fill="black" cx="27.465" cy="13.394" rx="2.308" ry="2.365"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _tileHeight,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final int tileCount =
              (constraints.maxWidth / _tileWidth).ceil() + 1;
          final Widget row = Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < tileCount; i++)
                SvgPicture.string(
                  _svg,
                  width: _tileWidth,
                  height: _tileHeight,
                  fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
            ],
          );
          // Clip so partial tiles at the right edge don't overflow.
          // For the bottom band, flip vertically so the solid line
          // sits at the band's lower edge and the glyphs above it.
          final Widget clipped = ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              alignment: Alignment.centerLeft,
              child: row,
            ),
          );
          if (!mirrored) return clipped;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationX(3.14159265358979),
            child: clipped,
          );
        },
      ),
    );
  }
}
