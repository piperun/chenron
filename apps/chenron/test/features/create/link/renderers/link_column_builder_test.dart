import "package:chenron/features/create/link/models/link_entry.dart";
import "package:chenron/features/create/link/renderers/link_column_builder.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:trina_grid/trina_grid.dart";

void main() {
  group("LinkColumnBuilder.findEntry", () {
    const keyA = ValueKey<String>("a");
    const keyB = ValueKey<String>("b");
    const entries = [
      LinkEntry(key: keyA, url: "https://a.example"),
      LinkEntry(key: keyB, url: "https://b.example"),
    ];

    test("returns the matching entry", () {
      expect(LinkColumnBuilder.findEntry(entries, keyA)?.url,
          "https://a.example");
      expect(LinkColumnBuilder.findEntry(entries, keyB)?.url,
          "https://b.example");
    });

    test("returns null for a key no longer present (does not throw)", () {
      // A row can outlive its entry: the entry was removed from `entries`
      // while the grid still holds the row. Looking that key up must not throw.
      const staleKey = ValueKey<String>("removed");
      expect(() => LinkColumnBuilder.findEntry(entries, staleKey),
          returnsNormally);
      expect(LinkColumnBuilder.findEntry(entries, staleKey), isNull);
    });

    test("returns null against an empty entry list", () {
      expect(LinkColumnBuilder.findEntry(const [], keyA), isNull);
    });
  });

  group("LinkColumnBuilder.build", () {
    testWidgets("produces the full column set", (tester) async {
      late List<TrinaColumn> columns;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              columns = LinkColumnBuilder.build(
                entries: const [
                  LinkEntry(key: ValueKey("a"), url: "https://a.example"),
                ],
                theme: Theme.of(context),
                context: context,
                folderNames: const {},
                globalTags: const {},
                onEdit: (_) {},
                onDelete: (_) {},
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(columns, hasLength(6));
    });
  });
}
