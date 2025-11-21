import "package:flutter/material.dart";

class RailHeader extends StatelessWidget {
  final bool isExtended;
  final VoidCallback onToggleExtended;

  const RailHeader({
    super.key,
    required this.isExtended,
    required this.onToggleExtended,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isExtended)
            const Text(
              "FOLDERS",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          IconButton(
            icon: Icon(isExtended ? Icons.menu_open : Icons.menu),
            onPressed: onToggleExtended,
            tooltip: isExtended ? "Collapse" : "Expand",
          ),
        ],
      ),
    );
  }
}
