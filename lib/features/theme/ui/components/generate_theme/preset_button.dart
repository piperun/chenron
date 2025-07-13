import "package:flutter/material.dart"
    show
        BoxDecoration,
        BuildContext,
        BoxShape,
        Border,
        Color,
        Colors,
        Container,
        Icon,
        Icons,
        InkWell,
        StatelessWidget,
        Theme,
        Tooltip,
        VoidCallback,
        Widget,
        BoxShadow;

class PresetColorButton extends StatelessWidget {
  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const PresetColorButton({
    super.key,
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onSelected,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(),
                        blurRadius: 8)
                  ]
                : null,
          ),
          child: isSelected
              ? Icon(Icons.check,
                  color: color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white)
              : null,
        ),
      ),
    );
  }
}
