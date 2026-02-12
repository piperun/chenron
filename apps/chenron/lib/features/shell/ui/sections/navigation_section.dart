import "package:flutter/material.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/statistics/pages/statistics_page.dart";

enum NavigationSection {
  statistics(
    icon: Icons.analytics_outlined,
    selectedIcon: Icons.analytics,
    label: "Statistics",
    page: StatisticsPage(padding: 16),
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

