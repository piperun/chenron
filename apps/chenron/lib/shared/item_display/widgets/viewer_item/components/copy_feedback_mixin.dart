import "dart:async";
import "package:flutter/material.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";

/// Mixin that handles copy-to-clipboard with visual feedback.
///
/// Provides a [copied] flag that resets after 1500ms, and a [handleCopy]
/// method that copies the given text and manages the timer lifecycle.
mixin CopyFeedbackMixin<T extends StatefulWidget> on State<T> {
  bool copied = false;
  Timer? _copyResetTimer;

  void handleCopy(String text) {
    _copyResetTimer?.cancel();
    ItemUtils.copyUrl(text);
    setState(() => copied = true);
    _copyResetTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => copied = false);
    });
  }

  void disposeCopyFeedback() {
    _copyResetTimer?.cancel();
  }
}
