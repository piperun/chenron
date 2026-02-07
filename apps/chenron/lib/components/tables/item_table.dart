import "package:flutter/material.dart";
import "package:trina_grid/trina_grid.dart";
import "package:chenron/notifiers/item_table_notifier.dart";

class DataGrid extends StatelessWidget {
  final List<TrinaColumn> columns;
  final List<TrinaRow<dynamic>> rows;
  final ItemTableNotifier<dynamic> notifier;

  const DataGrid({
    super.key,
    required this.columns,
    required this.rows,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TrinaGrid(
      columns: columns,
      rows: rows,
      onLoaded: (TrinaGridOnLoadedEvent event) {
        notifier.setStateManager(event.stateManager);
      },
      onRowChecked: notifier.onRowChecked,
      configuration: TrinaGridConfiguration(
        columnSize: const TrinaGridColumnSizeConfig(
          autoSizeMode: TrinaAutoSizeMode.scale,
        ),
        style: _buildStyle(colorScheme),
      ),
    );
  }

  static TrinaGridStyleConfig _buildStyle(ColorScheme cs) {
    return TrinaGridStyleConfig(
      gridBackgroundColor: cs.surface,
      rowColor: cs.surface,
      oddRowColor: cs.surfaceContainerLow,
      evenRowColor: cs.surface,
      activatedColor: cs.primaryContainer,
      columnCheckedColor: cs.primaryContainer,
      cellCheckedColor: cs.primaryContainer,
      rowCheckedColor: cs.primaryContainer.withValues(alpha: 0.3),
      rowHoveredColor: cs.surfaceContainerHighest,
      cellColorInEditState: cs.surfaceContainerHigh,
      cellColorInReadOnlyState: cs.surfaceContainerLow,
      cellReadonlyColor: cs.surfaceContainerLow,
      frozenRowColor: cs.surfaceContainer,
      frozenRowBorderColor: cs.outlineVariant,
      dragTargetColumnColor: cs.primaryContainer.withValues(alpha: 0.5),
      iconColor: cs.onSurfaceVariant,
      disabledIconColor: cs.onSurface.withValues(alpha: 0.2),
      menuBackgroundColor: cs.surfaceContainer,
      gridBorderColor: cs.outlineVariant,
      borderColor: cs.outlineVariant,
      activatedBorderColor: cs.primary,
      inactivatedBorderColor: cs.outlineVariant,
      columnTextStyle: TextStyle(
        color: cs.onSurface,
        decoration: TextDecoration.none,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      cellTextStyle: TextStyle(
        color: cs.onSurface,
        fontSize: 14,
      ),
    );
  }
}

