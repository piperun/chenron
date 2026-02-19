import "package:flutter/material.dart";
import "dart:async";
import "package:chenron/shared/constants/durations.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:core/patterns/include_options.dart";
import "package:chenron/features/shell/widgets/add_item_modal.dart";
import "package:chenron/features/shell/ui/sections/navigation_section.dart";
import "package:chenron/features/shell/ui/sections/appbar_section.dart";
import "package:chenron/features/shell/ui/folders_navigation_rail.dart";
import "package:chenron/features/shell/ui/shell_app_bar.dart";
import "package:chenron/features/shell/ui/current_page_builder.dart";
import "package:chenron/features/settings/models/settings_category.dart";
import "package:chenron/features/settings/ui/settings_navigation_rail.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:app_logger/app_logger.dart";
import "package:signals/signals.dart";

/// Global signal for the main search filter, accessible from anywhere
final globalSearchFilterSignal = signal<SearchFilter?>(null);

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AppPage _currentPage = AppPage.statistics;
  AppPage? _previousPage;
  bool _isExtended = true;
  String? _selectedFolderId;
  NavigationSection _currentSection = NavigationSection.viewer;
  SettingsCategory _settingsCategory = SettingsCategory.defaultSelection;
  late final SearchFilter _searchFilter;

  @override
  void initState() {
    super.initState();
    // Create search filter without debounce for instant local filtering
    // GlobalSearchBar has its own debouncer for database suggestions
    _searchFilter = SearchFilter(
      features: const IncludeOptions.empty(),
    );
    _searchFilter.setup();
    // Store in global signal for external access
    globalSearchFilterSignal.value = _searchFilter;
  }

  @override
  void dispose() {
    globalSearchFilterSignal.value = null;
    _searchFilter.dispose();
    super.dispose();
  }

  void _showCreateModal() {
    unawaited(showDialog(
      context: context,
      builder: (context) => AddItemModal(
        onTypeSelected: _navigateToCreatePage,
      ),
    ));
  }

  void _navigateToCreatePage(ItemType type) {
    setState(() {
      _previousPage = _currentPage;
      _currentPage = switch (type) {
        ItemType.link => AppPage.createLink,
        ItemType.folder => AppPage.createFolder,
        ItemType.document =>
          AppPage.createFolder, // TODO: Update when document page exists
      };
    });
  }

  void _returnToPreviousPage() {
    setState(() {
      _currentPage = _previousPage ?? AppPage.statistics;
      _previousPage = null;
    });
  }

  void _onSectionSelected(NavigationSection section) {
    if (_currentSection == section && _currentPage != AppPage.settings) {
      loggerGlobal.fine(
        "RootPage",
        "Already on section: ${section.label}. Ignoring selection.",
      );
      return;
    }

    loggerGlobal.fine("RootPage", "Navigating to ${section.label}.");
    setState(() {
      _currentSection = section;
      // Reset to the default page for the section when navigating from settings
      if (_currentPage == AppPage.settings || _currentPage.isCreateFlow) {
        _currentPage = AppPage.statistics; // Default page
      }
    });
  }

  void _onFolderSelected(String folderId) {
    loggerGlobal.fine("RootPage", "Folder selected: $folderId");

    final presenter = viewerViewModelSignal.value;

    // Navigate to the FolderViewerPage to show folder contents
    unawaited(Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FolderViewerPage(
          folderId: folderId,
          onItemTap: presenter.handleFolderItemTap,
          onTagSearch: (query) {
            _searchFilter.controller.value = query;
            _searchFilter.controller.onSubmitted?.call(query);
          },
        ),
      ),
    ));
  }

  void _navigateToSettings() {
    setState(() {
      _previousPage = _currentPage;
      _currentPage = AppPage.settings;
      _settingsCategory = SettingsCategory.defaultSelection;
    });
  }

  void _returnFromSettings() {
    setState(() {
      _currentPage = _previousPage ?? AppPage.statistics;
      _previousPage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: ShellAppBar(
        currentPage: _currentPage,
        onSettingsPressed: _navigateToSettings,
        onBack: _returnToPreviousPage,
        searchFilter: _searchFilter,
      ),
      body: Row(
        children: [
          if (_currentPage == AppPage.settings)
            SettingsNavigationRail(
              selectedCategory: _settingsCategory,
              onCategorySelected: (cat) =>
                  setState(() => _settingsCategory = cat),
              isExtended: _isExtended,
              onToggleExtended: () =>
                  setState(() => _isExtended = !_isExtended),
              onBack: _returnFromSettings,
            )
          else
            FoldersNavigationRail(
              selectedFolderId: _selectedFolderId,
              onFolderSelected: _onFolderSelected,
              isExtended: _isExtended,
              onToggleExtended: () =>
                  setState(() => _isExtended = !_isExtended),
              onAddPressed: _showCreateModal,
              currentSection: _currentSection,
              onSectionSelected: _onSectionSelected,
            ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: kDefaultAnimationDuration,
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: KeyedSubtree(
                key: ValueKey(_currentPage.name),
                child: CurrentPageBuilder(
                  currentPage: _currentPage,
                  currentSection: _currentSection,
                  searchFilter: _searchFilter,
                  onClose: _returnToPreviousPage,
                  onSaved: _handleSaved,
                  settingsCategory: _settingsCategory,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSaved() {
    // Return to previous page
    _returnToPreviousPage();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Item saved"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

