import "package:flutter/material.dart";

/// A widget that shows a floating label to the right on hover or focus.
///
/// Used in collapsed navigation rails where only icons are visible.
/// Wraps a [child] and displays [label] in a tooltip-style overlay
/// anchored to the right when the mouse hovers or keyboard focuses.
///
/// Adds [Semantics] with a tooltip so screen readers announce the label.
class FloatingLabel extends StatefulWidget {
  final String label;
  final Widget child;

  const FloatingLabel({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  State<FloatingLabel> createState() => _FloatingLabelState();
}

class _FloatingLabelState extends State<FloatingLabel> {
  final _controller = OverlayPortalController();
  final _link = LayerLink();
  bool _isHovered = false;
  bool _isFocused = false;

  void _show() {
    if (!_controller.isShowing) _controller.show();
  }

  void _hide() {
    if (!_isHovered && !_isFocused && _controller.isShowing) {
      _controller.hide();
    }
  }

  void _handleHoverEnter(PointerEvent _) {
    _isHovered = true;
    _show();
  }

  void _handleHoverExit(PointerEvent _) {
    _isHovered = false;
    _hide();
  }

  void _handleFocusChange(bool focused) {
    _isFocused = focused;
    if (focused) {
      _show();
    } else {
      _hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      tooltip: widget.label,
      child: CompositedTransformTarget(
        link: _link,
        child: OverlayPortal(
          controller: _controller,
          overlayChildBuilder: (_) => CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.centerRight,
            followerAnchor: Alignment.centerLeft,
            offset: const Offset(8, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IgnorePointer(
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(6),
                  color: colorScheme.inverseSurface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          child: Focus(
            onFocusChange: _handleFocusChange,
            skipTraversal: true,
            child: MouseRegion(
              onEnter: _handleHoverEnter,
              onExit: _handleHoverExit,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
