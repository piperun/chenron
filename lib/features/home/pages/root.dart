import 'package:flutter/material.dart';
// Keep existing imports for pages
import "package:chenron/features/create/folder/pages/create_folder.dart";
import "package:chenron/features/create/link/pages/create_link.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/settings/pages/configuration.dart";
import "package:chenron/pages/home/homepage.dart"; // Assuming this is the correct path for HomePage
// --- Add these imports ---
import 'package:chenron/features/settings/controller/config_controller.dart'; // Import the ConfigController
import 'package:chenron/locator.dart'; // Import locator to get the controller
import 'package:chenron/utils/logger.dart';

enum NavigationSection {
  dashboard(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: "Dashboard",
    // Ensure HomePage constructor matches if it takes arguments
    page: HomePage(padding: 16), // Assuming HomePage takes padding
  ),
  settings(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: "Settings",
    page: ConfigPage(), // ConfigPage is now simpler
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
  // Get the ConfigController instance
  final ConfigController _configController = locator.get<ConfigController>();

  NavigationSection _selectedSection = NavigationSection.dashboard;
  bool _isExtended = true;

  final List<NavigationRailDestination> _destinations = NavigationSection.values
      .map((section) => section.toDestination())
      .toList();

  // --- Updated Helper for showing the discard dialog ---
  // This now *only* shows the dialog UI and returns the user's choice.
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
  // --- End Updated Helper ---

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

  // --- Modified onDestinationSelected using ConfigController ---
  Future<void> _onDestinationSelected(int index) async {
    final newSection = NavigationSection.values[index];

    // Prevent navigating to the same section again
    if (newSection == _selectedSection) {
      loggerGlobal.fine("RootPage",
          "Already on section: ${newSection.label}. Ignoring selection.");
      return;
    }

    // Check if we are currently on the settings page AND there are unsaved changes
    if (_selectedSection == NavigationSection.settings &&
        _configController.hasUnsavedChanges()) {
      // Use controller method
      loggerGlobal.info("RootPage",
          "Settings has unsaved changes, prompting user before navigating away.");

      final confirmDiscard = await _showDiscardDialog(context);

      if (confirmDiscard) {
        loggerGlobal.info("RootPage",
            "User confirmed discard. Resetting ConfigController state and navigating.");
        // Reset the controller's state by re-initializing it
        await _configController.initialize();
        // Now navigate
        setState(() => _selectedSection = newSection);
      } else {
        loggerGlobal.info(
            "RootPage", "User cancelled discard. Staying on Settings page.");
        // Do nothing, stay on the current section
      }
    } else {
      // Navigate immediately if not on settings or no unsaved changes
      loggerGlobal.fine(
          "RootPage", "Navigating directly to ${newSection.label}.");
      setState(() => _selectedSection = newSection);
    }
  }
  // --- End Modified ---

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
            onDestinationSelected:
                _onDestinationSelected, // Use updated handler
            // Use a more descriptive tooltip for the expand/collapse button
            leading: IconButton(
              tooltip:
                  _isExtended ? "Collapse Navigation" : "Expand Navigation",
              icon: Icon(
                  _isExtended ? Icons.menu_open : Icons.menu), // Use menu icons
              onPressed: () => setState(() => _isExtended = !_isExtended),
            ),
            destinations: _destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Display the page associated with the selected section
          Expanded(child: _selectedSection.page),
        ],
      ),
    );
  }
}
