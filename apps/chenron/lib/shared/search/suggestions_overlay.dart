import "dart:async";
import "package:app_logger/app_logger.dart";
import "package:chenron/shared/constants/durations.dart";
import "package:chenron/shared/utils/text_highlighter.dart";
import "package:database/database.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:chenron/shared/search/search_controller.dart";
import "package:chenron/shared/search/suggestion_builder.dart";
import "package:chenron/shared/utils/debouncer.dart";
import "package:signals/signals_flutter.dart";

/// A custom overlay that shows search suggestions without interfering with typing.
///
/// Supports keyboard navigation: Up/Down to move selection, Enter to select,
/// Escape to dismiss.
class SuggestionsOverlay extends StatefulWidget {
  final SearchBarController controller;
  final Signal<AppDatabaseLifecycle> db;
  final Duration debounceDuration;
  final Future<void> Function({
    required String type,
    required String id,
    required String title,
  })? onItemSelected;
  final Widget child;

  const SuggestionsOverlay({
    super.key,
    required this.controller,
    required this.db,
    required this.child,
    this.debounceDuration = kDefaultDebounceDuration,
    this.onItemSelected,
  });

  @override
  State<SuggestionsOverlay> createState() => _SuggestionsOverlayState();
}

class _SuggestionsOverlayState extends State<SuggestionsOverlay> {
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  // Shared TapRegion id so taps inside either the search bar or the overlay
  // don't count as "outside".
  final Object _tapGroup = Object();
  OverlayEntry? _overlayEntry;
  late final Debouncer<List<SuggestionData>> _debouncer;
  late final void Function() _disposeQueryEffect;
  List<SuggestionData> _suggestions = [];
  int _selectedIndex = -1;
  bool _isLoading = false;
  String _lastQuery = "";
  // When set, suggestions stay hidden as long as the query equals this value.
  // Cleared as soon as the user types something different or empties the field.
  String? _dismissedQuery;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(duration: widget.debounceDuration);

    // Listen to query changes with debounce.
    // Deferred via addPostFrameCallback to avoid calling setState during
    // TextEditingController's notification dispatch.
    _disposeQueryEffect = effect(() {
      final query = widget.controller.query.value;
      if (query != _lastQuery) {
        _lastQuery = query;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _onQueryChanged(query);
        });
      }
    });
  }

  @override
  void dispose() {
    _disposeQueryEffect();
    _removeOverlay();
    _debouncer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _selectedIndex = -1;

    if (query.isEmpty) {
      _dismissedQuery = null;
      _removeOverlay();
      return;
    }

    // Different query than what was dismissed: re-enable suggestions.
    if (_dismissedQuery != null && query != _dismissedQuery) {
      _dismissedQuery = null;
    }

    if (_dismissedQuery == query) {
      _removeOverlay();
      return;
    }

    setState(() => _isLoading = true);

    // Debounce the database query
    unawaited(_debouncer.call(() async {
      final suggestions = await _fetchSuggestions();
      if (mounted && _lastQuery == query) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });

        if (suggestions.isNotEmpty) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
      return suggestions;
    }));
  }

  Future<List<SuggestionData>> _fetchSuggestions() async {
    if (!mounted) return [];

    final suggestionBuilder = GlobalSuggestionBuilder(
      db: widget.db,
      context: context,
      queryController: widget.controller,
      onItemSelected: ({required type, required id, required title}) async {
        _removeOverlay();
        await widget.onItemSelected?.call(
          type: type,
          id: id,
          title: title,
        );
      },
    );

    try {
      return await suggestionBuilder.buildSuggestions();
    } catch (e, s) {
      // Search-bar background fetch. The user is mid-keystroke — a
      // snackbar here would be noisy, so just log and return an empty
      // result set. The caller clears the spinner and removes the
      // overlay, exactly the same outcome as "no matches" — but the
      // failure is captured for diagnosis.
      loggerGlobal.severe(
          "SuggestionsOverlay", "Failed to build suggestions", e, s);
      return [];
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;
    if (_overlayEntry == null || _suggestions.isEmpty) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1).clamp(0, _suggestions.length - 1);
      });
      _overlayEntry?.markNeedsBuild();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1).clamp(0, _suggestions.length - 1);
      });
      _overlayEntry?.markNeedsBuild();
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_selectedIndex >= 0 && _selectedIndex < _suggestions.length) {
        _suggestions[_selectedIndex].onTap();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      _dismissedQuery = _lastQuery;
      _removeOverlay();
      _selectedIndex = -1;
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        width: size?.width ?? 600,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 8),
          child: TapRegion(
            groupId: _tapGroup,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              // Surface color goes on Material (the ink-splash root for
              // descendant ListTiles) rather than the wrapping Container,
              // so Flutter 3.44+ doesn't assert. Container keeps the
              // border + maxHeight constraints only.
              color: Theme.of(context).colorScheme.surface,
              clipBehavior: Clip.antiAlias,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _suggestions.length,
                        itemBuilder: (_, index) {
                          final item = _suggestions[index];
                          final isSelected = index == _selectedIndex;
                          final colorScheme = Theme.of(context).colorScheme;
                          // Use ListTile's built-in selected + selectedTileColor
                          // instead of wrapping in a colored Container — that
                          // avoids the Flutter 3.44+ DecoratedBox/ListTile
                          // assertion and gets us proper ink-splash behavior
                          // for free.
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: ListTile(
                              selected: isSelected,
                              selectedTileColor: colorScheme.primaryContainer,
                              selectedColor: colorScheme.onPrimaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              leading: Icon(item.icon),
                              title: RichText(
                                text: TextSpan(
                                  children: TextHighlighter.highlight(
                                    context,
                                    item.title,
                                    item.searchText,
                                  ),
                                ),
                              ),
                              subtitle: item.subtitle != null
                                  ? Text(
                                      item.subtitle!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    )
                                  : null,
                              onTap: item.onTap,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: _tapGroup,
      onTapOutside: (_) {
        if (_overlayEntry != null) {
          _dismissedQuery = _lastQuery;
          _removeOverlay();
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          child: widget.child,
        ),
      ),
    );
  }
}
