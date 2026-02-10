import "dart:async";

import "package:flutter/material.dart";

class SelectableItemWrapper extends StatefulWidget {
  final bool isDeleteMode;
  final bool isSelected;
  final Widget child;
  final VoidCallback? onTap;

  const SelectableItemWrapper({
    super.key,
    required this.isDeleteMode,
    required this.isSelected,
    required this.child,
    this.onTap,
  });

  @override
  State<SelectableItemWrapper> createState() => _SelectableItemWrapperState();
}

class _SelectableItemWrapperState extends State<SelectableItemWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      value: widget.isSelected ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(SelectableItemWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        unawaited(_controller.forward());
      } else {
        unawaited(_controller.reverse());
      }
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isDeleteMode) {
      return widget.child;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final t = _animation.value;
          return Stack(
            children: [
              Opacity(
                opacity: 1.0 - (t * 0.4),
                child: child,
              ),
              if (t > 0)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1 * t),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: t),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.all(8),
                    child: Opacity(
                      opacity: t,
                      child: Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}
