import "package:freezed_annotation/freezed_annotation.dart";

import "package:cache_manager/src/metadata.dart";
import "package:cache_manager/src/metadata_refresh.dart";

part "metadata_state.freezed.dart";

/// What a consumer should render right now for a URL.
@freezed
sealed class MetadataState with _$MetadataState {
  const MetadataState._();

  const factory MetadataState.unavailable({
    @Default(MetadataRefreshPhase.idle) MetadataRefreshPhase refreshPhase,
    MetadataRefreshFailure? lastFailure,
  }) = MetadataStateUnavailable;

  const factory MetadataState.available({
    required Metadata data,
    required MetadataFreshness freshness,
    @Default(MetadataRefreshPhase.idle) MetadataRefreshPhase refreshPhase,
    MetadataRefreshFailure? lastFailure,
  }) = MetadataStateAvailable;
}
