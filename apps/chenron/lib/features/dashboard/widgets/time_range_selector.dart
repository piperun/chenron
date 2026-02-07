import "package:flutter/material.dart";

enum TimeRange {
  week("7d", 7),
  month("30d", 30),
  quarter("90d", 90),
  all("All", 0);

  final String label;
  final int days;
  const TimeRange(this.label, this.days);

  DateTime? get startDate {
    if (this == all) return null;
    return DateTime.now().subtract(Duration(days: days));
  }
}

class TimeRangeSelector extends StatelessWidget {
  final TimeRange selected;
  final ValueChanged<TimeRange> onChanged;

  const TimeRangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TimeRange>(
      segments: TimeRange.values
          .map((range) => ButtonSegment<TimeRange>(
                value: range,
                label: Text(range.label),
              ))
          .toList(),
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStatePropertyAll<TextStyle>(
          Theme.of(context).textTheme.labelSmall!,
        ),
      ),
    );
  }
}
