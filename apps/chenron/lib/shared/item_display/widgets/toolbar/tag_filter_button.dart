import "package:flutter/material.dart";

class TagFilterButton extends StatelessWidget {
  final int includedCount;
  final int excludedCount;
  final VoidCallback? onPressed;

  const TagFilterButton({
    super.key,
    required this.includedCount,
    required this.excludedCount,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilters = includedCount > 0 || excludedCount > 0;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(
          color: hasFilters ? theme.colorScheme.secondary : theme.dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 16,
            color: hasFilters ? theme.colorScheme.secondary : null,
          ),
          const SizedBox(width: 8),
          Text(
            "Tags",
            style: TextStyle(
              color: hasFilters ? theme.colorScheme.secondary : null,
            ),
          ),
          if (includedCount > 0 || excludedCount > 0) ...[
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (includedCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "+$includedCount",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (includedCount > 0 && excludedCount > 0)
                  const SizedBox(width: 4),
                if (excludedCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "-$excludedCount",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
