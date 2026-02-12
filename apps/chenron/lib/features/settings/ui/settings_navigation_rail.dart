import "package:flutter/material.dart";
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
                  if (widget.isExtended &&
                      _expandedCategories.contains(category))
                    for (final child in category.children)
                      _SubCategoryRow(
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

    return Tooltip(
      message: isExtended ? "" : category.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color:
                isSelected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? category.selectedIcon : category.icon,
                size: 20,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              if (isExtended) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                if (category.hasChildren)
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
              ],
            ],
          ),
        ),
      ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.only(left: 32, right: 10, top: 6, bottom: 6),
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? category.selectedIcon : category.icon,
              size: 18,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ],
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
