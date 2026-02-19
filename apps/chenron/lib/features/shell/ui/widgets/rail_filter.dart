import "package:flutter/material.dart";
import "package:chenron/components/floating_label.dart";

class RailFilter extends StatefulWidget {
  final bool isExtended;
  final ValueChanged<String> onFilterChanged;

  const RailFilter({
    super.key,
    required this.isExtended,
    required this.onFilterChanged,
  });

  @override
  State<RailFilter> createState() => _RailFilterState();
}

class _RailFilterState extends State<RailFilter> {
  final _overlayController = OverlayPortalController();
  final _focusNode = FocusNode();
  final _textController = TextEditingController();
  final _link = LayerLink();

  @override
  void didUpdateWidget(RailFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the rail expands while the overlay is open, close it —
    // the inline TextField takes over.
    if (widget.isExtended && _overlayController.isShowing) {
      _overlayController.hide();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleToggleOverlay() {
    if (_overlayController.isShowing) {
      _closeOverlay();
    } else {
      _overlayController.show();
      // Focus after the overlay has been built.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _closeOverlay() {
    _overlayController.hide();
    if (_textController.text.isNotEmpty) {
      _textController.clear();
      widget.onFilterChanged("");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isExtended) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Filter folders...",
            prefixIcon: const Icon(Icons.filter_list, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
          ),
          onChanged: widget.onFilterChanged,
        ),
      );
    }

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (_) => _FilterOverlay(
          link: _link,
          focusNode: _focusNode,
          textController: _textController,
          onFilterChanged: widget.onFilterChanged,
          onClose: _closeOverlay,
        ),
        child: FloatingLabel(
          label: "Filter folders",
          child: IconButton(
            icon: const Icon(Icons.filter_list, size: 20),
            onPressed: _handleToggleOverlay,
          ),
        ),
      ),
    );
  }
}

class _FilterOverlay extends StatelessWidget {
  final LayerLink link;
  final FocusNode focusNode;
  final TextEditingController textController;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onClose;

  const _FilterOverlay({
    required this.link,
    required this.focusNode,
    required this.textController,
    required this.onFilterChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Dismiss on tap outside
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onClose,
          child: const SizedBox.expand(),
        ),
        // Positioned panel to the right of the icon
        CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.centerRight,
          followerAnchor: Alignment.centerLeft,
          offset: const Offset(4, 0),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            color: colorScheme.surfaceContainer,
            child: SizedBox(
              width: 220,
              child: TextField(
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: "Filter folders...",
                  prefixIcon: const Icon(Icons.filter_list, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onClose,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: colorScheme.surfaceContainer,
                ),
                onChanged: onFilterChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
