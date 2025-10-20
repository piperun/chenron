import "package:flutter/material.dart";

class LinkArchiveToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const LinkArchiveToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SwitchListTile(
          key: const Key("archive_toggle_switch"),
          title: const Text("Archive new links"),
          subtitle: const Text("Automatically archive links when added"),
          value: value,
          onChanged: onChanged,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
