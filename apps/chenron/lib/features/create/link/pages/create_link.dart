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
import "package:chenron/features/create/link/services/bulk_validator_service.dart";
import "package:chenron/features/create/link/models/validation_result.dart";
import "package:chenron/utils/validation/link_validator.dart";
import "package:chenron/utils/validation/tag_validator.dart";
import "package:chenron/notifiers/link_table_notifier.dart";
import "package:chenron/models/metadata.dart";

class CreateLinkPage extends StatefulWidget {
  final bool hideAppBar;
  final ValueChanged<VoidCallback>? onSaveCallbackReady;
  final ValueChanged<bool>? onValidationChanged;
  final VoidCallback? onClose;
  final VoidCallback? onSaved;

  const CreateLinkPage({
    super.key,
    this.hideAppBar = false,
    this.onSaveCallbackReady,
    this.onValidationChanged,
    this.onClose,
    this.onSaved,
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
    final theme = Theme.of(context);

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
      body: Column(
        children: [
          // Header with close button when in main page mode
          if (widget.hideAppBar && widget.onClose != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                    tooltip: "Close",
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Add Links",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _notifier.hasEntries ? _saveLinks : null,
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text("Save"),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
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
                      onChanged: (value) =>
                          _notifier.setArchiveMode(value: value),
                    ),
                    LinkTagsSection(
                      tags: _notifier.globalTags,
                      onTagAdded: _notifier.addGlobalTag,
                      onTagRemoved: _notifier.removeGlobalTag,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 300,
                        maxHeight: (MediaQuery.of(context).size.height * 0.5)
                            .clamp(300.0, double.infinity),
                      ),
                      child: LinkTableSection(
                        entries: _notifier.entries,
                        notifier: _tableNotifier,
                        onEdit: _handleEdit,
                        onDelete: _handleDelete,
                        onDeleteSelected: _handleDeleteSelected,
                        onClearAll: _handleClearAll,
                        folderNames: _selectedFolders
                            .fold<Map<String, String>>({}, (map, folder) {
                          map[folder.id] = folder.title;
                          return map;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  void _handleAddBulk(String input, BulkValidationResult validationResult) {
    // First validate the bulk input
    final result = BulkValidatorService.validateBulkInput(input);

    // Add only valid entries to the table
    if (result.hasValidLines) {
      final validEntries = result.validLinesData
          .map((line) => {
                "url": line.url!,
                "tags": line.tags ?? [],
              })
          .toList();

      _notifier.addEntries(validEntries);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Added ${result.validLines} valid URL(s) successfully"
              "${result.hasErrors ? '. ${result.invalidLines} invalid URLs remain in input.' : ''}",
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else if (result.hasErrors) {
      // All lines have errors - show message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "All ${result.invalidLines} URLs have validation errors. Please fix and try again."),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
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
        // Convert tags to Metadata objects
        final tags = entry.tags.isNotEmpty
            ? entry.tags
                .map((tag) => Metadata(
                      value: tag,
                      type: MetadataTypeEnum.tag,
                    ))
                .toList()
            : null;

        final result = await appDb.createLink(
          link: entry.url,
          tags: tags,
        );

        await appDb.updateFolder(
          folderId,
          itemUpdates: CUD(
            create: [],
            update: [
              FolderItem(
                type: FolderItemType.link,
                itemId: result.linkId,
                content: StringContent(value: entry.url),
              )
            ],
            remove: [],
          ),
        );
      }
    }

    if (mounted) {
      // If onSaved callback provided, call it (main page mode)
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        // Otherwise, close via Navigator (modal mode)
        Navigator.pop(context);
      }
    }
  }
}
