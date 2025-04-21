import 'package:flutter/material.dart';

class BaseSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChange;
  final String label;

  const BaseSwitch({
    super.key,
    required this.value,
    required this.onChange,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return OverflowBar(
      alignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Switch(
          value: value,
          onChanged: onChange,
        ),
      ],
    );
  }
}
