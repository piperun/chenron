import "package:chenron/notifiers/item_table_notifier.dart";
import "package:flutter_test/flutter_test.dart";
import "package:trina_grid/trina_grid.dart";

void main() {
  group("ItemTableNotifier.handleRowChecked", () {
    late ItemTableNotifier<dynamic> notifier;

    setUp(() => notifier = ItemTableNotifier<dynamic>());
    tearDown(() => notifier.dispose());

    test("a select-all event with null isChecked does not throw", () {
      // The header "select all" checkbox emits a TrinaGridOnRowCheckedAllEvent
      // whose isChecked is nullable and arrives null in the indeterminate
      // case. Force-unwrapping it would throw here.
      const event = TrinaGridOnRowCheckedAllEvent();

      expect(() => notifier.handleRowChecked(event), returnsNormally);
      expect(notifier.hasCheckedRows.value, isFalse);
    });

    test("a checked select-all event sets hasCheckedRows true", () {
      const event = TrinaGridOnRowCheckedAllEvent(isChecked: true);

      notifier.handleRowChecked(event);

      expect(notifier.hasCheckedRows.value, isTrue);
    });

    test("an unchecked select-all event sets hasCheckedRows false", () {
      notifier.hasCheckedRows.value = true;
      const event = TrinaGridOnRowCheckedAllEvent(isChecked: false);

      notifier.handleRowChecked(event);

      expect(notifier.hasCheckedRows.value, isFalse);
    });
  });
}
