# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

- - -
## database-v0.14.1 - 2026-05-21
#### Performance Improvements
- (**database**) items(item_id) index + parallelize folder pagination - (91a5019) - *piperun*

- - -

## database-v0.14.0 - 2026-05-19
#### Features
- (**database**) add background_jobs cleanup helpers - (f9969dd) - *piperun*
#### Bug Fixes
- (**database**) repair -1 enum indices after buggy v5 migration - (2e983a9) - *piperun*
#### Performance Improvements
- (**chenron**) collapse N+1 metadata lookup in suggestion_builder - (9713713) - *piperun*
- (**database**) stop re-running enum seeding on every app launch - (4217505) - *piperun*
- (**database**) add getFoldersByIds; drop N+1 in FolderPersistenceService - (b5a4038) - *piperun*
- (**database**) add watchFoldersWithItemCounts for count-only consumers - (78070f6) - *piperun*
#### Refactoring
- (**chenron**) replace magic ints/strings with named DB enums + constants - (0102f5f) - *piperun*
- <span style="background-color: #d73a49; color: white; padding: 2px 6px; border-radius: 3px; font-weight: bold; font-size: 0.85em;">BREAKING</span>(**database**) redesign VEPR as a function (runVepr) - (48413eb) - *piperun*
- <span style="background-color: #d73a49; color: white; padding: 2px 6px; border-radius: 3px; font-weight: bold; font-size: 0.85em;">BREAKING</span>(**database**) trim umbrella + drop main.dart shim - (3f4123e) - *piperun*
- <span style="background-color: #d73a49; color: white; padding: 2px 6px; border-radius: 3px; font-weight: bold; font-size: 0.85em;">BREAKING</span>(**database**) replace 4 ConfigDB lookup tables with intEnum (v5) - (f1ad893) - *piperun*
- <span style="background-color: #d73a49; color: white; padding: 2px 6px; border-radius: 3px; font-weight: bold; font-size: 0.85em;">BREAKING</span>(**database**) replace item/metadata lookup tables with intEnum (AppDB v15) - (e0b8adb) - *piperun*
- (**database**) split DB handler into DatabaseLifecycle + AppFileService - (5b101b7) - *piperun*
- (**database**) rename test_support/ to honest paths - (e8bcd31) - *piperun*
- (**database**) canonicalize on database.dart, demote main.dart to shim - (9ed8d08) - *piperun*
- <span style="background-color: #d73a49; color: white; padding: 2px 6px; border-radius: 3px; font-weight: bold; font-size: 0.85em;">BREAKING</span>locator-manage three static singletons - (f195a96) - *piperun*
- lift app-specific identifiers in generic packages to overridable defaults - (0ce7948) - *piperun*

- - -

## database-v0.13.0 - 2026-05-09
#### Refactoring
- generalize archive_jobs table into background_jobs - (0a99b8d) - *piperun*

- - -

## database-v0.12.0 - 2026-03-29
#### Features
- (**chenron**) add activity log page with filterable archive queue UI - (68a60b6) - *piperun*
- (**database**) trigger archive queue processing on enqueue - (7f6b48d) - *piperun*
#### Bug Fixes
- (**database**) join backup_settings on userConfigId instead of id - (1234634) - *piperun*

- - -

## database-v0.11.0 - 2026-03-25
#### Features
- add ArchiveQueueProcessor for background archive processing - (d2cdb58) - *piperun*
- add archive queue CRUD operations - (7d939b0) - *piperun*
- add archive_jobs queue table (schema v13) - (4f53e3f) - *piperun*
- update CRUD for adaptive TTL fields and add getExpiredEntries query - (45e52e2) - *piperun*
- add adaptive TTL columns to web_metadata_entries schema (v11 migration) - (873d319) - *piperun*
- redesign card footer and improve search - (45a13b0) - *piperun*
#### Bug Fixes
- update init_db_test to expect schema version 10 - (ba00dd8) - *piperun*
#### Performance Improvements
- single-pass filtering and add DB indexes - (1f8a6f5) - *piperun*
- parallelize DB queries and cache static RegExp - (044b67c) - *piperun*
#### Refactoring
- (**database**) split AppDatabase and ConfigDatabase into separate files - (7c54bbf) - *piperun*
- decouple archiving from folder creation, enqueue instead of await - (a17b50f) - *piperun*

- - -

## database-v0.10.0 - 2026-02-17
#### Features
- add WebMetadataEntries drift table for persistent metadata cache - (1d183e5) - *piperun*
- add removeTag and renameTag database operations - (bf78ab6) - *piperun*
#### Bug Fixes
- add unique constraint to Items (folderId, itemId) index - (26ea6b0) - *piperun*
- show live item counts on statistics overview cards - (3d3cd2c) - *piperun*
#### Refactoring
- align TagResult with other result types - (0a7d0d6) - *piperun*

- - -

