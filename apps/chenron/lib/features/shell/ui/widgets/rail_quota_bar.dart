import "package:flutter/material.dart";

class RailQuotaBar extends StatelessWidget {
  final bool isExtended;

  const RailQuotaBar({
    super.key,
    required this.isExtended,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder for quota bar - will be fully implemented later
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isExtended)
            const Text(
              "0 / 20",
              style: TextStyle(fontSize: 12),
            ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: 0.0,
            backgroundColor: Colors.grey.shade800,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
