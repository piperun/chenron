import 'package:flutter/material.dart';
// Keep existing imports for pages
import "package:chenron/features/create/folder/pages/create_folder.dart";
import "package:chenron/features/create/link/pages/create_link.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/settings/pages/configuration.dart";
import "package:chenron/features/dashboard/pages/dashboard.dart";
import 'package:chenron/locator.dart';
import 'package:chenron/utils/logger.dart';

enum NavigationSection {
  dashboard(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: "Dashboard",
    page: DashBoard(padding: 16),
  ),
  settings(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: "Settings",
    page: ConfigPage(), // ConfigPage remains
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

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  NavigationSection _selectedSection = NavigationSection.dashboard;
  bool _isExtended = true;

  final List<NavigationRailDestination> _destinations = NavigationSection.values
      .map((section) => section.toDestination())
      .toList();

  Future<bool> _showDiscardDialog(BuildContext context) async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Discard Unsaved Changes?'),
        content: const Text(
            'You have unsaved changes on the Settings page. Do you want to discard them and navigate away?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Stay
            child: const Text('Stay'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true), // Discard
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return shouldDiscard ?? false; // Return false if dialog dismissed otherwise
  }

  void _navigateToCreate(BuildContext context, String type) {
    // Consider making these routes named routes for better management
    switch (type) {
      case "folder":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateFolderPage()),
        );
        break;
      case "document":
        loggerGlobal.warning(
            "RootPage", "Document creation not implemented yet.");
        // TODO: Add document creation navigation
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Document creation coming soon!")));
        break;
      case "link":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateLinkPage()),
        );
        break;
      default:
        loggerGlobal.warning("RootPage", "Unknown creation type: $type");
        break;
    }
  }

  void _onDestinationSelected(int index) {
    final newSection = NavigationSection.values[index];

    // Prevent navigating to the same section again
    if (newSection == _selectedSection) {
      loggerGlobal.fine("RootPage",
          "Already on section: ${newSection.label}. Ignoring selection.");
      return;
    }

    loggerGlobal.fine(
        "RootPage", "Navigating directly to ${newSection.label}.");
    setState(() => _selectedSection = newSection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Show the label of the currently selected section
        title: Text(_selectedSection.label),
        actions: [
          // Add tooltips for accessibility
          IconButton(
            tooltip: "Add Link",
            icon: const Icon(Icons.link),
            onPressed: () => _navigateToCreate(context, "link"),
          ),
          IconButton(
            tooltip: "Add Document",
            icon: const Icon(Icons.description),
            onPressed: () => _navigateToCreate(context, "document"),
          ),
          IconButton(
            tooltip: "Add Folder",
            icon: const Icon(Icons.create_new_folder),
            onPressed: () => _navigateToCreate(context, "folder"),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: _isExtended,
            minExtendedWidth: 180,
            selectedIndex: _selectedSection.index,
            onDestinationSelected: _onDestinationSelected,
            leading: IconButton(
              tooltip:
                  _isExtended ? "Collapse Navigation" : "Expand Navigation",
              icon: Icon(_isExtended ? Icons.menu_open : Icons.menu),
              onPressed: () => setState(() => _isExtended = !_isExtended),
            ),
            destinations: _destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _selectedSection.page),
        ],
      ),
    );
  }
}
