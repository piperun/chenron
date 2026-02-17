import "package:flutter/material.dart";

class SelectableItemWrapper extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isDeleteMode ? onTap : null,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          if (isDeleteMode && isSelected)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
