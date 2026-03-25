import "package:flutter/material.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/features/shell/ui/sections/navigation_section.dart";
import "package:chenron/features/shell/ui/sections/appbar_section.dart";
import "package:chenron/features/settings/models/settings_category.dart";
import "package:chenron/features/settings/pages/configuration.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/activity_log/pages/activity_log_page.dart";
import "package:database/database.dart";

class CurrentPageBuilder extends StatelessWidget {
  final AppPage currentPage;
  final NavigationSection currentSection;
  final SearchFilter searchFilter;
  final VoidCallback onClose;
  final VoidCallback onSaved;
  final SettingsCategory settingsCategory;
  final AppDatabase? database;

  const CurrentPageBuilder({
    super.key,
    required this.currentPage,
    required this.currentSection,
    required this.searchFilter,
    required this.onClose,
    required this.onSaved,
    required this.settingsCategory,
    this.database,
  });

  @override
  Widget build(BuildContext context) {
    // If in a create flow, show that page
    if (currentPage.isCreateFlow) {
      return currentPage.getPage(
        onClose: onClose,
        onSaved: onSaved,
        searchFilter: searchFilter,
      );
    }

    // If on settings page, show settings with selected category
    if (currentPage == AppPage.settings) {
      return ConfigPage(selectedCategory: settingsCategory);
    }

    // Activity log page
    if (currentPage == AppPage.activityLog && database != null) {
      return ActivityLogPage(database: database!);
    }

    // Otherwise, show the current section's page
    if (currentSection == NavigationSection.viewer) {
      return Viewer(searchFilter: searchFilter);
    }

    return currentSection.page;
  }
}
