import "package:chenron/features/create/folder/pages/create_folder.dart";
import "package:chenron/features/create/link/pages/create_link.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:flutter/material.dart";
import "package:chenron/features/settings/settings_page.dart";
import "package:chenron/features/folder/create/pages/create.dart";
import "package:chenron/features/folder/view/pages/folder_viewer.dart";
import "package:chenron/pages/home/homepage.dart";

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;
  bool _isExtended = true;

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: "Dashboard",
    ),
    NavigationDestination(
      icon: Icon(Icons.folder_outlined),
      selectedIcon: Icon(Icons.folder),
      label: "Folders",
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: "Settings",
    ),
    NavigationDestination(
      icon: Icon(Icons.view_list_outlined),
      selectedIcon: Icon(Icons.view_list),
      label: "Viewer",
    ),
  ];

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return const HomePage(padding: 16);
      case 1:
        return const FolderViewer();
      case 2:
        return const SettingsPage();
      case 3:
        return const Viewer();
      default:
        return const HomePage(padding: 16);
    }
  }

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
        title: Text(_destinations[_selectedIndex].label),
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
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() => _selectedIndex = index);
            },
            leading: IconButton(
              icon: Icon(
                _isExtended ? Icons.chevron_left : Icons.chevron_right,
              ),
              onPressed: () {
                setState(() => _isExtended = !_isExtended);
              },
            ),
            destinations: _destinations.map((destination) {
              return NavigationRailDestination(
                icon: destination.icon,
                selectedIcon: destination.selectedIcon,
                label: Text(destination.label),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _getPage(),
          ),
        ],
      ),
    );
  }
}

class NavigationDestination {
  final Widget icon;
  final Widget selectedIcon;
  final String label;

  const NavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
