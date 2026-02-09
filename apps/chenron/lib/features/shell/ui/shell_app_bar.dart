import "package:flutter/material.dart";
import "package:chenron/shared/search/searchbar.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/features/shell/ui/sections/navigation_section.dart";
import "package:chenron/features/shell/ui/section_toggle.dart";
import "package:chenron/shared/ui/dark_mode.dart";

class ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsPressed;
  final SearchFilter searchFilter;
  final NavigationSection currentSection;
  final void Function(NavigationSection) onSectionSelected;

  const ShellAppBar({
    super.key,
    required this.onSettingsPressed,
    required this.searchFilter,
    required this.currentSection,
    required this.onSectionSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: GlobalSearchBar(
                  externalController: searchFilter.controller,
                ),
              ),
            ),
          ),
          // Visual separator after search
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: 1,
            height: 32,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          // Custom styled button group
          SectionToggle(
            currentSection: currentSection,
            onSectionSelected: onSectionSelected,
          ),
        ],
      ),
      actions: [
        // Visual separator before actions
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          width: 1,
          height: 32,
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
        const DarkModeToggle(),
        IconButton(
          tooltip: "Settings",
          icon: const Icon(Icons.settings_outlined),
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }
}
