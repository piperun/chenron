import "package:flutter/material.dart";
// Keep existing imports
import "package:chenron/features/create/folder/pages/create_folder.dart";
import "package:chenron/features/create/link/pages/create_link.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/settings/settings_page.dart";
import "package:chenron/features/folder/view/pages/folder_viewer.dart";
import "package:chenron/pages/home/homepage.dart";

enum NavigationSection {
  dashboard(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: "Dashboard",
    page: HomePage(padding: 16),
  ),
  folders(
    icon: Icons.folder_outlined,
    selectedIcon: Icons.folder,
    label: "Folders",
    page: FolderViewer(),
  ),
  settings(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: "Settings",
    page: SettingsPage(),
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

  // Add this field to cache the destinations
  final List<NavigationRailDestination> _destinations = NavigationSection.values
      .map((section) => section.toDestination())
      .toList();

  void _navigateToCreate(BuildContext context, String type) {
    switch (type) {
      case "folder":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateFolderPage()),
        );
        break;
      case "document":
        // Add document creation navigation
        break;
      case "link":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateLinkPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedSection.label),
        actions: [
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
            onDestinationSelected: (index) {
              setState(
                  () => _selectedSection = NavigationSection.values[index]);
            },
            leading: IconButton(
              icon:
                  Icon(_isExtended ? Icons.chevron_left : Icons.chevron_right),
              onPressed: () => setState(() => _isExtended = !_isExtended),
            ),
            // Use the cached destinations list instead
            destinations: _destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _selectedSection.page),
        ],
      ),
    );
  }
}
