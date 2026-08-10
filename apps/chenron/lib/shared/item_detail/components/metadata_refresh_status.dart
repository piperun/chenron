import "package:cache_manager/cache_manager.dart";
import "package:flutter/material.dart";

import "package:chenron/shared/item_detail/components/details_table.dart";
import "package:chenron/shared/utils/time_formatter.dart";

/// Read-only refresh history shown alongside a link's details.
class MetadataRefreshStatus extends StatelessWidget {
  final MetadataState state;

  const MetadataRefreshStatus({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final (metadata, phase, failure, available) = switch (state) {
      MetadataStateAvailable(
        :final data,
        :final refreshPhase,
        :final lastFailure,
      ) =>
        (data, refreshPhase, lastFailure, true),
      MetadataStateUnavailable(
        :final refreshPhase,
        :final lastFailure,
      ) =>
        (null, refreshPhase, lastFailure, false),
    };

    return Column(
      children: [
        if (metadata?.fetchedAt case final fetchedAt?)
          DetailRow(
            label: "Metadata updated",
            child: Text(TimeFormatter.formatFull(fetchedAt)),
          ),
        DetailRow(
          label: "Refresh",
          child: Text(_refreshLabel(phase, failure, available: available)),
        ),
        if (failure?.nextRetryAt case final retryAt?)
          DetailRow(
            label: "Retry",
            child: Text(TimeFormatter.formatFull(retryAt)),
          ),
      ],
    );
  }
}

String _refreshLabel(
  MetadataRefreshPhase phase,
  MetadataRefreshFailure? failure, {
  required bool available,
}) =>
    switch (phase) {
      MetadataRefreshPhase.refreshing => "Refreshing",
      MetadataRefreshPhase.idle => available ? "Up to date" : "Not fetched",
      MetadataRefreshPhase.failed => _failureLabel(failure),
    };

String _failureLabel(MetadataRefreshFailure? failure) {
  if (failure == null) return "Failed";
  final status = failure.statusCode;
  return status == null
      ? "Failed: ${failure.kind.name}"
      : "Failed: ${failure.kind.name} (HTTP $status)";
}
