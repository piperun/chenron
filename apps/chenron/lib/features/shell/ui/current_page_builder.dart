import "package:flutter/material.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/features/shell/ui/sections/navigation_section.dart";
import "package:chenron/features/shell/ui/sections/appbar_section.dart";
import "package:chenron/features/settings/models/settings_category.dart";
import "package:chenron/features/settings/pages/configuration.dart";
import "package:chenron/features/viewer/pages/viewer.dart";

class CurrentPageBuilder extends StatelessWidget {
  final AppPage currentPage;
  final NavigationSection currentSection;
  final SearchFilter searchFilter;
  final VoidCallback onClose;
  final VoidCallback onSaved;
  final SettingsCategory settingsCategory;

  const CurrentPageBuilder({
    super.key,
    required this.currentPage,
    required this.currentSection,
    required this.searchFilter,
    required this.onClose,
    required this.onSaved,
    required this.settingsCategory,
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

    // Otherwise, show the current section's page
    if (currentSection == NavigationSection.viewer) {
      return Viewer(searchFilter: searchFilter);
    }

    return currentSection.page;
  }
}
