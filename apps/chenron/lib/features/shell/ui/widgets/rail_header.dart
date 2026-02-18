import "package:flutter/material.dart";
import "package:chenron/features/shell/ui/sections/navigation_section.dart";

class RailHeader extends StatelessWidget {
  final bool isExtended;
  final VoidCallback onToggleExtended;
  final NavigationSection currentSection;
  final void Function(NavigationSection) onSectionSelected;

  const RailHeader({
    super.key,
    required this.isExtended,
    required this.onToggleExtended,
    required this.currentSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section destinations
          if (isExtended)
            _SectionRow(
              currentSection: currentSection,
              onSectionSelected: onSectionSelected,
            )
          else
            _SectionColumn(
              currentSection: currentSection,
              onSectionSelected: onSectionSelected,
            ),
          const SizedBox(height: 8),
          // FOLDERS label + collapse toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isExtended)
                const Text(
                  "FOLDERS",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              IconButton(
                icon: Icon(isExtended ? Icons.menu_open : Icons.menu),
                onPressed: onToggleExtended,
                tooltip: isExtended ? "Collapse" : "Expand",
              ),
            ],
          ),
        ],
      ),
    );
  }

}

/// Extended: horizontal row of icon + label buttons.
class _SectionRow extends StatelessWidget {
  final NavigationSection currentSection;
  final void Function(NavigationSection) onSectionSelected;

  const _SectionRow({
    required this.currentSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: NavigationSection.values.map((section) {
        final isSelected = section == currentSection;
        return Expanded(
          child: _SectionDestination(
            section: section,
            isSelected: isSelected,
            isExtended: true,
            onTap: () => onSectionSelected(section),
          ),
        );
      }).toList(),
    );
  }
}

/// Collapsed: vertical column of icon-only buttons.
class _SectionColumn extends StatelessWidget {
  final NavigationSection currentSection;
  final void Function(NavigationSection) onSectionSelected;

  const _SectionColumn({
    required this.currentSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: NavigationSection.values.map((section) {
        final isSelected = section == currentSection;
        return _SectionDestination(
          section: section,
          isSelected: isSelected,
          isExtended: false,
          onTap: () => onSectionSelected(section),
        );
      }).toList(),
    );
  }
}

class _SectionDestination extends StatelessWidget {
  final NavigationSection section;
  final bool isSelected;
  final bool isExtended;
  final VoidCallback onTap;

  const _SectionDestination({
    required this.section,
    required this.isSelected,
    required this.isExtended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = isSelected ? section.selectedIcon : section.icon;
    final color = isSelected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;
    final bgColor =
        isSelected ? colorScheme.primaryContainer : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isExtended ? 12 : 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: isExtended ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              if (isExtended) ...[
                const SizedBox(width: 8),
                Text(
                  section.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
