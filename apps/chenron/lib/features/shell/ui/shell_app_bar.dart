import "package:flutter/material.dart";
import "package:chenron/shared/search/searchbar.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/features/shell/ui/sections/appbar_section.dart";
import "package:chenron/shared/ui/dark_mode.dart";

class ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsPressed;
  final VoidCallback onActivityLogPressed;
  final VoidCallback? onBack;
  final SearchFilter searchFilter;
  final AppPage currentPage;

  const ShellAppBar({
    super.key,
    required this.onSettingsPressed,
    required this.onActivityLogPressed,
    required this.searchFilter,
    required this.currentPage,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    if (currentPage.isMainView) {
      return _MainAppBar(
        searchFilter: searchFilter,
        onActivityLogPressed: onActivityLogPressed,
        onSettingsPressed: onSettingsPressed,
      );
    }
    return _ContextualAppBar(
      currentPage: currentPage,
      onBack: onBack,
    );
  }
}

class _MainAppBar extends StatelessWidget {
  final SearchFilter searchFilter;
  final VoidCallback onActivityLogPressed;
  final VoidCallback onSettingsPressed;

  const _MainAppBar({
    required this.searchFilter,
    required this.onActivityLogPressed,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: GlobalSearchBar(
          externalController: searchFilter.controller,
        ),
      ),
      actions: [
        IconButton(
          tooltip: "Activity log",
          icon: const Icon(Icons.text_snippet_outlined),
          onPressed: onActivityLogPressed,
        ),
        const DarkModeToggle(),
        IconButton(
          tooltip: "Settings",
          icon: const Icon(Icons.settings_outlined),
          onPressed: onSettingsPressed,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _ContextualAppBar extends StatelessWidget {
  final AppPage currentPage;
  final VoidCallback? onBack;

  const _ContextualAppBar({
    required this.currentPage,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: "Back",
        onPressed: onBack,
      ),
      title: Text(
        currentPage.label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: const [
        DarkModeToggle(),
      ],
    );
  }
}
