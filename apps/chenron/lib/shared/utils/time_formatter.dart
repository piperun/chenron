import "package:intl/intl.dart";

/// Enum for different time display formats
enum TimeDisplayFormat {
  /// Relative time format (e.g., "2h ago", "5d ago")
  relative,

  /// Absolute time format (e.g., "2025-01-01 14:30")
  absolute,
}

/// Utility class for formatting timestamps
class TimeFormatter {
  /// Formats a DateTime as relative time (e.g., "2h ago", "5d ago")
  static String formatRelative(DateTime? dateTime) {
    if (dateTime == null) return "Unknown";

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return "${years}y ago";
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return "${months}mo ago";
    } else if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }

  /// Formats a DateTime as absolute time (e.g., "2025-01-01 14:30")
  static String formatAbsolute(DateTime? dateTime) {
    if (dateTime == null) return "Unknown";

    final formatter = DateFormat("yyyy-MM-dd HH:mm");
    return formatter.format(dateTime);
  }

  /// Formats a DateTime as full timestamp with seconds (e.g., "2025-01-01 14:30:45")
  static String formatFull(DateTime? dateTime) {
    if (dateTime == null) return "Unknown";

    final formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
    return formatter.format(dateTime);
  }

  /// Formats a DateTime based on the specified format preference
  static String format(DateTime? dateTime, TimeDisplayFormat format) {
    switch (format) {
      case TimeDisplayFormat.relative:
        return formatRelative(dateTime);
      case TimeDisplayFormat.absolute:
        return formatAbsolute(dateTime);
    }
  }

  /// Formats a DateTime for display in tooltips with full details
  static String formatTooltip(DateTime? dateTime) {
    if (dateTime == null) return "Unknown";

    final formatter = DateFormat("EEEE, MMMM d, yyyy 'at' HH:mm:ss");
    return formatter.format(dateTime);
  }
}

