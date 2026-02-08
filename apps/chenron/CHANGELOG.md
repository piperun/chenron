# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

- - -
## chenron-v0.6.2 - 2026-02-08
#### Bug Fixes
- resolve vibe lint warnings and remove stale test driver - (4ed0e9b) - *piperun*

- - -

## chenron-v0.6.1 - 2026-02-08
#### Bug Fixes
- resolve folder editor save and validation bugs - (df5ca22) - *piperun*
#### Refactoring
- rename logger package to app_logger, adjust VEPR log levels - (30d5ae9) - *piperun*

- - -

## chenron-v0.6.0 - 2026-02-08
#### Features
- improve dashboard activity list and search - (3b49b53) - *piperun*
#### Bug Fixes
- propagate folder context and add dbId getter - (fe97640) - *piperun*
- correct type ID off-by-one and default folder lookup - (75d21df) - *piperun*
- replace hardcoded colors with colorScheme values - (ceaefd6) - *piperun*
- eliminate dark mode flicker on app startup - (4d097f3) - *piperun*
#### Refactoring
- move integration tests to test/ as widget tests - (0854e0a) - *piperun*
- migrate app theme layer to new vibe API - (4ffdf55) - *piperun*

- - -

## chenron-v0.5.0 - 2026-02-08
#### Features
- add custom interval picker to backup schedule settings - (68612be) - *piperun*
- add backup schedule settings with startup wiring - (03f16ad) - *piperun*
#### Bug Fixes
- replace hardcoded colors with theme-aware values in item display - (ac3b16f) - *piperun*

- - -

## chenron-v0.4.0 - 2026-02-07
#### Features
- redesign settings page with category sidebar navigation - (774bfdc) - *piperun*
- theme DataGrid with Flutter ColorScheme - (7977341) - *piperun*
#### Bug Fixes
- truncate long tooltip text in ItemTitle to 200 chars - (7c8d5a9) - *piperun*
#### Refactoring
- remove dead showItemsTable from FolderForm - (f292cd1) - *piperun*

- - -

## chenron-v0.3.1 - 2026-02-07
#### Bug Fixes
- folder timestamp/description display and add home navigation to folder viewer - (626cde9) - *piperun*
#### Performance Improvements
- cache futures, fix resource leaks, and memoize expensive operations - (26995c1) - *piperun*
#### Refactoring
- extract ItemDeletionService and folder loading - (e5e87ba) - *piperun*
- extract FolderPersistenceService from CreateFolderPage - (9c77dd5) - *piperun*
- remove dead metadata classes and extract service layers - (55c9b58) - *piperun*

- - -

## chenron-v0.3.0 - 2026-02-07
#### Features
- wire activity tracking service and daily snapshot scheduling - (d4dba45) - *piperun*
- implement analytics dashboard with fl_chart visualizations - (40b03c9) - *piperun*
#### Refactoring
- improve card layout with tag badge overlay and tighter aspect ratio - (787418f) - *piperun*
- resolve all lint issues from stricter analysis configuration - (95ed734) - *piperun*
- fix remaining lint warnings for clean analyze - (e5e6a70) - *piperun*
- remove unnecessary async wrapping from AppDatabase access - (604487d) - *piperun*

- - -

## chenron-v0.2.0 - 2026-02-07
#### Features
- add per-type item count badges to folder sidebar - (4f73830) - *piperun*
#### Bug Fixes
- resolve card grid RenderFlex overflow - (c2ca12e) - *piperun*
- implement document deletion in item handler and viewer model - (411b39a) - *piperun*

- - -

