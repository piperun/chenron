import 'package:chenron/database/database.dart';
import 'package:chenron/models/item.dart';
import 'package:chenron/models/metadata.dart';
import 'package:drift/drift.dart';

extension DatabaseInit on AppDatabase {
  Future<void> setupEnumTypes() async {
    await _setupTypes<FolderItemType>(itemTypes, FolderItemType.values);
    await _setupTypes<MetadataTypeEnum>(metadataTypes, MetadataTypeEnum.values);
  }

  Future<void> _setupTypes<T extends Enum>(
      TableInfo table, List<T> enumValues) async {
    for (var type in enumValues) {
      final companion = _factoryCompanion(table, type);
      await into(table).insertOnConflictUpdate(companion);
    }
  }

  Insertable _factoryCompanion(TableInfo table, Enum type) {
    switch (table.actualTableName) {
      case 'item_types':
        return ItemTypesCompanion.insert(
          id: Value(type.index + 1),
          name: type.name,
        );
      case 'metadata_types':
        return MetadataTypesCompanion.insert(
          id: Value(type.index + 1),
          name: type.name,
        );
      default:
        throw ArgumentError('Unsupported table: ${table.actualTableName}');
    }
  }
}
