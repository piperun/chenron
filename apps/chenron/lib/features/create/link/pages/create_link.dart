import "package:chenron/shared/tag_section/tag_section.dart";
import "package:flutter/material.dart";
import "package:database/database.dart";
import "package:database/main.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/create/link/notifiers/create_link_notifier.dart";
import "package:chenron/features/create/link/services/link_persistence_service.dart";

import "package:chenron/features/create/link/widgets/link_folder_section.dart";
import "package:chenron/features/create/link/widgets/link_input_section.dart";
import "package:chenron/features/create/link/widgets/link_archive_toggle.dart";
import "package:chenron/features/create/link/widgets/link_table_section.dart";
import "package:chenron/features/create/link/widgets/link_edit_bottom_sheet.dart";
import "package:chenron/features/create/link/widgets/error_banner.dart";
import "package:chenron/features/create/link/widgets/link_page_header.dart";
import "package:chenron/features/create/link/services/url_parser_service.dart";
import "package:chenron/features/create/link/services/bulk_validator_service.dart";
import "package:chenron/features/create/link/models/validation_result.dart";
import "package:chenron/utils/validation/link_validator.dart";
import "package:chenron/utils/validation/tag_validator.dart";
import "package:chenron/notifiers/item_table_notifier.dart";
import "package:app_logger/app_logger.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";
import "package:chenron/shared/errors/user_error_message.dart";

class CreateLinkPage extends StatefulWidget {
  final bool hideAppBar;
  final ValueChanged<VoidCallback>? onSaveCallbackReady;
  final ValueChanged<bool>? onValidationChanged;
  final VoidCallback? onClose;
  final VoidCallback? onSaved;
  final List<Folder>? initialFolders;

  const CreateLinkPage({
    super.key,
    this.hideAppBar = false,
    this.onSaveCallbackReady,
    this.onValidationChanged,
    this.onClose,
    this.onSaved,
    this.initialFolders,
  });

  @override
  State<CreateLinkPage> createState() => _CreateLinkPageState();
}

class _CreateLinkPageState extends State<CreateLinkPage> {
  late CreateLinkNotifier _notifier;
  final ItemTableNotifier<FolderItem> _tableNotifier = ItemTableNotifier<FolderItem>();
  late List<Folder> _selectedFolders;
  String? _singleInputError;
  String? _generalError;
  late final void Function() _disposeEffect;

  @override
  void initState() {
    super.initState();
    _notifier = CreateLinkNotifier();
    _selectedFolders = List.from(widget.initialFolders ?? []);
    if (_selectedFolders.isNotEmpty) {
      _notifier.setSelectedFolders(
        _selectedFolders.map((f) => f.id).toList(),
      );
    }

    // Provide save callback to parent if requested
    widget.onSaveCallbackReady?.call(_saveLinks);

    // React to hasEntries changes for parent validation callback
    _disposeEffect = effect(() {
      final hasEntries = _notifier.hasEntries.value;
      widget.onValidationChanged?.call(hasEntries);
    });
  }

  @override
  void dispose() {
    _disposeEffect();
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
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
            if (_generalError != null)
              ErrorBanner(
                error: _generalError!,
                onDismiss: () => setState(() => _generalError = null),
              ),
            if (widget.hideAppBar && widget.onClose != null)
              LinkPageHeader(
                onClose: widget.onClose!,
                onSave: _saveLinks,
                hasEntries: _notifier.hasEntries.value,
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
    });
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
              "Added ${result.validLines} valid URL(s)"
              "${result.hasErrors ? '. ${result.invalidLines} invalid URLs remain.' : ''}",
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
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
      await showModalBottomSheet<void>(
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
        showErrorSnackBar(context, e);
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
      final savedCount = await LinkPersistenceService().saveLinks(
        entries: _notifier.entries,
        folderIds: _selectedFolders.map((f) => f.id).toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Saved $savedCount link(s)",
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );

        if (widget.onSaved != null) {
          widget.onSaved!();
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _generalError = userErrorMessage(e);
        });
      }
    }
  }
}