## database-v0.9.0 - 2026-02-12
#### Features
- show 'added' date when viewing items in a folder - (6b9ff34) - *piperun*

- - -

## database-v0.8.1 - 2026-02-12
#### Bug Fixes
- show user-friendly error messages instead of raw exceptions - (95c525a) - *piperun*

- - -

## database-v0.8.0 - 2026-02-12
#### Features
- add checksum-based backup deduplication - (300a3da) - *piperun*

- - -

## database-v0.7.0 - 2026-02-12
#### Features
- add item detail dialog with tag and folder management - (e13ca46) - *piperun*
- enable WAL journal mode for SQLite databases - (e47b69d) - *piperun*
#### Refactoring
- rename entity to item in domain-level code - (75e5285) - *piperun*
- migrate user_config and backup_settings create to VEPR - (c23a8fc) - *piperun*
- migrate folder update to VEPR pattern - (9098be6) - *piperun*
- normalize DocumentResult to use data field - (493f350) - *piperun*
- type IncludeOptions generics consistently across read handlers - (96b636e) - *piperun*
- add infinite scroll pagination for folder viewer - (303cac1) - *piperun*

- - -

## database-v0.6.1 - 2026-02-09
#### Bug Fixes
- make statistics ordering test deterministic - (10f7a72) - *piperun*
#### Refactoring
- extract UI components and deduplicate database builders - (48f515c) - *piperun*

- - -

## database-v0.6.0 - 2026-02-09
#### Features
- add viewer display preferences with persistent settings - (f2ea94c) - *piperun*
#### Refactoring
- suppress verbose log output in tests and default to FINE - (a22473a) - *piperun*
- rename logger package to app_logger, adjust VEPR log levels - (30d5ae9) - *piperun*

- - -

## database-v0.5.0 - 2026-02-08
#### Features
- improve dashboard activity list and search - (3b49b53) - *piperun*
#### Bug Fixes
- propagate folder context and add dbId getter - (fe97640) - *piperun*
- add migration to correct existing 0-based type_id values - (347c82f) - *piperun*
- correct type ID off-by-one and default folder lookup - (75d21df) - *piperun*

- - -

## database-v0.4.0 - 2026-02-08
#### Features
- add backup schedule settings with startup wiring - (03f16ad) - *piperun*

- - -

## database-v0.3.1 - 2026-02-07
#### Bug Fixes
- folder timestamp/description display and add home navigation to folder viewer - (626cde9) - *piperun*

- - -

## database-v0.3.0 - 2026-02-07
#### Features
- add activity tracking and recent access schema with SQLite triggers - (c795c80) - *piperun*
#### Bug Fixes
- resolve datetime format mismatches in statistics and activity triggers - (371ec6c) - *piperun*
#### Refactoring
- fix remaining lint warnings for clean analyze - (e5e6a70) - *piperun*

- - -

## database-v0.2.0 - 2026-02-07
#### Features
- add per-type item count badges to folder sidebar - (4f73830) - *piperun*

- - -

## database-v0.1.0 - 2026-02-07
#### Features
- (**database**) add color parameter to folder and tag creation operations - (e169c2b) - *piperun*
- (**database**) add VEPR implementation for creating and updating documents - (e34fcfc) - *piperun*
- (**database**) implement document file operations including create, read, update, and delete - (52e53e6) - *piperun*
- (**database**) enhance configuration and user settings management - (d212bc1) - *piperun*
- Add color attribute to TagResult and update related methods - (ade3860) - *piperun*
- Add color field to folders and tags tables - (bc8bfe8) - *piperun*
- add file-based document operations - (d6d5f61) - *piperun*
- add statistics tracking extensions - (eecae19) - *piperun*
- add statistics table for tracking item counts - (f31fb4d) - *piperun*
#### Refactoring
- (**database**) update DbResult to include DocumentFileType in document factory and removing the stupid show. - (21b8e5f) - *piperun*
- (**database**) implement document CRUD - (caf64b8) - *piperun*
- (**database**) replace mimeType with fileType in Documents table - (0899e94) - *piperun*
- (**database**) remove unused variables in read_document_test - (e32d568) - *piperun*
- (**tags**) update addTag method to accept optional color parameter - (46cc017) - *piperun*
- (**vibe**) merge vibe_core into vibe package - (131788a) - *piperun*
- update tag handling in document and link creation to use shared insertTags helper - (3665873) - *piperun*
- Remove Future wrapper from AppDatabase access pattern - (6660293) - *piperun*
- update insertDocuments to use Document schema - (2efed64) - *piperun*
- replace ItemContent/MapContent with freezed FolderItem union - (b196719) - *piperun*
- update ConfigDatabase to include additional user configuration fields and improve database connection handling - (6919ffc) - *piperun*
- extract database as separate package - (00d8ea2) - *piperun*

- - -

Changelog generated by [cocogitto](https://github.com/cocogitto/cocogitto).