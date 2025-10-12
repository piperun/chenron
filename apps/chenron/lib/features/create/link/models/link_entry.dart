import "package:flutter/foundation.dart";

enum LinkValidationStatus {
  pending,
  validating,
  valid,
  invalid,
  unreachable,
}

/// Represents a link entry that is being prepared for creation
class LinkEntry {
  final Key key;
  final String url;
  final List<String> tags;
  final List<String> folderIds;
  final bool isArchived;
  final String? comment;
  final LinkValidationStatus validationStatus;
  final String? validationMessage;

  LinkEntry({
    required this.key,
    required this.url,
    this.tags = const [],
    this.folderIds = const [],
    this.isArchived = false,
    this.comment,
    this.validationStatus = LinkValidationStatus.pending,
    this.validationMessage,
  });

  LinkEntry copyWith({
    Key? key,
    String? url,
    List<String>? tags,
    List<String>? folderIds,
    bool? isArchived,
    String? comment,
    LinkValidationStatus? validationStatus,
    String? validationMessage,
  }) {
    return LinkEntry(
      key: key ?? this.key,
      url: url ?? this.url,
      tags: tags ?? this.tags,
      folderIds: folderIds ?? this.folderIds,
      isArchived: isArchived ?? this.isArchived,
      comment: comment ?? this.comment,
      validationStatus: validationStatus ?? this.validationStatus,
      validationMessage: validationMessage ?? this.validationMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LinkEntry &&
        other.key == key &&
        other.url == url &&
        listEquals(other.tags, tags) &&
        listEquals(other.folderIds, folderIds) &&
        other.isArchived == isArchived &&
        other.comment == comment &&
        other.validationStatus == validationStatus &&
        other.validationMessage == validationMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      key,
      url,
      Object.hashAll(tags),
      Object.hashAll(folderIds),
      isArchived,
      comment,
      validationStatus,
      validationMessage,
    );
  }

  @override
  String toString() {
    return "LinkEntry(url: $url, tags: $tags, folders: $folderIds, archived: $isArchived, status: $validationStatus)";
  }
}
