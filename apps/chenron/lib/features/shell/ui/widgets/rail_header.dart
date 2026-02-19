import "package:flutter/material.dart";
import "package:chenron/components/floating_label.dart";
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showExtended = constraints.maxWidth > 120;
          return Column(
            crossAxisAlignment: showExtended
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              // Section destinations
              if (showExtended)
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
              if (showExtended)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "FOLDERS",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu_open),
                      onPressed: onToggleExtended,
                      tooltip: "Collapse",
                    ),
                  ],
                )
              else
                FloatingLabel(
                  label: "Expand",
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: onToggleExtended,
                  ),
                ),
            ],
          );
        },
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
          showLabel: false,
          onTap: () => onSectionSelected(section),
        );
      }).toList(),
    );
  }
}

class _SectionDestination extends StatelessWidget {
  final NavigationSection section;
  final bool isSelected;
  final bool showLabel;
  final VoidCallback onTap;

  const _SectionDestination({
    required this.section,
    required this.isSelected,
    this.showLabel = true,
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

    Widget destination = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Icon (20) + padding (16/24) + gap (8) + label needs ~90px
            final canShowLabel =
                showLabel && constraints.maxWidth > 80;
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: canShowLabel ? 12 : 8,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize:
                    canShowLabel ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: color),
                  if (canShowLabel) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        section.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );

    if (!showLabel) {
      destination = FloatingLabel(
        label: section.label,
        child: destination,
      );
    }

    return destination;
  }
}
