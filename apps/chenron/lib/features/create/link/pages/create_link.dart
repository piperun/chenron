import "package:chenron/shared/tag_section/tag_section.dart";
import "package:flutter/material.dart";
import "package:database/database.dart";
import "package:database/extensions/folder/update.dart";
import "package:database/extensions/link/create.dart";
import "package:database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:signals/signals.dart";
import "package:chenron/features/create/link/notifiers/create_link_notifier.dart";
import "package:chenron/features/create/link/widgets/link_folder_section.dart";
import "package:chenron/features/create/link/widgets/link_input_section.dart";
import "package:chenron/features/create/link/widgets/link_archive_toggle.dart";
import "package:chenron/features/create/link/widgets/link_table_section.dart";
import "package:chenron/features/create/link/widgets/link_edit_bottom_sheet.dart";
import "package:chenron/features/create/link/services/url_parser_service.dart";
import "package:chenron/features/create/link/services/bulk_validator_service.dart";
import "package:chenron/features/create/link/models/validation_result.dart";
import "package:chenron/utils/validation/link_validator.dart";
import "package:chenron/utils/validation/tag_validator.dart";
import "package:chenron/notifiers/item_table_notifier.dart";
import "package:logger/logger.dart";

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
  final ItemTableNotifier _tableNotifier = ItemTableNotifier();
  List<Folder> _selectedFolders = [];
  String? _singleInputError;
  String? _generalError;

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
                  key: const Key("create_link_save_button"),
                  icon: const Icon(Icons.save),
                  onPressed: _saveLinks,
                ),
              ],
            ),
      body: Column(
        children: [
          // General error banner
          if (_generalError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                border: Border(
                  bottom: BorderSide(color: theme.colorScheme.error, width: 2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Error: $_generalError",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _generalError = null),
                    color: theme.colorScheme.error,
                    tooltip: "Dismiss",
                  ),
                ],
              ),
            ),
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
                    key: const Key("create_link_close_button"),
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
                    key: const Key("create_link_header_save_button"),
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
                      keyPrefix: "link_input",
                      mode: _notifier.inputMode,
                      onModeChanged: _notifier.setInputMode,
                      onAddSingle: _handleAddSingle,
                      onAddBulk: _handleAddBulk,
                      singleInputError: _singleInputError,
                      onErrorDismissed: () =>
                          setState(() => _singleInputError = null),
                    ),
                    LinkArchiveToggle(
                      value: _notifier.isArchiveMode,
                      onChanged: (value) =>
                          _notifier.setArchiveMode(value: value),
                    ),
                    TagSection(
                      keyPrefix: "global_tags",
                      title: "Global Tags",
                      description:
                          "Add tags to all links created in this session",
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
    if (parsed == null) {
      setState(() {
        _singleInputError = "Invalid input format";
      });
      return;
    }

    // Validate URL
    final urlError = LinkValidator.validateContent(parsed.url);
    if (urlError != null) {
      setState(() {
        _singleInputError = urlError;
      });
      return;
    }

    // Validate tags using TagValidator
    final tagError = TagValidator.validateTags(parsed.tags);
    if (tagError != null) {
      setState(() {
        _singleInputError = tagError;
      });
      return;
    }

    // Clear any previous errors
    setState(() {
      _singleInputError = null;
    });

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
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    // For bulk mode, inline errors are already shown in the ValidationErrorPanel
  }

  Future<void> _handleEdit(Key key) async {
    final entry = _notifier.getEntry(key);
    if (entry == null) return;

    try {
      await showModalBottomSheet(
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
      // Modal dismissed - could add post-edit logic here if needed
    } catch (e, stackTrace) {
      loggerGlobal.severe("CreateLink", "Error editing link", e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error editing link: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

    try {
      final db = locator.get<Signal<AppDatabaseHandler>>().value;
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
                FolderItem.link(
                  id: null,
                  itemId: result.linkId,
                  url: entry.url,
                )
              ],
              remove: [],
            ),
          );
        }
      }

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Successfully saved ${_notifier.entries.length} link(s)",
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // If onSaved callback provided, call it (main page mode)
        if (widget.onSaved != null) {
          widget.onSaved!();
        } else {
          // Otherwise, close via Navigator (modal mode)
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _generalError = "Could not save: ${e.toString()}";
        });
      }
    }
  }
}
