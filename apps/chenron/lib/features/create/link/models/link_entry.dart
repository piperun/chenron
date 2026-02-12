import "package:flutter/foundation.dart";
import "package:freezed_annotation/freezed_annotation.dart";

part "link_entry.freezed.dart";

enum LinkValidationStatus {
  pending,
  validating,
  valid,
  invalid,
  unreachable,
}

/// Represents a link entry that is being prepared for creation
@freezed
abstract class LinkEntry with _$LinkEntry {
  const factory LinkEntry({
    required Key key,
    required String url,
    @Default([]) List<String> tags,
    @Default([]) List<String> folderIds,
    @Default(false) bool isArchived,
    String? comment,
    @Default(LinkValidationStatus.pending)
    LinkValidationStatus validationStatus,
    String? validationMessage,
    int? validationStatusCode,
  }) = _LinkEntry;
}
