import "dart:async";
import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";

/// Describes one option in a [PathModeSelector].
class PathModeOption {
  /// Display label for the radio button.
  final String label;

  /// Resolves the subtitle text shown under the radio button.
  final Future<String> Function()? resolveSubtitle;

  /// Resolves the path value when this option is selected.
  /// If null, selecting this option calls [PathModeSelector.onPathChanged]
  /// with null (i.e. "use default").
  final Future<String> Function()? resolveValue;

  /// If true, this option shows a text field and folder picker.
  final bool isCustom;

  const PathModeOption({
    required this.label,
    this.resolveSubtitle,
    this.resolveValue,
    this.isCustom = false,
  });
}

/// A reusable radio-group widget for choosing between a default path,
/// optional named paths, and a custom user-specified path.
class PathModeSelector extends StatefulWidget {
  /// The current stored path, or null if using the default.
  final String? currentPath;

  /// Available options. Options with [PathModeOption.isCustom] show a
  /// text field and folder picker button.
  final List<PathModeOption> options;

  /// Called when the selected path changes. Receives null for default mode.
  final ValueChanged<String?> onPathChanged;

  /// Label text for the custom path text field.
  final String fieldLabel;

  /// Called during init to detect which option index matches [currentPath].
  /// Only invoked when [currentPath] is non-null. If not provided, defaults
  /// to the first custom option index.
  final Future<int> Function(String path)? detectInitialMode;

  const PathModeSelector({
    super.key,
    this.currentPath,
    required this.options,
    required this.onPathChanged,
    this.fieldLabel = "Path",
    this.detectInitialMode,
  });

  @override
  State<PathModeSelector> createState() => _PathModeSelectorState();
}

class _PathModeSelectorState extends State<PathModeSelector> {
  late TextEditingController _pathController;
  late int _selectedIndex;
  late Map<int, Future<String>> _subtitleFutures;

  int get _customIndex {
    final idx = widget.options.indexWhere((o) => o.isCustom);
    return idx >= 0 ? idx : widget.options.length - 1;
  }

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController(text: widget.currentPath ?? "");
    _subtitleFutures = _buildSubtitleFutures();

    if (widget.currentPath == null) {
      _selectedIndex = 0;
    } else {
      _selectedIndex = _customIndex;
      if (widget.detectInitialMode != null) {
        unawaited(_detectMode(widget.currentPath!));
      }
    }
  }

  Map<int, Future<String>> _buildSubtitleFutures() {
    return {
      for (var i = 0; i < widget.options.length; i++)
        if (widget.options[i].resolveSubtitle != null)
          i: widget.options[i].resolveSubtitle!(),
    };
  }

  Future<void> _detectMode(String path) async {
    final index = await widget.detectInitialMode!(path);
    if (mounted) setState(() => _selectedIndex = index);
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  void _handleModeChanged(int? index) {
    if (index == null) return;
    setState(() => _selectedIndex = index);

    final option = widget.options[index];
    if (option.isCustom) {
      if (_pathController.text.isNotEmpty) {
        widget.onPathChanged(_pathController.text);
      }
    } else if (option.resolveValue != null) {
      _pathController.clear();
      unawaited(_applyResolvedValue(option));
    } else {
      widget.onPathChanged(null);
      _pathController.clear();
    }
  }

  Future<void> _applyResolvedValue(PathModeOption option) async {
    final path = await option.resolveValue!();
    widget.onPathChanged(path);
  }

  Future<void> _handlePickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() => _pathController.text = result);
      widget.onPathChanged(result);
    }
  }

  void _onPathChanged(String value) {
    if (widget.options[_selectedIndex].isCustom && value.trim().isNotEmpty) {
      widget.onPathChanged(value.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustomSelected = widget.options[_selectedIndex].isCustom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioGroup<int>(
          groupValue: _selectedIndex,
          onChanged: _handleModeChanged,
          child: Column(
            children: [
              for (var i = 0; i < widget.options.length; i++)
                _buildRadioTile(theme, i, widget.options[i]),
            ],
          ),
        ),
        if (isCustomSelected)
          Padding(
            padding: const EdgeInsets.only(left: 32.0, top: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pathController,
                    decoration: InputDecoration(
                      labelText: widget.fieldLabel,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: _onPathChanged,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _handlePickFolder,
                  icon: const Icon(Icons.folder_open),
                  tooltip: "Browse for folder",
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRadioTile(ThemeData theme, int index, PathModeOption option) {
    if (_subtitleFutures.containsKey(index)) {
      return RadioListTile<int>(
        title: Text(option.label),
        value: index,
        contentPadding: EdgeInsets.zero,
        subtitle: FutureBuilder<String>(
          future: _subtitleFutures[index],
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? "Loading...",
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            );
          },
        ),
      );
    }
    return RadioListTile<int>(
      title: Text(option.label),
      value: index,
      contentPadding: EdgeInsets.zero,
    );
  }
}
