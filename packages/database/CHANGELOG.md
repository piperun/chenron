# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

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