## chenron-v0.1.0 - 2026-02-07
#### Features
- Add unit tests for parseArchiveDate function to validate URL parsing - (49851a3) - *piperun*
- Implement search history functionality in LocalSearchBar and SearchFilter - (d4e0b36) - *piperun*
- Add deprecated_member_use error to analyzer options and skip benchmark tests for explicit execution - (1759297) - *piperun*
- Remove unused TextBase components and related classes to clean up codebase - (4b3dc8d) - *piperun*
- Remove ItemList and TestData classes to streamline codebase - (d1fdec9) - *piperun*
- Add ArchiveOrgClient and options for interacting with the Wayback Machine API - (abdfa21) - *piperun*
- Remove default title parameter from createTestLink method for cleaner API - (db0b8c0) - *piperun*
- Skip validation performance benchmark group for explicit execution - (c0dadc3) - *piperun*
- Refactor _fetchSuggestions method to remove query parameter for improved clarity - (a43a643) - *piperun*
- Implement mock tests for ArchiveOrgClient to simulate various archiving scenarios - (b07ec92) - *piperun*
- Add optional parameters to archiveAndWait method for enhanced flexibility - (b9e1bfc) - *piperun*
- Remove unused tags parameter from insertLinks method in InsertionExtensions - (2a9e29d) - *piperun*
- Remove redundant ignore directive for depend_on_referenced_packages in path_provider_mocks.dart - (981f0b8) - *piperun*
- Refactor database queries to use local variables for improved readability in link tests - (0ba43d8) - *piperun*
- Add avoid-generics-shadowing lint rule, implement date sorting in viewer presenter, and remove unused document model - (f12d960) - *piperun*
- Remove unused import for drift package in create_folder_test - (57f9159) - *piperun*
- Implement date sorting in search filter for improved item ordering - (3cc5d4a) - *piperun*
- Refactor database queries to use local variables for improved readability - (80611c0) - *piperun*
- Refactor database queries to use local variables for improved readability - (8f40269) - *piperun*
- Refactor database test teardown to use local variables for improved readability - (d246f40) - *piperun*
- Implement path provider mocks with comprehensive test coverage - (a681253) - *piperun*
- Add new lint rules to enhance code quality and remove unused path provider mocks - (caca09e) - *piperun*
- Enhance linting rules and add comprehensive directory tests for improved code quality and functionality - (79a8620) - *piperun*
- Add additional lint rules to improve code quality and enforce best practices - (6913c1f) - *piperun*
- Simplify VEPR operations by replacing transaction blocks with run method and updating validation and execution methods - (1022cfa) - *piperun*
- Refactor VEPR operations to use run macro and improve validation methods - (6da7dfd) - *piperun*
- Add await to database setup calls for proper asynchronous handling - (e078aa3) - *piperun*
- Remove obsolete directory test and database operation classes to streamline codebase - (52eaa3e) - *piperun*
- Remove unused directory export to clean up codebase - (4dbb6cd) - *piperun*
- Add changeTheme method to ThemeService for theme management - (66f90ea) - *piperun*
- Remove deprecated parameters in item display components for cleaner code - (4a32c7b) - *piperun*
- Refactor ID generation to a global extension for improved flexibility - (9ed863c) - *piperun*
- Refactor add link tests to use initTestApp for improved setup and consistency - (10c90b5) - *piperun*
- Add ArchiveIsClient and MonolithDownloader for URL archiving functionality - (50617ec) - *piperun*
- Implement navigation rail components including header, quota bar, filter, folder list, and bottom section - (b1f2278) - *piperun*
- Improve test readability by formatting expect statements and updating import paths - (3bb012f) - *piperun*
- Update TestPathProvider formatting for improved readability - (9f53e68) - *piperun*
- Refactor _RootPageState to use _CurrentPageBuilder for improved readability and maintainability - (1f2c695) - *piperun*
- Update custom_lint and other dependencies in pubspec.yaml and pubspec.lock - (0ab3feb) - *piperun*
- Update flutter_lints dependency to version 6.0.0 across multiple packages - (4915b4f) - *piperun*
- Refactor CodeInputField, LinkTableSection, and FolderEditor to use StatelessWidget for improved performance and readability - (00258bf) - *piperun*
- Refactor DataGrid to StatelessWidget, remove unused color.dart, and update dependencies - (3b9c773) - *piperun*
- Add ItemSectionController and CreateFolderNotifier for item management and folder creation - (5adf297) - *piperun*
- Refactor CacheSettings to use state management and integrate file picker for custom cache directory selection - (6439151) - *piperun*
- Add cache directory management to user configurations - (0170b7f) - *piperun*
- add platform_provider package with OS-specific implementations and resources - (a25233d) - *piperun*
- introduce reusable folder form with parent folder selection, tag management, and new item display and folder picker UI components. - (7f24326) - *piperun*
- Enhance Viewer functionality with URL handling and item interaction improvements - (5ad910a) - *piperun*
- Implement item tap handling in FolderViewerPage for improved item interaction - (2d038f1) - *piperun*
- Add itemClickAction to user configuration for customizable item interaction - (73b86da) - *piperun*
- Add FolderFormFields and ItemEditor components for folder management - (6d68b29) - *piperun*
- Implement folder item management, tag filtering, and dedicated viewer UI. - (60d77f7) - *piperun*
- Implement FoldersNavigationRail for improved folder navigation and selection - (6bb0f8b) - *piperun*
- Refactor folder loading logic to include parent folders in FolderViewerPage - (c05eadc) - *piperun*
- Add currentFolderId support to FolderParentSection for improved folder selection - (244a244) - *piperun*
- Enhance Folder Editor to support loading and managing parent folder relationships - (2f6ffe8) - *piperun*
- Add comprehensive tests for FolderForm functionality - (08ad8bb) - *piperun*
- Add integration tests for Folder Editor functionality - (d5804bd) - *piperun*
- Add edit and delete functionality to folder header - (f9fb5a0) - *piperun*
- Introduce DataGrid component and update imports for consistency; enhance tag filter modal UI and tests - (0561e67) - *piperun*
- Add comprehensive tests for TagFilterModal including normal and bulk modes - (91a9845) - *piperun*
- Enhance tag filtering functionality with bulk operations for including and excluding multiple tags - (0130750) - *piperun*
- Refactor tag filter modal to improve active and available tag management with enhanced UI components - (dbb2e63) - *piperun*
- Implement tag filtering functionality with TagFilterState and integrate into search components - (ae9059f) - *piperun*
- Enhance tag filtering with inclusion and exclusion patterns in search queries - (63259ce) - *piperun*
- Update FilterableItemDisplay to use consistent displayModeContext and add optional SearchBarController to GlobalSuggestionBuilder - (ee10caa) - *piperun*
- Introduce LocalSearchBar and SearchBarController for enhanced search functionality with features like debouncing and history management - (ca09a0d) - *piperun*
- Add IncludeOptions class for feature flag management and implement SearchFeatureManager for managing search functionalities - (6fba078) - *piperun*
- Implement search history management with loading, saving, and clearing functionalities - (0aea9c1) - *piperun*
- Add displayModeContext to FilterableItemDisplay for context-specific display mode handling - (fdd4d57) - *piperun*
- Implement responsive grid layout for mobile and desktop - (3cf756d) - *piperun*
- Enhance metadata fetching and caching with improved logging and freshness checks - (c78b7a5) - *piperun*
- Implement viewer item display with card and row layouts - (617a889) - *piperun*
- Enhance metadata fetching logic with improved caching and error handling - (a6b6270) - *piperun*
- Enhance URL tag parsing to include all tags for validation and improve theme registry initialization logic - (f818ab2) - *piperun*
- Implement folder editor functionality with state management and UI components - (b0657f4) - *piperun*
- Refactor ItemMetaRow and ItemInfoModal to use _TimeDisplay for improved time formatting and tooltip support - (ad4bef5) - *piperun*
- Implement link table rendering components including column, row builders, and validation dialog - (8970816) - *piperun*
- Add keyPrefix parameter to input sections for improved widget testing - (ef9f1fb) - *piperun*
- Refactor link table and renderer components for improved structure and consistency - (86652a2) - *piperun*
- Enhance CardSection to accept Text widgets for title and description with styling - (c861139) - *piperun*
- Rewrote link creation with error handling and input validation UI - (1758d1c) - *piperun*
- Add time display format field to user configuration schema and update handling in VEPR - (c601d48) - *piperun*
- Add display settings for time format selection and update user configuration handling - (21f247f) - *piperun*
- Refactor folder and link tag management by consolidating tag sections and removing unused components - (34e2470) - *piperun*
- Implement folder creation functionality with input validation and tagging support - (82cc837) - *piperun*
- Enhance CreateLinkNotifier with bulk entry logging and validation improvements - (23e41eb) - *piperun*
- Implement code input field with validation and error highlighting - (ef04e10) - *piperun*
- Add link update extensions for managing link paths and tags - (a23a6b2) - *piperun*
- Enhance link creation with VEPR pattern and optimize transaction handling - (bee49e9) - *piperun*
- Implement URL parsing and validation services - (298e3a0) - *piperun*
#### Bug Fixes
- Make EditableCodeField selection test more reliable - (e67c482) - *piperun*
- Update all test files to use synchronous AppDatabase access - (18028ae) - *piperun*
- Add missing Future<void> return type to tearDown function in folder_form_test - (d0cd6e8) - *piperun*
- Update validation messages in LinkValidator for clarity and consistency - (c6f26ee) - *piperun*
#### Refactoring
- (**vibe**) merge vibe_core into vibe package - (131788a) - *piperun*
- extract private widget-builder methods into composed widgets - (fe4d9f2) - *piperun*
- Update mock database handler and add folder detail widgets - (3c097e2) - *piperun*
- Update all call sites to use synchronous AppDatabase access - (ec8cf8c) - *piperun*
- Remove Future wrapper from AppDatabase access pattern - (6660293) - *piperun*
- add listener to active search controller for state updates - (4b57bab) - *piperun*
- update workspace dependencies and imports - (4d695d5) - *piperun*
- Update initState to be asynchronous and await _loadDisplayMode for improved initialization - (f61aa2c) - *piperun*
- Use unawaited for asynchronous calls to improve performance and prevent unhandled futures - (0c8c645) - *piperun*
- Use unawaited for asynchronous method calls to improve performance and prevent unhandled futures - (00de167) - *piperun*
- Enhance error handling and logging in link and folder operations for improved stability - (4331311) - *piperun*
- Update methods to return Future<void> for asynchronous operations in database handlers and UI components - (ac5e697) - *piperun*
- Add lint rules for cast_nullable_to_non_nullable and discarded_futures for improved code quality - (f08eadb) - *piperun*
- Improve code readability by formatting and organizing async method calls and variable declarations - (5b94b7c) - *piperun*
- Replace StringContent and MapContent instantiations with const constructors for improved performance - (e388f94) - *piperun*
- Replace asynchronous existence checks with synchronous counterparts for improved performance - (37b5e17) - *piperun*
- Add final keyword to variable declarations for improved readability and consistency - (398ff85) - *piperun*
- Replace async file existence checks with synchronous counterparts for improved performance - (ea18d41) - *piperun*
- Enhance type safety in ThemeModel by adding type casts - (1d0e4b2) - *piperun*
- Optimize directory existence checks and centralize item handling logic - (8a638dc) - *piperun*
- Update color usage in EmptyStateMessage and change launch URL functions to return Future<void> - (216a5fd) - *piperun*
- Clean up Viewer item handling by removing unused imports and improving item initialization - (eb129df) - *piperun*
- Implement ActiveFiltersTab and AvailableTagsTab components for improved tag filtering functionality - (ea433c2) - *piperun*
- Improve code readability by formatting and removing unnecessary print ignores in MainSetup - (9781a58) - *piperun*
- Replace HookWidget with StatefulWidget in Viewer and ViewerContent for improved state management - (f5e1c76) - *piperun*
- Streamline entry validation logic by consolidating parallel and sequential execution paths - (641e0ce) - *piperun*
- Enhance entry validation by introducing configurable validation strategy - (d83d2ad) - *piperun*
- Simplify query construction in ReadDbHandler by utilizing _buildQuery method - (59eff39) - *piperun*
- Update linter rules to enhance code quality and consistency - (7efcde7) - *piperun*
- Update time format selection to use RadioGroup for improved state management - (4ba055f) - *piperun*
- Replace 'withOpacity' with 'withValues' for color adjustments across multiple components - (fac91db) - *piperun*
- Replace 'withOpacity' with 'withValues' for color adjustments in FolderHeader - (281ef31) - *piperun*
- Rearrange properties in FlexThemeBuildConfig for improved clarity and maintainability - (39df7e7) - *piperun*
- Use 'const' constructors for improved performance in various components and tests - (fba733a) - *piperun*
- Remove unused imports across multiple test and implementation files - (d98099f) - *piperun*
- Update import statements to use consistent package paths and double quotes - (8ac3e04) - *piperun*
- Simplify SectionTile constructor by using super.key directly - (8f74174) - *piperun*
- Update deprecated annotations and clean up code formatting for consistency - (0c9f9bd) - *piperun*

- - -

Changelog generated by [cocogitto](https://github.com/cocogitto/cocogitto).