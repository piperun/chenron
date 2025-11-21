import "package:flutter/material.dart";
import "dart:async" show unawaited;
import "package:chenron/shared/search/searchbar.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/shared/patterns/include_options.dart";
import "package:chenron/features/shell/widgets/add_item_modal.dart";
import "package:chenron/features/shell/ui/sections/navigation_section.dart";
import "package:chenron/features/shell/ui/sections/appbar_section.dart";
import "package:chenron/features/shell/ui/folders_navigation_rail.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/utils/logger.dart";
import "package:chenron/shared/ui/dark_mode.dart";
import "package:signals/signals.dart";

/// Global signal for the main search filter, accessible from anywhere
final globalSearchFilterSignal = signal<SearchFilter?>(null);

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AppPage _currentPage = AppPage.dashboard;
  AppPage? _previousPage;
  bool _isExtended = true;
  String? _selectedFolderId;
  NavigationSection _currentSection = NavigationSection.viewer;
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
      _currentPage = _previousPage ?? AppPage.dashboard;
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
        _currentPage = AppPage.dashboard; // Default page
      }
    });
  }

  void _onFolderSelected(String folderId) {
    loggerGlobal.fine("RootPage", "Folder selected: $folderId");

    // Navigate to the FolderViewerPage to show folder contents
    unawaited(Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FolderViewerPage(folderId: folderId),
      ),
    ));
  }

  void _navigateToSettings() {
    setState(() => _currentPage = AppPage.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _AppBar(
        onSettingsPressed: _navigateToSettings,
        searchFilter: _searchFilter,
        currentSection: _currentSection,
        onSectionSelected: _onSectionSelected,
      ),
      body: Row(
        children: [
          FoldersNavigationRail(
            selectedFolderId: _selectedFolderId,
            onFolderSelected: _onFolderSelected,
            isExtended: _isExtended,
            onToggleExtended: () => setState(() => _isExtended = !_isExtended),
            onAddPressed: _showCreateModal,
            showSyncFeatures: false,
            showPlanInfo: false,
            showQuotaBar: false,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: KeyedSubtree(
                key: ValueKey(_currentPage),
                child: _buildCurrentPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    // If in a create flow, show that page
    if (_currentPage.isCreateFlow) {
      return _currentPage.getPage(
        onClose: _returnToPreviousPage,
        onSaved: _handleSaved,
        searchFilter: _searchFilter,
      );
    }

    // If on settings page, show settings
    if (_currentPage == AppPage.settings) {
      return _currentPage.getPage(
        onClose: _returnToPreviousPage,
        onSaved: _handleSaved,
        searchFilter: _searchFilter,
      );
    }

    // Otherwise, show the current section's page
    if (_currentSection == NavigationSection.viewer) {
      return Viewer(searchFilter: _searchFilter);
    }

    return _currentSection.page;
  }

  void _handleSaved() {
    // Return to previous page
    _returnToPreviousPage();

    // Show success snackbar with "Add Another" action
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✓ Item saved successfully"),
          action: SnackBarAction(
            label: "Add Another",
            onPressed: _showCreateModal,
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

// AppBar Component
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsPressed;
  final SearchFilter searchFilter;
  final NavigationSection currentSection;
  final Function(NavigationSection) onSectionSelected;

  const _AppBar({
    required this.onSettingsPressed,
    required this.searchFilter,
    required this.currentSection,
    required this.onSectionSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: GlobalSearchBar(
                  externalController: searchFilter.controller,
                ),
              ),
            ),
          ),
          // Visual separator after search
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: 1,
            height: 32,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          // Custom styled button group
          _SectionToggle(
            currentSection: currentSection,
            onSectionSelected: onSectionSelected,
          ),
        ],
      ),
      actions: [
        // Visual separator before actions
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          width: 1,
          height: 32,
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
        const DarkModeToggle(),
        IconButton(
          tooltip: "Settings",
          icon: const Icon(Icons.settings_outlined),
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }
}

// Custom Section Toggle Widget
class _SectionToggle extends StatelessWidget {
  final NavigationSection currentSection;
  final Function(NavigationSection) onSectionSelected;

  const _SectionToggle({
    required this.currentSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: NavigationSection.values.map((section) {
          final isSelected = section == currentSection;
          return _SectionButton(
            section: section,
            isSelected: isSelected,
            onPressed: () => onSectionSelected(section),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionButton extends StatelessWidget {
  final NavigationSection section;
  final bool isSelected;
  final VoidCallback onPressed;

  const _SectionButton({
    required this.section,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? section.selectedIcon : section.icon,
                size: 18,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                section.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
