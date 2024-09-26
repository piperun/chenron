import 'dart:convert';

class UserConfigModel {
  final String id;
  final bool darkMode;
  final Map<String, dynamic>? colorScheme;
  final String? archiveOrgS3AccessKey;
  final String? archiveOrgS3SecretKey;

  UserConfigModel({
    required this.id,
    required this.darkMode,
    this.colorScheme,
    this.archiveOrgS3AccessKey,
    this.archiveOrgS3SecretKey,
  });

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
