import "package:flutter/material.dart";
import "package:vibe/vibe.dart";

import "package:chenron/features/settings/models/settings_category.dart";

class SettingsNavigationRail extends StatefulWidget {
  final SettingsCategory selectedCategory;
  final ValueChanged<SettingsCategory> onCategorySelected;
  final bool isExtended;
  final VoidCallback onToggleExtended;
  final VoidCallback onBack;

  const SettingsNavigationRail({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.isExtended,
    required this.onToggleExtended,
    required this.onBack,
  });

  @override
  State<SettingsNavigationRail> createState() => _SettingsNavigationRailState();
}

class _SettingsNavigationRailState extends State<SettingsNavigationRail> {
  late Set<SettingsCategory> _expandedCategories;

  @override
  void initState() {
    super.initState();
    _expandedCategories = {};
    // Auto-expand the parent of the initially selected category
    final parent = widget.selectedCategory.parent;
    if (parent != null) {
      _expandedCategories.add(parent);
    }
  }

  void _onCategoryTap(SettingsCategory category) {
    if (category.hasChildren) {
      setState(() {
        if (_expandedCategories.contains(category)) {
          _expandedCategories.remove(category);
        } else {
          _expandedCategories.add(category);
          // Auto-select first child when expanding
          widget.onCategorySelected(category.children.first);
        }
      });
    } else {
      // Leaf or sub-category: select directly
      widget.onCategorySelected(category);
    }
  }

  bool _isSelected(SettingsCategory category) {
    if (category == widget.selectedCategory) return true;
    // A parent is "selected" if one of its children is selected
    if (category.hasChildren) {
      return category.children.contains(widget.selectedCategory);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.isExtended ? 280 : 72,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            right: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
          _SettingsHeader(
            isExtended: widget.isExtended,
            onToggleExtended: widget.onToggleExtended,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              children: [
                for (final category in SettingsCategory.topLevel) ...[
                  _CategoryRow(
                    category: category,
                    isSelected: _isSelected(category),
                    isExpanded: _expandedCategories.contains(category),
                    isExtended: widget.isExtended,
                    onTap: () => _onCategoryTap(category),
                  ),
                  if (_expandedCategories.contains(category))
                    for (final child in category.children)
                      widget.isExtended
                          ? _SubCategoryRow(
                              category: child,
                              isSelected: child == widget.selectedCategory,
                              onTap: () => _onCategoryTap(child),
                            )
                          : _CollapsedSubCategoryRow(
                              category: child,
                              isSelected: child == widget.selectedCategory,
                              onTap: () => _onCategoryTap(child),
                            ),
                ],
              ],
            ),
          ),
          _SettingsBackButton(
            isExtended: widget.isExtended,
            onBack: widget.onBack,
          ),
        ],
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final bool isExtended;
  final VoidCallback onToggleExtended;

  const _SettingsHeader({
    required this.isExtended,
    required this.onToggleExtended,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isExtended)
            const Text(
              "SETTINGS",
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
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final SettingsCategory category;
  final bool isSelected;
  final bool isExpanded;
  final bool isExtended;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.category,
    required this.isSelected,
    required this.isExpanded,
    required this.isExtended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final IconData displayIcon =
        isSelected ? category.selectedIcon : category.icon;

    // Collapsed rail: tight icon-only row. SuperButton's pointer +
    // plate chrome doesn't make sense in 72 px width, so we keep the
    // existing minimal layout for this mode.
    if (!isExtended) {
      return Tooltip(
        message: category.label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              displayIcon,
              size: 20,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    // Extended rail: SuperButton renders the menu-row chrome (active
    // theme decides — Nier gives YorHa fade-fill + pointer + borders;
    // Material falls back to a plain FilledButton). Hierarchy chevron
    // sits outside the button as a trailing hint.
    final Widget button = SuperButton(
      label: category.label,
      icon: displayIcon,
      selected: isSelected,
      onPressed: onTap,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: category.hasChildren
          ? Row(
              children: [
                Expanded(child: button),
                Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            )
          : button,
    );
  }
}

class _SubCategoryRow extends StatelessWidget {
  final SettingsCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubCategoryRow({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Indent sub-categories so the hierarchy stays visually obvious
      // even after the pointer + plate chrome takes most of the row.
      padding: const EdgeInsets.only(left: 20, top: 1, bottom: 1),
      child: SuperButton(
        label: category.label,
        icon: isSelected ? category.selectedIcon : category.icon,
        selected: isSelected,
        onPressed: onTap,
      ),
    );
  }
}

class _CollapsedSubCategoryRow extends StatelessWidget {
  final SettingsCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CollapsedSubCategoryRow({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: category.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          margin: const EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(
            color:
                isSelected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isSelected ? category.selectedIcon : category.icon,
            size: 18,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SettingsBackButton extends StatelessWidget {
  final bool isExtended;
  final VoidCallback onBack;

  const _SettingsBackButton({
    required this.isExtended,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: isExtended
          ? SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text("Back"),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          : Center(
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                tooltip: "Back",
              ),
            ),
    );
  }
}
