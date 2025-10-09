// Navigation sections that appear in the sidebar

import "package:chenron/features/dashboard/pages/dashboard.dart";
import "package:chenron/features/settings/pages/configuration.dart";
import "package:chenron/features/shell/ui/sections/navigation_section.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:flutter/material.dart";

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
