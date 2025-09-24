import "package:flutter/material.dart";
import "package:chenron/features/create/folder/pages/create_folder.dart";
import "package:chenron/features/create/link/pages/create_link.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/settings/pages/configuration.dart";
import "package:chenron/features/dashboard/pages/dashboard.dart";

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
    page: ConfigPage(),
  ),
  viewer(
    icon: Icons.view_list_outlined,
    selectedIcon: Icons.view_list,
    label: "Viewer",
    page: Viewer(),
  ),
  createFolder(
    icon: Icons.create_new_folder_outlined,
    selectedIcon: Icons.create_new_folder,
    label: "Add Folder",
    page: CreateFolderPage(),
  ),
  createLink(
    icon: Icons.add_link,
    selectedIcon: Icons.link,
    label: "Add Link",
    page: CreateLinkPage(),
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