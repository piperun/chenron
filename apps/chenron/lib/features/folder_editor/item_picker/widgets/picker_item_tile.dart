import "package:flutter/material.dart";

class PickerItemTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final bool isSelected;
  final VoidCallback onToggle;

  const PickerItemTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.leadingIcon,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: isSelected,
      onChanged: (_) => onToggle(),
      secondary: Icon(leadingIcon),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      dense: true,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
