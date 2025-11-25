import "dart:async";
import "package:flutter/material.dart";

class RailBottomSection extends StatelessWidget {
  final bool showPlanInfo;
  final bool isExtended;
  final VoidCallback onAddPressed;

  const RailBottomSection({
    super.key,
    required this.showPlanInfo,
    required this.isExtended,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Plan info section (hidden by default)
          if (showPlanInfo)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isExtended)
                    const Text("Free", style: TextStyle(fontSize: 12)),
                  TextButton(
                    onPressed: () => _showUpgradeDialog(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: Colors.blue.shade700,
                        style: BorderStyle.solid,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isExtended ? "Upgrade" : "↑",
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          // Add New button (always shown)
          if (isExtended)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: const Text("Add New"),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            FloatingActionButton(
              onPressed: onAddPressed,
              tooltip: "Add New",
              mini: true,
              child: const Icon(Icons.add),
            ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    unawaited(showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Upgrade Plan"),
        content: const Text(
          "Premium features coming soon!\n\nChoose from Free, Premium 1, Premium 2, or Pay-as-you-go plans.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    ));
  }
}

