import "package:flutter/material.dart";
import "package:forrest/forrest.dart";

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
  late final TreeController<SettingsCategory> _treeController;
  late final _SettingsTreeCompactBehavior _compactBehavior;

  @override
  void initState() {
    super.initState();
    final SettingsCategory? parent = widget.selectedCategory.parent;
    _treeController = TreeController<SettingsCategory>(
      initiallyExpanded: parent == null
          ? const <SettingsCategory>[]
          : <SettingsCategory>[parent],
    );
    _compactBehavior = _SettingsTreeCompactBehavior(
      isCompact: !widget.isExtended,
      onToggle: widget.onToggleExtended,
    );
  }

  @override
  void didUpdateWidget(covariant SettingsNavigationRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _compactBehavior.update(
      isCompact: !widget.isExtended,
      onToggle: widget.onToggleExtended,
    );
  }

  @override
  void dispose() {
    _compactBehavior.dispose();
    _treeController.dispose();
    super.dispose();
  }

  TreeNode<SettingsCategory> _buildNode(SettingsCategory category) {
    return TreeNode<SettingsCategory>(
      value: category,
      label: category.label,
      icon: category == widget.selectedCategory
          ? category.selectedIcon
          : category.icon,
      canSelect: !category.hasChildren,
      children: category.children.map(_buildNode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tree<SettingsCategory>(
      roots: SettingsCategory.topLevel.map(_buildNode).toList(growable: false),
      selected: widget.selectedCategory,
      controller: _treeController,
      compactBehavior: _compactBehavior,
      onSelected: widget.onCategorySelected,
      layout: const TreeLayout(
        expandedWidth: 280,
        compactWidth: 72,
        indent: 20,
        compactIndent: 6,
      ),
      header: widget.isExtended ? const _SettingsHeader() : null,
      footer: _SettingsBackButton(
        isExtended: widget.isExtended,
        onBack: widget.onBack,
      ),
    );
  }
}

final class _SettingsTreeCompactBehavior extends TreeCompactBehavior {
  _SettingsTreeCompactBehavior({
    required bool isCompact,
    required VoidCallback onToggle,
  })  : _isCompact = isCompact,
        _onToggle = onToggle;

  bool _isCompact;
  VoidCallback _onToggle;

  @override
  bool get isCompact => _isCompact;

  void update({
    required bool isCompact,
    required VoidCallback onToggle,
  }) {
    _isCompact = isCompact;
    _onToggle = onToggle;
  }

  @override
  void toggle() => _onToggle();
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: const Text(
        "SETTINGS",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
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
                key: const ValueKey<String>("settings-navigation-back"),
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
                key: const ValueKey<String>("settings-navigation-back"),
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                tooltip: "Back",
              ),
            ),
    );
  }
}
