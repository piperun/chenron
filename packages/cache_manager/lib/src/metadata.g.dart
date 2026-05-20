// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Metadata _$MetadataFromJson(Map<String, dynamic> json) => _Metadata(
      url: json['url'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
      ttlDays: (json['ttlDays'] as num?)?.toInt() ?? 7,
      etag: json['etag'] as String?,
      contentHash: json['contentHash'] as String?,
      consecutiveUnchanged:
          (json['consecutiveUnchanged'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MetadataToJson(_Metadata instance) => <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'fetchedAt': instance.fetchedAt.toIso8601String(),
      'ttlDays': instance.ttlDays,
      'etag': instance.etag,
      'contentHash': instance.contentHash,
      'consecutiveUnchanged': instance.consecutiveUnchanged,
    };
