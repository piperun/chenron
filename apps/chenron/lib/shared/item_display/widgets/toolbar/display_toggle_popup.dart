import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/locator.dart";

class DisplayTogglePopup extends StatelessWidget {
  final bool _iconOnly;

  const DisplayTogglePopup({super.key}) : _iconOnly = false;

  const DisplayTogglePopup.icon({super.key}) : _iconOnly = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = _iconOnly
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;
    final ConfigController config = locator.get<ConfigController>();

    return MenuAnchor(
      builder: (context, controller, child) {
        void toggle() {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        }

        if (_iconOnly) {
          return Material(
            color: foreground.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: toggle,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.tune,
                  size: 20,
                  color: foreground.withValues(alpha: 0.8),
                ),
              ),
            ),
          );
        }

        return OutlinedButton.icon(
          onPressed: toggle,
          icon: Icon(Icons.tune, size: 16, color: foreground),
          label: Text(
            "Display",
            style: TextStyle(color: foreground),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: theme.dividerColor),
          ),
        );
      },
      menuChildren: [
        MenuItemButton(
          onPressed: null,
          child: Watch((context) => _DisplayToggleCheckbox(
                label: "Images",
                isSelected: config.showImages.value,
                onChanged: (v) => config.updateShowImages(enabled: v),
              )),
        ),
        MenuItemButton(
          onPressed: null,
          child: Watch((context) => _DisplayToggleCheckbox(
                label: "Description",
                isSelected: config.showDescription.value,
                onChanged: (v) => config.updateShowDescription(enabled: v),
              )),
        ),
        MenuItemButton(
          onPressed: null,
          child: Watch((context) => _DisplayToggleCheckbox(
                label: "Tags",
                isSelected: config.showTags.value,
                onChanged: (v) => config.updateShowTags(enabled: v),
              )),
        ),
        MenuItemButton(
          onPressed: null,
          child: Watch((context) => _DisplayToggleCheckbox(
                label: "Copy",
                isSelected: config.showCopyLink.value,
                onChanged: (v) => config.updateShowCopyLink(enabled: v),
              )),
        ),
      ],
    );
  }
}

class _DisplayToggleCheckbox extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const _DisplayToggleCheckbox({
    required this.label,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) => onChanged(value ?? false),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
