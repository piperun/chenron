import 'dart:convert';

import 'package:chenron/database/database.dart';
import 'package:drift/drift.dart';

class UserConfigModel {
  final String? id;
  final bool? darkMode;
  final Map<String, dynamic>? colorScheme;
  final String? archiveOrgS3AccessKey;
  final String? archiveOrgS3SecretKey;

  UserConfigModel({
    this.id,
    this.darkMode,
    this.colorScheme,
    this.archiveOrgS3AccessKey,
    this.archiveOrgS3SecretKey,
  });
  @Deprecated(
      'DO NOT USE, internal solution within CRUD functions will be used instead')
  Insertable toCompanion(String id) {
    return UserConfigsCompanion.insert(
      id: id,
      darkMode: const Value(false),
      colorScheme: Value(colorScheme != null ? jsonEncode(colorScheme) : null),
      archiveOrgS3AccessKey: Value(archiveOrgS3AccessKey),
      archiveOrgS3SecretKey: Value(archiveOrgS3SecretKey),
    );
  }

  factory UserConfigModel.fromMap(Map<String, dynamic> map) {
    return UserConfigModel(
      id: map['id'] as String,
      darkMode: map['darkMode'] as bool,
      colorScheme: map['colorScheme'] != null
          ? jsonDecode(map['colorScheme'] as String)
          : null,
      archiveOrgS3AccessKey: map['archiveOrgS3AccessKey'] as String?,
      archiveOrgS3SecretKey: map['archiveOrgS3SecretKey'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'darkMode': darkMode,
      'colorScheme': colorScheme != null ? jsonEncode(colorScheme) : null,
      'archiveOrgS3AccessKey': archiveOrgS3AccessKey,
      'archiveOrgS3SecretKey': archiveOrgS3SecretKey,
    };
  }
}
