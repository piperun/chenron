import "dart:async";

import "package:cache_manager/cache_manager.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:signals/signals_flutter.dart";
import "package:url_launcher/url_launcher.dart" as url_launcher;
import "package:vibe/vibe.dart";

import "package:chenron/components/favicon_display/favicon.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/item_detail/item_detail_data.dart";
import "package:chenron/shared/item_detail/components/type_chip.dart";

class LinkHero extends StatefulWidget {
  final ItemDetailData data;

  const LinkHero({super.key, required this.data});

  @override
  State<LinkHero> createState() => _LinkHeroState();
}

class _LinkHeroState extends State<LinkHero> {
  /// Long-lived metadata signal owned by [MetadataService]. Hoisted
  /// once so the [Watch] in `build()` doesn't allocate on rebuild.
  Signal<MetadataState>? _metadataSignal;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    final url = widget.data.url;
    if (url != null && url.isNotEmpty) {
      _metadataSignal = locator.get<MetadataService>().watch(url);
    }
  }

  Future<void> _handleRefreshMetadata() async {
    final url = widget.data.url;
    if (url == null || _isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await locator.get<MetadataService>().forceFetch(url);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
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
    final metadataSignal = _metadataSignal;

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
        if (metadataSignal != null)
          Watch((context) {
            final state = metadataSignal.value;
            final ready =
                state is MetadataStateReady ? state.data : null;
            final title = ready?.title;
            final description = ready?.description;

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
          }),
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
            NierMinorButton(
              label: "Copy URL",
              icon: Icons.copy,
              onPressed: _handleCopyUrl,
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
