import "package:flutter/material.dart";
import "package:chenron/shared/search/searchbar.dart";
import "package:chenron/features/shell/widgets/add_item_modal.dart";
import "package:chenron/features/shell/ui/sections/navigation_section.dart";
import "package:chenron/features/shell/ui/sections/appbar_section.dart";
import "package:chenron/utils/logger.dart";
import "package:chenron/shared/ui/dark_mode.dart";

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AppPage _currentPage = AppPage.dashboard;
  bool _isExtended = true;

  void _showCreateModal() {
    showDialog(
      context: context,
      builder: (context) => const AddItemModal(),
    );
  }

  void _onDestinationSelected(int index) {
    final newSection = NavigationSection.values[index];
    final newPage = AppPage.values.firstWhere(
      (page) => page.navSection == newSection,
    );

    if (_currentPage == newPage) {
      loggerGlobal.fine(
        "RootPage",
        "Already on page: ${newSection.label}. Ignoring selection.",
      );
      return;
    }

    loggerGlobal.fine("RootPage", "Navigating to ${newSection.label}.");
    setState(() => _currentPage = newPage);
  }

  void _navigateToSettings() {
    setState(() => _currentPage = AppPage.settings);
  }

  int? get _selectedNavIndex {
    final navSection = _currentPage.navSection;
    if (navSection == null) return null;
    return NavigationSection.values.indexOf(navSection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _AppBar(
        onSettingsPressed: _navigateToSettings,
      ),
      body: Row(
        children: [
          _NavigationSidebar(
            isExtended: _isExtended,
            selectedIndex: _selectedNavIndex,
            onDestinationSelected: _onDestinationSelected,
            onToggleExtended: () => setState(() => _isExtended = !_isExtended),
            onAddPressed: _showCreateModal,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _currentPage.page),
        ],
      ),
    );
  }
}

// AppBar Component
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsPressed;

  const _AppBar({required this.onSettingsPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: GlobalSearchBar(),
        ),
      ),
      actions: [
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

// Navigation Sidebar Component
class _NavigationSidebar extends StatelessWidget {
  final bool isExtended;
  final int? selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onToggleExtended;
  final VoidCallback onAddPressed;

  const _NavigationSidebar({
    required this.isExtended,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onToggleExtended,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: isExtended,
      minExtendedWidth: 180,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      leading: IconButton(
        tooltip: isExtended ? "Collapse Navigation" : "Expand Navigation",
        icon: Icon(isExtended ? Icons.menu_open : Icons.menu),
        onPressed: onToggleExtended,
      ),
      destinations: NavigationSection.values
          .map((section) => section.toDestination())
          .toList(),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _AddButton(
              isExtended: isExtended,
              onPressed: onAddPressed,
            ),
          ),
        ),
      ),
    );
  }
}

// Add Button Component
class _AddButton extends StatelessWidget {
  final bool isExtended;
  final VoidCallback onPressed;

  const _AddButton({
    required this.isExtended,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isExtended) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: const Text("Add New"),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: "Add New",
      child: const Icon(Icons.add),
    );
  }
}
