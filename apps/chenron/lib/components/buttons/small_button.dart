import "package:flutter/material.dart";

class SmallButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? iconSize;
  final double? fontSize;

  const SmallButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.iconSize,
    this.fontSize,
  });

  @override
  State<SmallButton> createState() => _SmallButtonState();
}

class _SmallButtonState extends State<SmallButton> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 100),
      child: TextButton.icon(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(0, 36),
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
        ),
        icon: Icon(widget.icon, size: widget.iconSize ?? 18),
        label: Text(
          widget.label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: widget.fontSize ?? 12),
        ),
      ),
    );
  }
}
