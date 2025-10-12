import "package:flutter/material.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/update.dart";
import "package:chenron/database/extensions/link/create.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/cud.dart";
import "package:chenron/models/item.dart";
import "package:signals/signals.dart";
import "package:chenron/features/create/link/notifiers/create_link_notifier.dart";
import "package:chenron/features/create/link/widgets/link_folder_section.dart";
import "package:chenron/features/create/link/widgets/link_input_section.dart";
import "package:chenron/features/create/link/widgets/link_archive_toggle.dart";
import "package:chenron/features/create/link/widgets/link_tags_section.dart";
import "package:chenron/features/create/link/widgets/link_table_section.dart";
import "package:chenron/features/create/link/widgets/link_edit_bottom_sheet.dart";
import "package:chenron/features/create/link/services/url_parser_service.dart";
import "package:chenron/utils/validation/link_validator.dart";
import "package:chenron/utils/validation/tag_validator.dart";
import "package:chenron/notifiers/link_table_notifier.dart";

class CreateLinkPage extends StatefulWidget {
  final bool hideAppBar;
  final ValueChanged<VoidCallback>? onSaveCallbackReady;
  final ValueChanged<bool>? onValidationChanged;
  
  const CreateLinkPage({
    super.key,
    this.hideAppBar = false,
    this.onSaveCallbackReady,
    this.onValidationChanged,
  });

  @override
  State<CreateLinkPage> createState() => _CreateLinkPageState();
}

class _CreateLinkPageState extends State<CreateLinkPage> {
  late CreateLinkNotifier _notifier;
  final DataGridNotifier _tableNotifier = DataGridNotifier();
  List<Folder> _selectedFolders = [];

  @override
  void initState() {
    super.initState();
    _notifier = CreateLinkNotifier();
    
    // Provide save callback to parent if requested
    widget.onSaveCallbackReady?.call(_saveLinks);
    
    // Listen to notifier for validation changes
    _notifier.addListener(_onNotifierChanged);
    
    // Initially no links, so invalid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValidationChanged?.call(false);
    });
  }

  void _onNotifierChanged() {
    widget.onValidationChanged?.call(_notifier.hasEntries);
    setState(() {});
  }

  @override
  void dispose() {
    _notifier.removeListener(_onNotifierChanged);
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hideAppBar
          ? null
          : AppBar(
              title: const Text("Add Links"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveLinks,
                ),
              ],
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LinkFolderSection(
              selectedFolders: _selectedFolders,
              onFoldersChanged: (folders) {
                setState(() {
                  _selectedFolders = folders;
                  _notifier.setSelectedFolders(
                    folders.map((f) => f.id).toList(),
                  );
                });
              },
            ),
            LinkInputSection(
              mode: _notifier.inputMode,
              onModeChanged: _notifier.setInputMode,
              onAddSingle: _handleAddSingle,
              onAddBulk: _handleAddBulk,
            ),
            LinkArchiveToggle(
              value: _notifier.isArchiveMode,
              onChanged: (value) => _notifier.setArchiveMode(value: value),
            ),
            LinkTagsSection(
              tags: _notifier.globalTags,
              onTagAdded: _notifier.addGlobalTag,
              onTagRemoved: _notifier.removeGlobalTag,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 300,
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: LinkTableSection(
                entries: _notifier.entries,
                notifier: _tableNotifier,
                onEdit: _handleEdit,
                onDelete: _handleDelete,
                onDeleteSelected: _handleDeleteSelected,
                onClearAll: _handleClearAll,
                folderNames: _selectedFolders.fold<Map<String, String>>({}, (map, folder) {
                  map[folder.id] = folder.title;
                  return map;
                }),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddSingle(String input) {
    final parsed = UrlParserService.parseSingleLine(input);
    if (parsed == null) return;
    
    // Validate URL
    final urlError = LinkValidator.validateContent(parsed.url);
    if (urlError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(urlError)),
      );
      return;
    }
    
    // Validate tags using TagValidator
    final tagError = TagValidator.validateTags(parsed.tags);
    if (tagError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tagError)),
      );
      return;
    }
    
    _notifier.addEntry(
      url: parsed.url,
      tags: parsed.tags,
    );
  }

  void _handleAddBulk(String input) {
    final parsed = UrlParserService.parseBulkLines(input);
    
    int validCount = 0;
    int invalidCount = 0;
    final validEntries = <Map<String, dynamic>>[];
    final List<String> invalidReasons = [];
    
    for (final p in parsed) {
      // Validate URL
      final urlError = LinkValidator.validateContent(p.url);
      if (urlError != null) {
        invalidCount++;
        invalidReasons.add("${p.url}: $urlError");
        continue;
      }
      
      // Validate tags using TagValidator
      final tagError = TagValidator.validateTags(p.tags);
      if (tagError != null) {
        invalidCount++;
        invalidReasons.add("${p.url}: $tagError");
        continue;
      }
      
      // All validations passed
      validEntries.add({
        "url": p.url,
        "tags": p.tags,
      });
      validCount++;
    }
    
    if (validEntries.isNotEmpty) {
      _notifier.addEntries(validEntries);
    }
    
    if (invalidCount > 0) {
      String message = "Added $validCount valid URL(s). Skipped $invalidCount invalid URL(s).";
      if (invalidReasons.isNotEmpty && invalidReasons.length <= 3) {
        message += "\n${invalidReasons.join('\n')}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
        ),
      );
    } else if (validCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added $validCount URL(s) successfully")),
      );
    }
  }

  void _handleEdit(Key key) {
    final entry = _notifier.getEntry(key);
    if (entry == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LinkEditBottomSheet(
        entry: entry,
        availableFolders: _selectedFolders.isEmpty ? null : _selectedFolders,
        onSave: (updatedEntry) {
          _notifier.updateEntry(key, updatedEntry);
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _handleDelete(Key key) {
    _notifier.removeEntry(key);
  }

  void _handleDeleteSelected() {
    final selectedRows = _tableNotifier.stateManager?.checkedRows ?? [];
    final keys = selectedRows.map((row) => row.key).whereType<Key>().toList();
    _notifier.removeEntries(keys);
    _tableNotifier.removeSelectedRows();
  }

  void _handleClearAll() {
    _notifier.clearEntries();
  }

  Future<void> _saveLinks() async {
    if (_notifier.entries.isEmpty) return;

    final db = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
    final appDb = db.appDatabase;

    final targetFolders = _selectedFolders.isEmpty
        ? ["default"]
        : _selectedFolders.map((f) => f.id).toList();

    for (final folderId in targetFolders) {
      for (final entry in _notifier.entries) {
        final linkId = await appDb.createLink(
          link: entry.url,
          // TODO: When we implement tags for links.
        );

        await appDb.updateFolder(
          folderId,
          itemUpdates: CUD(
            create: [],
            update: [
              FolderItem(
                type: FolderItemType.link,
                itemId: linkId,
                content: StringContent(value: entry.url),
              )
            ],
            remove: [],
          ),
        );
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
