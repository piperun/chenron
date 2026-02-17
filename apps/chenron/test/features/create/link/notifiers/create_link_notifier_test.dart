import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/create/link/notifiers/create_link_notifier.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  late CreateLinkNotifier notifier;

  setUpAll(installTestLogger);

  setUp(() {
    notifier = CreateLinkNotifier();
  });

  tearDown(() {
    notifier.dispose();
  });

  group("initial state", () {
    test("starts with single input mode", () {
      expect(notifier.inputMode, InputMode.single);
    });

    test("starts with no entries", () {
      expect(notifier.entries, isEmpty);
      expect(notifier.hasEntries.value, false);
    });

    test("starts with no global tags", () {
      expect(notifier.globalTags, isEmpty);
    });

    test("starts with no selected folders", () {
      expect(notifier.selectedFolderIds, isEmpty);
    });

    test("starts with archive mode off", () {
      expect(notifier.isArchiveMode, false);
    });
  });

  group("input mode", () {
    test("switches to bulk mode", () {
      notifier.setInputMode(InputMode.bulk);
      expect(notifier.inputMode, InputMode.bulk);
    });

    test("switches back to single mode", () {
      notifier.setInputMode(InputMode.bulk);
      notifier.setInputMode(InputMode.single);
      expect(notifier.inputMode, InputMode.single);
    });

    test("does not change when setting same mode", () {
      notifier.setInputMode(InputMode.single); // same as initial
      expect(notifier.inputMode, InputMode.single);
    });

    test("changes when mode actually changes", () {
      notifier.setInputMode(InputMode.bulk);
      expect(notifier.inputMode, InputMode.bulk);
    });
  });

  group("archive mode", () {
    test("toggles on", () {
      notifier.setArchiveMode(value: true);
      expect(notifier.isArchiveMode, true);
    });

    test("toggles off", () {
      notifier.setArchiveMode(value: true);
      notifier.setArchiveMode(value: false);
      expect(notifier.isArchiveMode, false);
    });

    test("does not change when setting same value", () {
      notifier.setArchiveMode(value: false); // same as initial
      expect(notifier.isArchiveMode, false);
    });
  });

  group("folder selection", () {
    test("sets selected folders", () {
      notifier.setSelectedFolders(["folder-1", "folder-2"]);
      expect(notifier.selectedFolderIds, ["folder-1", "folder-2"]);
    });

    test("updates on folder change", () {
      notifier.setSelectedFolders(["folder-1"]);
      expect(notifier.selectedFolderIds, ["folder-1"]);
    });
  });

  group("global tags", () {
    test("adds a tag", () {
      notifier.addGlobalTag("flutter");
      expect(notifier.globalTags, {"flutter"});
    });

    test("trims and lowercases", () {
      notifier.addGlobalTag("  Flutter  ");
      expect(notifier.globalTags, {"flutter"});
    });

    test("ignores empty tags", () {
      notifier.addGlobalTag("");
      notifier.addGlobalTag("   ");
      expect(notifier.globalTags, isEmpty);
    });

    test("ignores duplicate tags", () {
      notifier.addGlobalTag("flutter");
      notifier.addGlobalTag("flutter");
      expect(notifier.globalTags.length, 1);
    });

    test("removes a tag", () {
      notifier.addGlobalTag("flutter");
      notifier.addGlobalTag("dart");
      notifier.removeGlobalTag("flutter");

      expect(notifier.globalTags, {"dart"});
    });

    test("does not change when removing non-existent tag", () {
      notifier.removeGlobalTag("nonexistent");
      expect(notifier.globalTags, isEmpty);
    });

    test("clears all tags", () {
      notifier.addGlobalTag("a");
      notifier.addGlobalTag("b");
      notifier.clearGlobalTags();

      expect(notifier.globalTags, isEmpty);
    });

    test("does not change when clearing already empty", () {
      notifier.clearGlobalTags();
      expect(notifier.globalTags, isEmpty);
    });
  });

  group("entry management", () {
    test("adds an entry", () {
      notifier.addEntry(url: "https://example.com", validateAsync: false);

      expect(notifier.entries.length, 1);
      expect(notifier.entries.first.url, "https://example.com");
      expect(notifier.hasEntries.value, true);
    });

    test("trims URL", () {
      notifier.addEntry(url: "  https://example.com  ", validateAsync: false);

      expect(notifier.entries.first.url, "https://example.com");
    });

    test("includes inline tags", () {
      notifier.addEntry(
        url: "https://example.com",
        tags: ["tag1", "tag2"],
        validateAsync: false,
      );

      expect(notifier.entries.first.tags, contains("tag1"));
      expect(notifier.entries.first.tags, contains("tag2"));
    });

    test("merges global tags with inline tags", () {
      notifier.addGlobalTag("global");
      notifier.addEntry(
        url: "https://example.com",
        tags: ["inline"],
        validateAsync: false,
      );

      expect(notifier.entries.first.tags, contains("global"));
      expect(notifier.entries.first.tags, contains("inline"));
    });

    test("uses selected folder IDs", () {
      notifier.setSelectedFolders(["folder-1", "folder-2"]);
      notifier.addEntry(url: "https://example.com", validateAsync: false);

      expect(
          notifier.entries.first.folderIds, ["folder-1", "folder-2"]);
    });

    test("defaults to 'default' folder when none selected", () {
      notifier.addEntry(url: "https://example.com", validateAsync: false);

      expect(notifier.entries.first.folderIds, ["default"]);
    });

    test("respects archive mode", () {
      notifier.setArchiveMode(value: true);
      notifier.addEntry(url: "https://example.com", validateAsync: false);

      expect(notifier.entries.first.isArchived, true);
    });

    test("allows override of archive per entry", () {
      notifier.setArchiveMode(value: true);
      notifier.addEntry(
        url: "https://example.com",
        isArchived: false,
        validateAsync: false,
      );

      expect(notifier.entries.first.isArchived, false);
    });

    test("starts with pending validation status", () {
      notifier.addEntry(url: "https://example.com", validateAsync: false);

      expect(notifier.entries.first.validationStatus,
          LinkValidationStatus.pending);
    });

    test("rejects duplicate URL", () {
      final first = notifier.addEntry(
          url: "https://example.com", validateAsync: false);
      final second = notifier.addEntry(
          url: "https://example.com", validateAsync: false);

      expect(first, true);
      expect(second, false);
      expect(notifier.entries.length, 1);
    });

    test("rejects duplicate URL after trimming", () {
      notifier.addEntry(url: "https://example.com", validateAsync: false);
      final dup = notifier.addEntry(
          url: "  https://example.com  ", validateAsync: false);

      expect(dup, false);
      expect(notifier.entries.length, 1);
    });
  });

  group("bulk entry management", () {
    test("adds multiple entries", () {
      notifier.addEntries([
        {"url": "https://one.com", "tags": <String>[]},
        {"url": "https://two.com", "tags": <String>["tag1"]},
      ]);

      expect(notifier.entries.length, 2);
      expect(notifier.entries[0].url, "https://one.com");
      expect(notifier.entries[1].url, "https://two.com");
    });

    test("skips duplicates within the batch", () {
      final skipped = notifier.addEntries([
        {"url": "https://one.com", "tags": <String>[]},
        {"url": "https://one.com", "tags": <String>[]},
        {"url": "https://two.com", "tags": <String>[]},
      ]);

      expect(skipped, 1);
      expect(notifier.entries.length, 2);
    });

    test("skips duplicates against existing entries", () {
      notifier.addEntry(url: "https://one.com", validateAsync: false);

      final skipped = notifier.addEntries([
        {"url": "https://one.com", "tags": <String>[]},
        {"url": "https://two.com", "tags": <String>[]},
      ]);

      expect(skipped, 1);
      expect(notifier.entries.length, 2);
    });
  });

  group("entry updates", () {
    test("updates an entry by key", () {
      notifier.addEntry(url: "https://old.com", validateAsync: false);
      final key = notifier.entries.first.key;

      notifier.updateEntry(
        key,
        notifier.entries.first.copyWith(url: "https://new.com"),
      );

      expect(notifier.entries.first.url, "https://new.com");
    });

    test("ignores update for non-existent key", () {
      notifier.addEntry(url: "https://example.com", validateAsync: false);

      notifier.updateEntry(
        UniqueKey(),
        const LinkEntry(
            key: ValueKey("fake"), url: "https://fake.com"),
      );

      // Original entry unchanged
      expect(notifier.entries.length, 1);
      expect(notifier.entries.first.url, "https://example.com");
    });
  });

  group("entry removal", () {
    test("removes an entry by key", () {
      notifier.addEntry(url: "https://one.com", validateAsync: false);
      notifier.addEntry(url: "https://two.com", validateAsync: false);
      final keyToRemove = notifier.entries.first.key;

      notifier.removeEntry(keyToRemove);

      expect(notifier.entries.length, 1);
      expect(notifier.entries.first.url, "https://two.com");
    });

    test("does not change when removing non-existent key", () {
      notifier.addEntry(url: "https://example.com", validateAsync: false);
      final entriesBefore = notifier.entries.length;

      notifier.removeEntry(UniqueKey());
      expect(notifier.entries.length, entriesBefore);
    });

    test("removes multiple entries", () {
      notifier.addEntry(url: "https://one.com", validateAsync: false);
      notifier.addEntry(url: "https://two.com", validateAsync: false);
      notifier.addEntry(url: "https://three.com", validateAsync: false);

      final keysToRemove =
          notifier.entries.take(2).map((e) => e.key).toList();
      notifier.removeEntries(keysToRemove);

      expect(notifier.entries.length, 1);
      expect(notifier.entries.first.url, "https://three.com");
    });

    test("clears all entries", () {
      notifier.addEntry(url: "https://one.com", validateAsync: false);
      notifier.addEntry(url: "https://two.com", validateAsync: false);

      notifier.clearEntries();

      expect(notifier.entries, isEmpty);
      expect(notifier.hasEntries.value, false);
    });

    test("does not change when clearing already empty", () {
      notifier.clearEntries();
      expect(notifier.entries, isEmpty);
    });
  });

  group("getEntry", () {
    test("returns entry by key", () {
      notifier.addEntry(url: "https://example.com", validateAsync: false);
      final key = notifier.entries.first.key;

      final entry = notifier.getEntry(key);
      expect(entry, isNotNull);
      expect(entry!.url, "https://example.com");
    });

    test("returns null for non-existent key", () {
      final entry = notifier.getEntry(UniqueKey());
      expect(entry, isNull);
    });
  });

  group("dispose", () {
    test("completes without errors", () {
      notifier.addGlobalTag("tag");
      notifier.setSelectedFolders(["folder"]);
      notifier.addEntry(url: "https://example.com", validateAsync: false);

      // Create a separate notifier for this test to avoid double-dispose
      // from tearDown
      final testNotifier = CreateLinkNotifier();
      testNotifier.addGlobalTag("tag");
      testNotifier.addEntry(url: "https://example.com", validateAsync: false);
      testNotifier.dispose();
      // No errors = pass
    });
  });

  group("signal reactivity", () {
    test("hasEntries reacts to addEntry", () {
      expect(notifier.hasEntries.value, false);

      notifier.addEntry(url: "https://example.com", validateAsync: false);
      expect(notifier.hasEntries.value, true);
    });

    test("hasEntries reacts to clearEntries", () {
      notifier.addEntry(url: "https://example.com", validateAsync: false);
      expect(notifier.hasEntries.value, true);

      notifier.clearEntries();
      expect(notifier.hasEntries.value, false);
    });

    test("entries signal updates on addEntry", () {
      var updateCount = 0;
      final dispose = notifier.hasEntries.subscribe((_) {
        updateCount++;
      });

      notifier.addEntry(url: "https://example.com", validateAsync: false);
      expect(updateCount, greaterThan(0));

      dispose();
    });

    test("entries signal updates on removeEntry", () {
      notifier.addEntry(url: "https://example.com", validateAsync: false);
      final key = notifier.entries.first.key;

      var updateCount = 0;
      final dispose = notifier.hasEntries.subscribe((_) {
        updateCount++;
      });

      notifier.removeEntry(key);
      expect(updateCount, greaterThan(0));

      dispose();
    });
  });
}
