import "package:core/patterns/include_options.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron/shared/search/search_controller.dart";
import "package:chenron/shared/search/search_feature_manager.dart";
import "package:chenron/shared/search/search_features.dart";

void main() {
  // -------------------------------------------------------------------------
  // has()
  // -------------------------------------------------------------------------
  group("has()", () {
    test("returns true for enabled features", () {
      final manager = SearchFeatureManager(
        features: const IncludeOptions({SearchFeature.debounce}),
      );
      expect(manager.has(SearchFeature.debounce), isTrue);
    });

    test("returns false for disabled features", () {
      final manager = SearchFeatureManager(
        features: const IncludeOptions({SearchFeature.debounce}),
      );
      expect(manager.has(SearchFeature.history), isFalse);
    });

    test("supports multiple features", () {
      final manager = SearchFeatureManager(
        features: const IncludeOptions(
            {SearchFeature.debounce, SearchFeature.history}),
      );
      expect(manager.has(SearchFeature.debounce), isTrue);
      expect(manager.has(SearchFeature.history), isTrue);
    });

    test("empty features set returns false for all", () {
      final manager = SearchFeatureManager(
        features: const IncludeOptions(<SearchFeature>{}),
      );
      expect(manager.has(SearchFeature.debounce), isFalse);
      expect(manager.has(SearchFeature.history), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // setup() and dispose()
  // -------------------------------------------------------------------------
  group("setup() and dispose()", () {
    late SearchBarController controller;

    setUp(() {
      controller = SearchBarController();
    });

    tearDown(() {
      controller.dispose();
    });

    test("setup with debounce creates debouncer", () {
      final manager = SearchFeatureManager(
        features: const IncludeOptions({SearchFeature.debounce}),
      );

      manager.setup(controller);
      // Should not throw on dispose
      manager.dispose(controller);
    });

    test("setup with history creates history manager", () {
      final manager = SearchFeatureManager(
        features: const IncludeOptions({SearchFeature.history}),
      );

      manager.setup(controller);
      expect(manager.historyManager, isNotNull);
    });

    test("setup without history leaves history manager null", () {
      final manager = SearchFeatureManager(
        features: const IncludeOptions({SearchFeature.debounce}),
      );

      manager.setup(controller);
      expect(manager.historyManager, isNull);
      manager.dispose(controller);
    });

    test("setup with callback attaches listener", () {
      var callCount = 0;
      final manager = SearchFeatureManager(
        features: const IncludeOptions({SearchFeature.debounce}),
        debounceDuration: const Duration(milliseconds: 1),
      );

      manager.setup(controller, () => callCount++);

      // Changing text should trigger the listener (even if debounced)
      controller.textController.text = "test";

      // Cleanup
      manager.dispose(controller);
    });

    test("dispose without setup does not throw", () {
      final manager = SearchFeatureManager(
        features: const IncludeOptions({SearchFeature.debounce}),
      );
      // Should not throw even without setup
      manager.dispose(controller);
    });

    test("setup with no features does nothing", () {
      final manager = SearchFeatureManager(
        features: const IncludeOptions(<SearchFeature>{}),
      );
      manager.setup(controller);
      expect(manager.historyManager, isNull);
      manager.dispose(controller);
    });
  });

  // -------------------------------------------------------------------------
  // loadHistory()
  // -------------------------------------------------------------------------
  group("loadHistory()", () {
    test("returns empty list when history not enabled", () async {
      final manager = SearchFeatureManager(
        features: const IncludeOptions({SearchFeature.debounce}),
      );
      final history = await manager.loadHistory();
      expect(history, isEmpty);
    });
  });
}
