import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:chenron/shared/search/search_history.dart";
import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(installTestLogger);

  test("loadHistory returns empty on corrupt prefs instead of throwing",
      () async {
    SharedPreferences.setMockInitialValues({
      "recent_searches": "{ this is not valid json",
    });

    final service = SearchHistoryService();
    expect(await service.loadHistory(), isEmpty);
  });

  test("loadHistory returns empty when the stored value is the wrong shape",
      () async {
    // Valid JSON, but an object where a list is expected.
    SharedPreferences.setMockInitialValues({
      "recent_searches": '{"not":"a list"}',
    });

    final service = SearchHistoryService();
    expect(await service.loadHistory(), isEmpty);
  });

  test("a save after corrupt data heals the history", () async {
    SharedPreferences.setMockInitialValues({"recent_searches": "garbage"});

    final service = SearchHistoryService();
    // saveHistoryItem reads first; it must not throw on the corrupt value.
    await service.saveHistoryItem(type: "link", id: "1", title: "Example");

    final history = await service.loadHistory();
    expect(history, hasLength(1));
    expect(history.first.id, "1");
  });

  test("valid history round-trips newest first", () async {
    SharedPreferences.setMockInitialValues({});

    final service = SearchHistoryService();
    await service.saveHistoryItem(type: "link", id: "1", title: "One");
    await service.saveHistoryItem(type: "folder", id: "2", title: "Two");

    final history = await service.loadHistory();
    expect(history.map((h) => h.id), ["2", "1"]);
  });
}
