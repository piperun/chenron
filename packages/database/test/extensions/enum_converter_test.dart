import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:drift/drift.dart";
import "package:flutter_test/flutter_test.dart";

/// Round-trip characterization for the `intEnum<T>()` columns and their
/// generated [EnumIndexConverter]s.
///
/// Each enum variant is written through the typed companion and read
/// back through the typed row getter; the converter must map
/// `enum.index -> int -> enum` losslessly for every variant.
///
/// Also pins the documented failure mode: an out-of-enum-range int
/// stored in such a column throws [RangeError] when the converter tries
/// to index `enum.values[storedInt]` on read. This behavior caused the
/// historical "RangeError: -1" crash; the test locks it in so any
/// change to the converter (e.g. graceful clamping) is a conscious one.
String _id(String seed) => seed.padRight(32, "0");

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  group("AppDatabase intEnum converters", () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(
        databaseName: "test_enum_app_db",
        setupOnInit: true,
        debugMode: true,
      );
    });

    tearDown(() async {
      await db.delete(db.items).go();
      await db.delete(db.metadataRecords).go();
      await db.delete(db.folders).go();
      await db.close();
    });

    test("items.type_id round-trips every FolderItemType variant", () async {
      // A parent folder for the FK column (and realism).
      final folderId = _id("folder");
      await db.into(db.folders).insert(
            FoldersCompanion.insert(
              id: folderId,
              title: "Enum Folder",
              description: "holds enum round-trip items",
            ),
          );

      for (final variant in FolderItemType.values) {
        final rowId = _id("item-${variant.name}");
        await db.into(db.items).insert(
              ItemsCompanion.insert(
                id: rowId,
                folderId: folderId,
                itemId: _id("target-${variant.name}"),
                typeId: variant,
              ),
            );

        final row = await (db.select(db.items)
              ..where((t) => t.id.equals(rowId)))
            .getSingle();
        expect(row.typeId, variant,
            reason: "FolderItemType.${variant.name} must survive the trip");
      }
    });

    test("metadata_records.type_id round-trips every MetadataTypeEnum variant",
        () async {
      for (final variant in MetadataTypeEnum.values) {
        final rowId = _id("meta-${variant.name}");
        await db.into(db.metadataRecords).insert(
              MetadataRecordsCompanion.insert(
                id: rowId,
                typeId: variant,
                itemId: _id("mitem-${variant.name}"),
                metadataId: _id("mid-${variant.name}"),
              ),
            );

        final row = await (db.select(db.metadataRecords)
              ..where((t) => t.id.equals(rowId)))
            .getSingle();
        expect(row.typeId, variant);
      }
    });

    test("out-of-range items.type_id throws RangeError on read", () async {
      // FolderItemType has 3 variants (indices 0..2); 99 is out of range.
      // Insert raw so the converter is bypassed on write, then read.
      final folderId = _id("folder-bad");
      await db.into(db.folders).insert(
            FoldersCompanion.insert(
              id: folderId,
              title: "Bad Enum Folder",
              description: "row with an impossible type_id",
            ),
          );
      await db.customStatement(
        "INSERT INTO items (id, folder_id, item_id, type_id) "
        "VALUES (?, ?, ?, 99)",
        [_id("item-bad"), folderId, _id("target-bad")],
      );

      // EnumIndexConverter.fromSql does `FolderItemType.values[99]`.
      await expectLater(
        db.select(db.items).get(),
        throwsA(isA<RangeError>()),
      );
    });

    test("out-of-range metadata_records.type_id throws RangeError on read",
        () async {
      await db.customStatement(
        "INSERT INTO metadata_records (id, type_id, item_id, metadata_id) "
        "VALUES (?, 99, ?, ?)",
        [_id("meta-bad"), _id("mitem-bad"), _id("mid-bad")],
      );

      await expectLater(
        db.select(db.metadataRecords).get(),
        throwsA(isA<RangeError>()),
      );
    });
  });

  group("ConfigDatabase intEnum converters", () {
    late ConfigDatabase db;

    setUp(() {
      db = ConfigDatabase(
        databaseName: "test_enum_config_db",
        setupOnInit: false,
        debugMode: true,
      );
    });

    tearDown(() async {
      await db.delete(db.userThemes).go();
      await db.delete(db.userConfigs).go();
      await db.close();
    });

    test("user_configs round-trips every theme/time/click enum combination",
        () async {
      // Cross every variant of all three enums against each other so a
      // mis-wired converter on any one column is caught.
      var n = 0;
      for (final theme in ThemeType.values) {
        for (final time in TimeDisplayFormat.values) {
          for (final click in ItemClickAction.values) {
            final id = _id("cfg-${n++}");
            await db.into(db.userConfigs).insert(
                  UserConfigsCompanion.insert(
                    id: id,
                    selectedThemeType: Value(theme),
                    timeDisplayFormat: Value(time),
                    itemClickAction: Value(click),
                  ),
                );

            final row = await (db.select(db.userConfigs)
                  ..where((t) => t.id.equals(id)))
                .getSingle();
            expect(row.selectedThemeType, theme);
            expect(row.timeDisplayFormat, time);
            expect(row.itemClickAction, click);
          }
        }
      }
    });

    test("user_themes.seed_type round-trips every SeedType variant", () async {
      final configId = _id("cfg-for-themes");
      await db.into(db.userConfigs).insert(
            UserConfigsCompanion.insert(id: configId),
          );

      for (final variant in SeedType.values) {
        final themeId = _id("theme-${variant.name}");
        await db.into(db.userThemes).insert(
              UserThemesCompanion.insert(
                id: themeId,
                userConfigId: configId,
                name: "seed-${variant.name}",
                primaryColor: 0xFF112233,
                secondaryColor: 0xFF445566,
                seedType: Value(variant),
              ),
            );

        final row = await (db.select(db.userThemes)
              ..where((t) => t.id.equals(themeId)))
            .getSingle();
        expect(row.seedType, variant);
      }
    });

    test("out-of-range user_configs.selected_theme_type throws on read",
        () async {
      // ThemeType has 2 variants (0,1). Store 5 raw, then read.
      final id = _id("cfg-bad");
      await db.customStatement(
        "INSERT INTO user_configs (id, selected_theme_type, "
        "time_display_format, item_click_action) VALUES (?, 5, 0, 0)",
        [id],
      );

      await expectLater(
        db.select(db.userConfigs).get(),
        throwsA(isA<RangeError>()),
      );
    });
  });
}
