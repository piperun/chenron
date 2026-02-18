import "package:flutter/material.dart";
import "package:chenron/shared/search/searchbar.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/features/shell/ui/sections/appbar_section.dart";
import "package:chenron/shared/ui/dark_mode.dart";

class ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsPressed;
  final VoidCallback? onBack;
  final SearchFilter searchFilter;
  final AppPage currentPage;

  const ShellAppBar({
    super.key,
    required this.onSettingsPressed,
    required this.searchFilter,
    required this.currentPage,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    if (currentPage.isMainView) {
      return _buildMainAppBar();
    }
    return _buildContextualAppBar(context);
  }

  AppBar _buildMainAppBar() {
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

  AppBar _buildContextualAppBar(BuildContext context) {
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
