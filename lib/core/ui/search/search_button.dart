import 'package:flutter/material.dart';
import 'package:chenron/core/ui/search/search_view.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => SearchView(),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search,
                  size: 20,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Search...',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 48),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('⌘K'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
