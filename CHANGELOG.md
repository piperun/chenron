# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

- - -
## chenron-v1.13.1 - 2026-05-20
#### Bug Fixes
- (**chenron**) collapse duplicate ChenronDir enum to silence GetIt warning - (acd0dd0) - *piperun*

- - -

## [v1.2.1](https://github.com/piperun/chenron-flutter/compare/48f4c66301952b4bc2f4a98f942c6b05ef45f859..v1.2.1) - 2026-05-20
### Package updates
- [chenron-v1.13.1](apps/chenron) bumped to [chenron-v1.13.1](https://github.com/piperun/chenron-flutter/compare/chenron-v1.13.0..chenron-v1.13.1)
### Global changes

- - -

## chenron-v1.13.0 - 2026-05-20
#### Refactoring
- (**chenron**) hoist metadata fetch + migrate to MetadataService signals - (62c5808) - *piperun*

- - -

## [v1.2.0](https://github.com/piperun/chenron-flutter/compare/48f4c66301952b4bc2f4a98f942c6b05ef45f859..v1.2.0) - 2026-05-20
### Package updates
- [cache_manager-v0.6.0](packages/cache_manager) bumped to [cache_manager-v0.6.0](https://github.com/piperun/chenron-flutter/compare/cache_manager-v0.5.0..cache_manager-v0.6.0)
### Global changes

- - -

## chenron-v1.12.0 - 2026-05-20
#### Features
- (**chenron**) wire statistics charts to ChartPalette + themed tooltips - (80553fe) - *piperun*
- (**chenron**) polish Growth Trend chart tooltip readability - (7b6b158) - *piperun*
#### Bug Fixes
- (**chenron**) improve folder list selected state contrast - (3f92212) - *piperun*
- (**chenron**) theme picker shows honest selection state - (1ec168d) - *piperun*
- (**chenron**) statistics page polish - (b3de25a) - *piperun*
- (**chenron**) satisfy Flutter 3.44 ListTile assertion in search dialogs - (be6f765) - *piperun*
- (**chenron**) wrap bottom-sheet child in Material to satisfy Flutter 3.44 assertion - (7464a99) - *piperun*

- - -

## [v1.2.0](https://github.com/piperun/chenron-flutter/compare/2552bd5c4e19c095c9565d976354476a9968bac7..v1.2.0) - 2026-05-19
### Package updates
- [vibe-v0.2.0](packages/vibe) bumped to [vibe-v0.2.0](https://github.com/piperun/chenron-flutter/compare/vibe-v0.1.1..vibe-v0.2.0)
- [chenron-v1.12.0](apps/chenron) bumped to [chenron-v1.12.0](https://github.com/piperun/chenron-flutter/compare/chenron-v1.11.0..chenron-v1.12.0)
### Global changes
#### Refactoring
- (**cache_manager**) unify logging on app_logger - ([0988b01](https://github.com/piperun/chenron-flutter/commit/0988b0137e65d69db27d651f125f4b429c92510c)) - [@piperun](https://github.com/piperun)

- - -

## chenron-v1.11.0 - 2026-05-19
#### Features
- (**chenron**) auto-purge activity log on startup with retention setting - (2f0d4cb) - *piperun*
- (**chenron**) add safeWatch + safeAwait error-handling helpers - (16900d0) - *piperun*
#### Bug Fixes
- (**chenron**) reuse the lifecycle ConfigDatabase in _processArchiveQueue - (172fb63) - *piperun*
- (**chenron**) close the 3 remaining stream-error audit OPEN sites - (eb2e8aa) - *piperun*
- (**chenron**) wrap MISSING db awaits with safeAwait across page-level handlers - (c023d97) - *piperun*
- (**chenron**) route the three .listen() stream sites through safeWatch - (fe56c4f) - *piperun*
- (**chenron**) replace SILENT catches in tag/folder pickers with safeAwait - (08d97fd) - *piperun*
- (**chenron**) dispose the SuggestionsOverlay query effect on State.dispose - (89be7e1) - *piperun*
- (**chenron**) guard CreateLinkNotifier signal writes against dispose race - (cf4d49f) - *piperun*
- (**chenron**) bound favicon cache with LRU to prevent unbounded growth - (4273117) - *piperun*
#### Performance Improvements
- (**chenron**) batch activity tracker's two writes into one transaction - (86f4167) - *piperun*
- (**chenron**) move bookmark HTML parse to a background isolate - (05d2765) - *piperun*
- (**chenron**) batch folder_editor save into one transaction - (dfd1db5) - *piperun*
- (**chenron**) collapse N+1 metadata lookup in suggestion_builder - (9713713) - *piperun*
- (**chenron**) bound bulk-validation concurrency and share one HTTP client - (36fef07) - *piperun*
- (**chenron**) route metadata refresh notifications by URL via a dispatcher - (a93af39) - *piperun*
- (**chenron**) memoize FilterableItemDisplay filter+sort with Computed - (894fbd9) - *piperun*
- (**chenron**) reduce per-cell rebuilds in item list/grid views - (7df8116) - *piperun*
- (**database**) add getFoldersByIds; drop N+1 in FolderPersistenceService - (b5a4038) - *piperun*
- (**database**) add watchFoldersWithItemCounts for count-only consumers - (78070f6) - *piperun*
#### Refactoring
- (**chenron**) extract _PathModeTile from PathModeSelector - (a9e2fd4) - *piperun*
- (**chenron**) extract _GlobalSearchBarView from GlobalSearchBar - (eeb3bb6) - *piperun*
- (**chenron**) widget-method cleanup for ActivityLogPage - (4270a5a) - *piperun*
- (**chenron**) split DeleteConfirmationDialog build into 4 widgets - (1d35fca) - *piperun*
- (**chenron**) extract showConfirmDialog helper for confirm/destruct dialogs - (46f575d) - *piperun*
- (**chenron**) extract _ChromeIconButton from FolderHeader _ActionRow - (e1d8e9d) - *piperun*
- (**chenron**) extract SettingsSectionHeader - (4847cdf) - *piperun*
- (**chenron**) rename direct-action methods _on* -> _handle* per CLAUDE.md - (2fce12f) - *piperun*
- (**chenron**) rename files to match their renamed Notifier/Service classes - (c798928) - *piperun*
- (**chenron**) rename Controller/State/Manager classes per CLAUDE.md convention - (9a6a0c2) - *piperun*
- (**chenron**) route semantic Colors.* through theme.colorScheme - (adcc975) - *piperun*
- (**chenron**) replace magic ints/strings with named DB enums + constants - (0102f5f) - *piperun*
- (**chenron**) consolidate item-type enums on FolderItemType - (fa785aa) - *piperun*
- <span style="background-color: #d73a49; color: white; padding: 2px 6px; border-radius: 3px; font-weight: bold; font-size: 0.85em;">BREAKING</span>(**database**) trim umbrella + drop main.dart shim - (3f4123e) - *piperun*
- <span style="background-color: #d73a49; color: white; padding: 2px 6px; border-radius: 3px; font-weight: bold; font-size: 0.85em;">BREAKING</span>(**database**) replace 4 ConfigDB lookup tables with intEnum (v5) - (f1ad893) - *piperun*
- (**database**) split DB handler into DatabaseLifecycle + AppFileService - (5b101b7) - *piperun*
- (**database**) canonicalize on database.dart, demote main.dart to shim - (9ed8d08) - *piperun*
- (**settings**) migrate theme UI + delete ConfigController (Phases 8+9) - (883b9ea) - *piperun*
- (**settings**) migrate backup + data UIs off ConfigController (Phases 6+7) - (c308b02) - *piperun*
- (**settings**) migrate display + cache UIs off ConfigController (Phase 5) - (f198c95) - *piperun*
- (**settings**) migrate archive UI off ConfigController bridge (Phase 4) - (29b147b) - *piperun*
- (**settings**) SettingsCoordinator + bridge ConfigController (Phase 3) - (1a144aa) - *piperun*
- (**settings**) add Backup + Theme section notifiers (Phase 2) - (b759f57) - *piperun*
- (**settings**) introduce per-section notifiers (Archive/Display/Database) - (4ca9f5d) - *piperun*
- <span style="background-color: #d73a49; color: white; padding: 2px 6px; border-radius: 3px; font-weight: bold; font-size: 0.85em;">BREAKING</span>locator-manage three static singletons - (f195a96) - *piperun*

- - -

## chenron-v1.10.0 - 2026-05-09
#### Features
- (**chenron**) log metadata fetches to the activity log - (4372553) - *piperun*
- (**chenron**) UX cleanups across activity log icon, search, settings, link creation - (4388c30) - *piperun*
#### Refactoring
- generalize archive_jobs table into background_jobs - (0a99b8d) - *piperun*

- - -

## [v1.1.0](https://github.com/piperun/chenron-flutter/compare/70f692f96e3e3337d8f7b1daae37df4cc7f162bc..v1.1.0) - 2026-05-09
### Package updates
- [chenron-v1.10.0](apps/chenron) bumped to [chenron-v1.10.0](https://github.com/piperun/chenron-flutter/compare/chenron-v1.9.0..chenron-v1.10.0)
- [cache_manager-v0.4.0](packages/cache_manager) bumped to [cache_manager-v0.4.0](https://github.com/piperun/chenron-flutter/compare/cache_manager-v0.3.0..cache_manager-v0.4.0)
### Global changes
#### Features
- add window_manager for persistent window sizing - ([54a9edc](https://github.com/piperun/chenron-flutter/commit/54a9edc1539bc0a18824b4ab66327929f7563830)) - [@piperun](https://github.com/piperun)
#### Bug Fixes
- update folder editor test for standardized snackbar text - ([3bd8d4c](https://github.com/piperun/chenron-flutter/commit/3bd8d4c2288bd2ea2442e3927945c338b8585332)) - [@piperun](https://github.com/piperun)
#### Documentation
- add versioning rules comment to cog.toml - ([f8c48fc](https://github.com/piperun/chenron-flutter/commit/f8c48fc673b8ce5bae0414657d21bcc8689ddc85)) - [@piperun](https://github.com/piperun)
- add README - ([70f692f](https://github.com/piperun/chenron-flutter/commit/70f692f96e3e3337d8f7b1daae37df4cc7f162bc)) - [@piperun](https://github.com/piperun)

- - -

## chenron-v1.9.0 - 2026-03-29
#### Features
- (**chenron**) add activity log page with filterable archive queue UI - (68a60b6) - *piperun*
- (**database**) trigger archive queue processing on enqueue - (7f6b48d) - *piperun*
- add cache logging to MetadataFactory - (4583086) - *piperun*
#### Bug Fixes
- display toggle popup, save button reactivity, and showCopyLink wiring - (5005f50) - *piperun*
- swap back and home button order in folder viewer - (9410bdb) - *piperun*

- - -

## chenron-v1.8.1 - 2026-03-25
#### Features
- (**chenron**) add activity log page with filterable archive queue UI - (68a60b6) - *piperun*

- - -

## chenron-v1.8.0 - 2026-03-25
#### Features
- wire archive queue processor into app startup - (2719b38) - *piperun*
- integrate startup refresh scheduler into MetadataFactory - (3f17f00) - *piperun*
- integrate change detection and adaptive TTL into MetadataFactory fetch flow - (aaaf197) - *piperun*
- extend persistence interface and bridge for adaptive TTL fields - (18c69a3) - *piperun*
#### Performance Improvements
- single-pass filtering and add DB indexes - (1f8a6f5) - *piperun*
- parallelize DB queries and cache static RegExp - (044b67c) - *piperun*

- - -

## chenron-v1.7.0 - 2026-02-19
#### Features
- improve collapsed navigation rail UX - (640f799) - *piperun*

- - -

## chenron-v1.6.0 - 2026-02-19
#### Features
- show sub-category icons when settings rail is collapsed - (2f5c3b0) - *piperun*
#### Bug Fixes
- reject scheme-only URLs in isValidUrlFormat - (6b334ed) - *piperun*

- - -

## chenron-v1.5.2 - 2026-02-19
#### Bug Fixes
- use sell icon for tags and reject video URLs in og:image - (25216b4) - *piperun*
#### Performance Improvements
- optimize cache computation, batch queries, and FutureBuilder - (9ff81d2) - *piperun*
#### Refactoring
- decouple shared code from global signals and locator - (f1991f5) - *piperun*

- - -

## chenron-v1.5.1 - 2026-02-18
#### Bug Fixes
- remove dead code and unused parameters - (8cadd0a) - *piperun*
- prevent RenderFlex overflow in card mode content - (7ea6d28) - *piperun*
#### Refactoring
- split item_toolbar into focused component files - (a7be8a2) - *piperun*
- split item_detail_dialog into focused component files - (3e17761) - *piperun*
- extract PathModeSelector for settings path modes - (d62cfb2) - *piperun*
- extract CopyFeedbackMixin from footer and URL bar - (2061ea1) - *piperun*
- extract MetadataLifecycleMixin from viewer components - (b21f5d7) - *piperun*
- extract shared ItemEmptyState and remove duplicate URL launch - (2a27ebd) - *piperun*
- unify CardItem into UnifiedItem - (88725d6) - *piperun*

- - -

## chenron-v1.5.0 - 2026-02-18
#### Features
- split cache clearing into images and metadata - (cafc270) - *piperun*
#### Bug Fixes
- toolbar alignment and settings tags icon - (5fc11d1) - *piperun*
#### Refactoring
- replace widget methods with proper widget classes - (92dae43) - *piperun*

- - -

Changelog generated by [cocogitto](https://github.com/cocogitto/cocogitto).