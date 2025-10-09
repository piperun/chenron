import "package:flutter/material.dart";
import "package:chenron/features/create/folder/pages/create_folder.dart";
import "package:chenron/features/create/link/pages/create_link.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/settings/pages/configuration.dart";
import "package:chenron/features/dashboard/pages/dashboard.dart";
import "package:chenron/shared/search/searchbar.dart";
import "package:chenron/utils/logger.dart";

// Navigation sections that appear in the sidebar
enum NavigationSection {
  dashboard(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: "Dashboard",
    page: DashBoard(padding: 16),
  ),
  viewer(
    icon: Icons.view_list_outlined,
    selectedIcon: Icons.view_list,
    label: "Viewer",
    page: Viewer(),
  );

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget page;

  const NavigationSection({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.page,
  });

  NavigationRailDestination toDestination() => NavigationRailDestination(
        icon: Icon(icon),
        selectedIcon: Icon(selectedIcon),
        label: Text(label),
      );
}

// Enum for all possible pages including Settings
enum AppPage {
  dashboard(NavigationSection.dashboard),
  viewer(NavigationSection.viewer),
  settings(null);

  final NavigationSection? navSection;
  const AppPage(this.navSection);

  Widget get page {
    switch (this) {
      case AppPage.dashboard:
        return const DashBoard(padding: 16);
      case AppPage.viewer:
        return const Viewer();
      case AppPage.settings:
        return const ConfigPage();
    }
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AppPage _currentPage = AppPage.dashboard;
  bool _isExtended = true;

  void _showCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CreateBottomSheet(
        onFolderTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateFolderPage()),
          );
        },
        onLinkTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateLinkPage()),
          );
        },
        onDocumentTap: () {
          Navigator.pop(context);
          _showDocumentComingSoon();
        },
      ),
    );
  }

  void _showDocumentComingSoon() {
    loggerGlobal.warning("RootPage", "Document creation not implemented yet.");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Document creation coming soon!")),
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
            onAddPressed: _showCreateBottomSheet,
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

// Create Bottom Sheet Component
class _CreateBottomSheet extends StatelessWidget {
  final VoidCallback onFolderTap;
  final VoidCallback onLinkTap;
  final VoidCallback onDocumentTap;

  const _CreateBottomSheet({
    required this.onFolderTap,
    required this.onLinkTap,
    required this.onDocumentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Create New",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Choose what you'd like to add",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          _CreateOption(
            icon: Icons.create_new_folder_outlined,
            title: "Folder",
            subtitle: "Create a new folder",
            onTap: onFolderTap,
          ),
          _CreateOption(
            icon: Icons.add_link,
            title: "Link",
            subtitle: "Add a link or bookmark",
            onTap: onLinkTap,
          ),
          _CreateOption(
            icon: Icons.description_outlined,
            title: "Document",
            subtitle: "Upload a document",
            onTap: onDocumentTap,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Create Option Component
class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 32),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
