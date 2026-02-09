import "package:flutter/foundation.dart";
import "dart:async";
import "package:signals/signals.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:chenron/features/create/link/services/url_validator_service.dart";
import "package:app_logger/app_logger.dart";

enum InputMode { single, bulk }

class CreateLinkNotifier {
  final Signal<InputMode> _inputMode = signal(InputMode.single);
  final Signal<List<LinkEntry>> _entries = signal([]);
  final Signal<Set<String>> _globalTags = signal({});
  final Signal<List<String>> _selectedFolderIds = signal([]);
  final Signal<bool> _isArchiveMode = signal(false);

  late final Computed<bool> hasEntries = computed(() => _entries.value.isNotEmpty);

  InputMode get inputMode => _inputMode.value;
  List<LinkEntry> get entries => List.unmodifiable(_entries.value);
  Set<String> get globalTags => Set.unmodifiable(_globalTags.value);
  List<String> get selectedFolderIds => List.unmodifiable(_selectedFolderIds.value);
  bool get isArchiveMode => _isArchiveMode.value;

  void setInputMode(InputMode mode) {
    if (_inputMode.value != mode) {
      _inputMode.value = mode;
    }
  }

  void setArchiveMode({required bool value}) {
    if (_isArchiveMode.value != value) {
      _isArchiveMode.value = value;
    }
  }

  void setSelectedFolders(List<String> folderIds) {
    _selectedFolderIds.value = folderIds;
  }

  void addGlobalTag(String tag) {
    final cleanTag = tag.trim().toLowerCase();
    if (cleanTag.isNotEmpty && !_globalTags.value.contains(cleanTag)) {
      _globalTags.value = {..._globalTags.value, cleanTag};
    }
  }

  void removeGlobalTag(String tag) {
    if (_globalTags.value.contains(tag)) {
      _globalTags.value = Set.from(_globalTags.value)..remove(tag);
    }
  }

  void clearGlobalTags() {
    if (_globalTags.value.isNotEmpty) {
      _globalTags.value = {};
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
      ..._globalTags.value,
    }.toList();

    final entry = LinkEntry(
      key: UniqueKey(),
      url: url.trim(),
      tags: entryTags,
      folderIds: _selectedFolderIds.value.isEmpty
          ? ["default"]
          : List.of(_selectedFolderIds.value),
      isArchived: isArchived ?? _isArchiveMode.value,
      validationStatus: LinkValidationStatus.pending,
    );

    _entries.value = [..._entries.value, entry];

    if (validateAsync) {
      unawaited(_validateEntry(entry.key));
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
    unawaited(validateAllEntries(parallel: true));
  }

  /// Updates an existing entry
  void updateEntry(Key key, LinkEntry updatedEntry) {
    final current = _entries.value;
    final index = current.indexWhere((e) => e.key == key);
    if (index != -1) {
      final newList = List<LinkEntry>.from(current);
      newList[index] = updatedEntry;
      _entries.value = newList;
    }
  }

  /// Removes an entry
  void removeEntry(Key key) {
    final current = _entries.value;
    final newList = current.where((e) => e.key != key).toList();
    if (newList.length != current.length) {
      _entries.value = newList;
    }
  }

  /// Removes multiple entries
  void removeEntries(List<Key> keys) {
    final keySet = keys.toSet();
    final current = _entries.value;
    final newList = current.where((e) => !keySet.contains(e.key)).toList();
    if (newList.length != current.length) {
      _entries.value = newList;
    }
  }

  /// Clears all entries
  void clearEntries() {
    if (_entries.value.isNotEmpty) {
      _entries.value = [];
    }
  }

  /// Validates a specific entry asynchronously
  Future<void> _validateEntry(Key key) async {
    final current = _entries.value;
    final index = current.indexWhere((e) => e.key == key);
    if (index == -1) return;

    final entry = current[index];

    loggerGlobal.info(
        "CreateLinkNotifier", "Starting validation for URL: ${entry.url}");

    // Set validating status
    final list1 = List<LinkEntry>.from(current);
    list1[index] = entry.copyWith(
      validationStatus: LinkValidationStatus.validating,
    );
    _entries.value = list1;

    try {
      // Perform validation
      final result = await UrlValidatorService.validateUrl(entry.url);

      loggerGlobal.info("CreateLinkNotifier",
          "Validation completed for ${entry.url}: isValid=${result.isValid}, isReachable=${result.isReachable}, message=${result.message}");

      // Update entry with result (re-find index since list may have changed)
      final latest = _entries.value;
      final updatedIndex = latest.indexWhere((e) => e.key == key);
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

        final list2 = List<LinkEntry>.from(latest);
        list2[updatedIndex] = latest[updatedIndex].copyWith(
          validationStatus: status,
          validationMessage: result.message,
          validationStatusCode: result.statusCode,
        );
        _entries.value = list2;
      }
    } catch (e, stackTrace) {
      loggerGlobal.severe("CreateLinkNotifier",
          "Validation error for ${entry.url}: $e", e, stackTrace);

      // Mark as unreachable on error
      final latest = _entries.value;
      final updatedIndex = latest.indexWhere((e) => e.key == key);
      if (updatedIndex != -1) {
        final list3 = List<LinkEntry>.from(latest);
        list3[updatedIndex] = latest[updatedIndex].copyWith(
          validationStatus: LinkValidationStatus.unreachable,
          validationMessage: "Validation error: $e",
        );
        _entries.value = list3;
      }
    }
  }

  /// Validates all entries with a configurable strategy
  Future<void> validateAllEntries({bool parallel = true}) async {
    loggerGlobal.info("CreateLinkNotifier",
        "Starting ${parallel ? 'parallel' : 'sequential'} validation for ${_entries.value.length} entries");
    final startTime = DateTime.now();

    final keys = _entries.value.map((e) => e.key).toList(growable: false);

    if (parallel) {
      await Future.wait(keys.map(_validateEntry));
    } else {
      for (final key in keys) {
        await _validateEntry(key);
      }
    }

    final duration = DateTime.now().difference(startTime);
    loggerGlobal.info("CreateLinkNotifier",
        "${parallel ? 'Parallel' : 'Sequential'} validation completed in ${duration.inMilliseconds}ms");
  }

  /// Revalidates a specific entry
  Future<void> revalidateEntry(Key key) async {
    await _validateEntry(key);
  }

  /// Gets an entry by key
  LinkEntry? getEntry(Key key) {
    try {
      return _entries.value.firstWhere((e) => e.key == key);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _inputMode.dispose();
    _entries.dispose();
    _globalTags.dispose();
    _selectedFolderIds.dispose();
    _isArchiveMode.dispose();
    hasEntries.dispose();
  }
}
