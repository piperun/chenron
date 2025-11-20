import "package:flutter/material.dart";

class TextHighlighter {
  static List<TextSpan> highlight(
      BuildContext context, String text, String query) {
    final ThemeData theme = Theme.of(context);
    final TextStyle baseStyle = DefaultTextStyle.of(context).style;

    if (query.isEmpty) return [TextSpan(text: text, style: baseStyle)];

    final matches = query.toLowerCase().allMatches(text.toLowerCase());
    if (matches.isEmpty) return [TextSpan(text: text, style: baseStyle)];

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    final highlightStyle = baseStyle.copyWith(
      fontWeight: FontWeight.bold,
      backgroundColor:
          theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
    );

    for (final match in matches) {
      if (match.start != lastMatchEnd) {
        spans.add(TextSpan(
            text: text.substring(lastMatchEnd, match.start), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: highlightStyle,
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd != text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: baseStyle));
    }

    return spans;
  }
}
