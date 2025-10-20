import "package:flutter/material.dart";
import "package:chenron/shared/search/search_controller.dart";
import "package:chenron/shared/search/suggestion_builder.dart";
import "package:chenron/shared/utils/debouncer.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:signals/signals_flutter.dart";

/// A custom overlay that shows search suggestions without interfering with typing.
/// 
/// This widget listens to a SearchBarController with debouncing and displays
/// suggestions in an overlay positioned below the search bar.
class SuggestionsOverlay extends StatefulWidget {
  final SearchBarController controller;
  final Signal<Future<AppDatabaseHandler>> db;
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
    this.debounceDuration = const Duration(milliseconds: 300),
    this.onItemSelected,
  });

  @override
  State<SuggestionsOverlay> createState() => _SuggestionsOverlayState();
}

class _SuggestionsOverlayState extends State<SuggestionsOverlay> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late final Debouncer<List<ListTile>> _debouncer;
  List<ListTile> _suggestions = [];
  bool _isLoading = false;
  String _lastQuery = "";

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(duration: widget.debounceDuration);
    
    // Listen to query changes with debounce
    effect(() {
      final query = widget.controller.query.value;
      if (query != _lastQuery) {
        _lastQuery = query;
        _onQueryChanged(query);
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _debouncer.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    if (query.isEmpty) {
      _removeOverlay();
      return;
    }

    setState(() => _isLoading = true);

    // Debounce the database query
    _debouncer.call(() async {
      final suggestions = await _fetchSuggestions(query);
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
    });
  }

  Future<List<ListTile>> _fetchSuggestions(String query) async {
    if (!mounted) return [];
    
    final suggestionBuilder = GlobalSuggestionBuilder(
      db: widget.db,
      context: context,
      controller: null, // Not needed - using queryController instead
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
    
    return suggestionBuilder.buildSuggestions();
  }

  void _showOverlay() {
    _removeOverlay();
    
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size?.width ?? 600,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 8),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 400),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
                      itemBuilder: (context, index) => _suggestions[index],
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
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.child,
    );
  }
}
