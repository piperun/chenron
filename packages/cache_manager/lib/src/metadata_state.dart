import "package:freezed_annotation/freezed_annotation.dart";

import "package:cache_manager/src/metadata.dart";

part "metadata_state.freezed.dart";

/// What a consumer should render right now for a URL.
///
/// Three observable states cover every case the cache exposes:
///   - [MetadataState.loading] — initial state before/during the first
///     fetch; no data is available yet
///   - [MetadataState.ready] — fresh data is available
///   - [MetadataState.failed] — fetching failed and the back-off is
///     either exhausted or still in progress; [reason] explains why
///     and [attemptCount] is the number of attempts so far
///
/// There is intentionally no "stale" variant. Staleness is an internal
/// concern of the cache (it triggers a background refresh) and never
/// leaks to consumers — they always see one of the three states above.
@freezed
sealed class MetadataState with _$MetadataState {
  const MetadataState._();

  const factory MetadataState.loading() = MetadataStateLoading;

  const factory MetadataState.ready(Metadata data) = MetadataStateReady;

  const factory MetadataState.failed(
    String reason,
    int attemptCount,
  ) = MetadataStateFailed;
}
