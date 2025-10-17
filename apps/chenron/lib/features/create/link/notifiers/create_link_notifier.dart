import "package:flutter/foundation.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:chenron/features/create/link/services/url_validator_service.dart";
import "package:chenron/utils/logger.dart";

enum InputMode { single, bulk }

class CreateLinkNotifier extends ChangeNotifier {
  InputMode _inputMode = InputMode.single;
  final List<LinkEntry> _entries = [];
  final Set<String> _globalTags = {};
  List<String> _selectedFolderIds = [];
  bool _isArchiveMode = false;

  InputMode get inputMode => _inputMode;
  List<LinkEntry> get entries => List.unmodifiable(_entries);
  Set<String> get globalTags => Set.unmodifiable(_globalTags);
  List<String> get selectedFolderIds => List.unmodifiable(_selectedFolderIds);
  bool get isArchiveMode => _isArchiveMode;
  bool get hasEntries => _entries.isNotEmpty;

  void setInputMode(InputMode mode) {
    if (_inputMode != mode) {
      _inputMode = mode;
      notifyListeners();
    }
  }

  void setArchiveMode({required bool value}) {
    if (_isArchiveMode != value) {
      _isArchiveMode = value;
      notifyListeners();
    }
  }

  void setSelectedFolders(List<String> folderIds) {
    _selectedFolderIds = folderIds;
    notifyListeners();
  }

  void addGlobalTag(String tag) {
    final cleanTag = tag.trim().toLowerCase();
    if (cleanTag.isNotEmpty && !_globalTags.contains(cleanTag)) {
      _globalTags.add(cleanTag);
      notifyListeners();
    }
  }

  void removeGlobalTag(String tag) {
    if (_globalTags.remove(tag)) {
      notifyListeners();
    }
  }

  void clearGlobalTags() {
    if (_globalTags.isNotEmpty) {
      _globalTags.clear();
      notifyListeners();
    }
  }

  /// Adds a new entry and optionally validates it
  void addEntry({
    required String url,
    List<String>? tags,
    bool? isArchived,
    bool validateAsync = true,
  }) {
    final entryTags = <String>{
      ...?tags,
      ..._globalTags,
    }.toList();

    final entry = LinkEntry(
      key: UniqueKey(),
      url: url.trim(),
      tags: entryTags,
      folderIds: _selectedFolderIds.isEmpty ? ["default"] : _selectedFolderIds,
      isArchived: isArchived ?? _isArchiveMode,
      validationStatus: LinkValidationStatus.pending,
    );

    _entries.add(entry);
    notifyListeners();

    if (validateAsync) {
      _validateEntry(entry.key);
    }
  }

  /// Adds multiple entries (bulk mode)
  void addEntries(List<Map<String, dynamic>> entriesData) {
    loggerGlobal.info("CreateLinkNotifier",
        "Adding ${entriesData.length} entries in bulk mode");

    for (final data in entriesData) {
      addEntry(
        url: data["url"] as String,
        tags: data["tags"] as List<String>?,
        validateAsync: false,
      );
    }

    loggerGlobal.info("CreateLinkNotifier",
        "Starting validation for ${entriesData.length} entries");
    // Validate all at once (non-blocking)
    _validateAllEntries();
  }

  /// Updates an existing entry
  void updateEntry(Key key, LinkEntry updatedEntry) {
    final index = _entries.indexWhere((e) => e.key == key);
    if (index != -1) {
      _entries[index] = updatedEntry;
      notifyListeners();
    }
  }

  /// Removes an entry
  void removeEntry(Key key) {
    final initialLength = _entries.length;
    _entries.removeWhere((e) => e.key == key);
    if (_entries.length != initialLength) {
      notifyListeners();
    }
  }

  /// Removes multiple entries
  void removeEntries(List<Key> keys) {
    final keySet = keys.toSet();
    final initialLength = _entries.length;
    _entries.removeWhere((e) => keySet.contains(e.key));
    if (_entries.length != initialLength) {
      notifyListeners();
    }
  }

  /// Clears all entries
  void clearEntries() {
    if (_entries.isNotEmpty) {
      _entries.clear();
      notifyListeners();
    }
  }

  /// Validates a specific entry asynchronously
  Future<void> _validateEntry(Key key) async {
    final index = _entries.indexWhere((e) => e.key == key);
    if (index == -1) return;

    final entry = _entries[index];

    loggerGlobal.info(
        "CreateLinkNotifier", "Starting validation for URL: ${entry.url}");

    // Set validating status
    _entries[index] = entry.copyWith(
      validationStatus: LinkValidationStatus.validating,
    );
    notifyListeners();

    try {
      // Perform validation
      final result = await UrlValidatorService.validateUrl(entry.url);

      loggerGlobal.info("CreateLinkNotifier",
          "Validation completed for ${entry.url}: isValid=${result.isValid}, isReachable=${result.isReachable}, message=${result.message}");

      // Update entry with result
      final updatedIndex = _entries.indexWhere((e) => e.key == key);
      if (updatedIndex != -1) {
        LinkValidationStatus status;
        if (!result.isValid) {
          status = LinkValidationStatus.invalid;
          loggerGlobal.warning(
              "CreateLinkNotifier", "URL ${entry.url} is INVALID");
        } else if (!result.isReachable) {
          status = LinkValidationStatus.unreachable;
          loggerGlobal.warning("CreateLinkNotifier",
              "URL ${entry.url} is UNREACHABLE: ${result.message}");
        } else {
          status = LinkValidationStatus.valid;
          loggerGlobal.info("CreateLinkNotifier",
              "URL ${entry.url} is VALID (status code: ${result.statusCode})");
        }

        _entries[updatedIndex] = _entries[updatedIndex].copyWith(
          validationStatus: status,
          validationMessage: result.message,
          validationStatusCode: result.statusCode,
        );
        notifyListeners();
      }
    } catch (e, stackTrace) {
      loggerGlobal.severe("CreateLinkNotifier",
          "Validation error for ${entry.url}: $e", e, stackTrace);

      // Mark as unreachable on error
      final updatedIndex = _entries.indexWhere((e) => e.key == key);
      if (updatedIndex != -1) {
        _entries[updatedIndex] = _entries[updatedIndex].copyWith(
          validationStatus: LinkValidationStatus.unreachable,
          validationMessage: "Validation error: $e",
        );
        notifyListeners();
      }
    }
  }

  /// Validates all entries in parallel (non-blocking)
  Future<void> _validateAllEntriesParallel() async {
    loggerGlobal.info("CreateLinkNotifier",
        "Starting parallel validation for ${_entries.length} entries");
    final startTime = DateTime.now();

    // Validate all entries in parallel using Future.wait
    await Future.wait(
      _entries.map((entry) => _validateEntry(entry.key)),
    );

    final duration = DateTime.now().difference(startTime);
    loggerGlobal.info("CreateLinkNotifier",
        "Parallel validation completed in ${duration.inMilliseconds}ms");
  }

  /// Validates all entries sequentially (kept for compatibility)
  Future<void> _validateAllEntries() async {
    for (final entry in _entries) {
      await _validateEntry(entry.key);
    }
  }

  /// Revalidates a specific entry
  Future<void> revalidateEntry(Key key) async {
    await _validateEntry(key);
  }

  /// Gets an entry by key
  LinkEntry? getEntry(Key key) {
    try {
      return _entries.firstWhere((e) => e.key == key);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _entries.clear();
    _globalTags.clear();
    _selectedFolderIds.clear();
    super.dispose();
  }
}
