import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart" as url_launcher;

import "package:chenron/shared/item_detail/item_detail_data.dart";
import "package:chenron/shared/utils/time_formatter.dart";

class DetailsTable extends StatelessWidget {
  final ItemDetailData data;

  const DetailsTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (data.createdAt != null)
          DetailRow(
            label: "Created",
            child: Text(
              "${TimeFormatter.formatFull(data.createdAt)} (${TimeFormatter.formatRelative(data.createdAt)})",
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        if (data.updatedAt != null && data.updatedAt != data.createdAt)
          DetailRow(
            label: "Updated",
            child: Text(
              "${TimeFormatter.formatFull(data.updatedAt)} (${TimeFormatter.formatRelative(data.updatedAt)})",
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        if (data.url != null)
          DetailRow(
            label: "URL",
            child: SelectableText(
              data.url!,
              style: TextStyle(
                fontSize: 12,
                fontFamily: "monospace",
                color: theme.colorScheme.primary,
              ),
              maxLines: 2,
            ),
          ),
        if (data.domain != null)
          DetailRow(
            label: "Domain",
            child: Text(
              data.domain!,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        if (data.archiveOrgUrl != null ||
            data.archiveIsUrl != null ||
            data.localArchivePath != null)
          DetailRow(
            label: "Archives",
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (data.archiveOrgUrl != null)
                  ArchiveBadge(
                    label: "archive.org",
                    url: data.archiveOrgUrl,
                  ),
                if (data.archiveIsUrl != null)
                  ArchiveBadge(
                    label: "archive.is",
                    url: data.archiveIsUrl,
                  ),
                if (data.localArchivePath != null)
                  const ArchiveBadge(label: "Local backup"),
              ],
            ),
          ),
      ],
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final Widget child;

  const DetailRow({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class ArchiveBadge extends StatelessWidget {
  final String label;
  final String? url;

  const ArchiveBadge({super.key, required this.label, this.url});

  Future<void> _handleTap() async {
    if (url == null) return;
    final uri = Uri.tryParse(url!);
    if (uri != null) {
      await url_launcher.launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (url != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.open_in_new,
                size: 11,
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );

    if (url != null) {
      return InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(4),
        child: badge,
      );
    }
    return badge;
  }
}
