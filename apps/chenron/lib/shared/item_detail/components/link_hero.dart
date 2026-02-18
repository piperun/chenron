import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:url_launcher/url_launcher.dart" as url_launcher;

import "package:chenron/components/favicon_display/favicon.dart";
import "package:chenron/components/metadata_factory.dart";
import "package:chenron/shared/item_detail/item_detail_data.dart";
import "package:chenron/shared/item_detail/components/type_chip.dart";

class LinkHero extends StatefulWidget {
  final ItemDetailData data;

  const LinkHero({super.key, required this.data});

  @override
  State<LinkHero> createState() => _LinkHeroState();
}

class _LinkHeroState extends State<LinkHero> {
  late Future<Map<String, dynamic>?> _metadataFuture;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _metadataFuture = widget.data.url != null
        ? MetadataFactory.getOrFetch(widget.data.url!)
        : Future.value(null);
  }

  Future<void> _handleRefreshMetadata() async {
    if (widget.data.url == null || _isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _metadataFuture = MetadataFactory.forceFetch(widget.data.url!);
    });
    await _metadataFuture;
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _handleOpenLink() async {
    if (widget.data.url == null) return;
    final uri = Uri.parse(widget.data.url!);
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri);
    }
  }

  void _handleCopyUrl() {
    if (widget.data.url == null) return;
    unawaited(Clipboard.setData(ClipboardData(text: widget.data.url!)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("URL copied to clipboard"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Domain row with favicon and type badge
        Row(
          children: [
            if (widget.data.url != null) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: Favicon(url: widget.data.url!),
              ),
              const SizedBox(width: 8),
            ],
            if (widget.data.domain != null)
              Expanded(
                child: Text(
                  widget.data.domain!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Spacer(),
            TypeChip(type: widget.data.itemType),
          ],
        ),
        const SizedBox(height: 12),

        // Metadata title + description
        FutureBuilder<Map<String, dynamic>?>(
          future: _metadataFuture,
          builder: (context, snapshot) {
            final title = snapshot.data?["title"] as String?;
            final description = snapshot.data?["description"] as String?;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title.isNotEmpty) ...[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (description != null && description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // Action buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _handleOpenLink,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text("Open Link"),
            ),
            OutlinedButton.icon(
              onPressed: _handleCopyUrl,
              icon: const Icon(Icons.copy, size: 16),
              label: const Text("Copy URL"),
            ),
            OutlinedButton.icon(
              onPressed: _isRefreshing ? null : _handleRefreshMetadata,
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 16),
              label: const Text("Refresh"),
            ),
          ],
        ),
      ],
    );
  }
}
