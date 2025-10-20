// Navigation sections that appear in the sidebar

import "package:chenron/features/dashboard/pages/dashboard.dart";
import "package:chenron/features/settings/pages/configuration.dart";
import "package:chenron/features/shell/ui/sections/navigation_section.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/create/link/pages/create_link.dart";
import "package:chenron/features/create/folder/pages/create_folder.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:flutter/material.dart";

enum AppPage {
  dashboard(NavigationSection.dashboard),
  viewer(NavigationSection.viewer),
  createLink(null),
  createFolder(null),
  settings(null);

  final NavigationSection? navSection;
  const AppPage(this.navSection);

  /// Returns true if this page is a temporary create flow
  bool get isCreateFlow {
    return this == AppPage.createLink || this == AppPage.createFolder;
  }

  Widget getPage({
    VoidCallback? onClose,
    VoidCallback? onSaved,
    SearchFilter? searchFilter,
  }) {
    switch (this) {
      case AppPage.dashboard:
        return const DashBoard(padding: 16);
      case AppPage.viewer:
        return Viewer(searchFilter: searchFilter);
      case AppPage.createLink:
        return CreateLinkPage(
          hideAppBar: true,
          onClose: onClose,
          onSaved: onSaved,
        );
      case AppPage.createFolder:
        return CreateFolderPage(
          hideAppBar: true,
          onClose: onClose,
          onSaved: onSaved,
        );
      case AppPage.settings:
        return const ConfigPage();
    }
  }
}
