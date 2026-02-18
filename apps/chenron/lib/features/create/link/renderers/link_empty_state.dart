import "package:flutter/material.dart";
import "package:chenron/shared/empty_state/empty_state.dart";

/// Empty state display for link tables.
class LinkEmptyState {
  static Widget build() {
    return const EmptyState(
      icon: Icons.link_off,
      message: "No links added yet",
      subtitle: "Add URLs above to see them here",
    );
  }
}
