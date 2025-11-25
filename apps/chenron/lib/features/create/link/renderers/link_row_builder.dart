import "package:trina_grid/trina_grid.dart";
import "package:chenron/features/create/link/models/link_entry.dart";

/// Builder for converting LinkEntry objects to TrinaRow objects
class LinkRowBuilder {
  static List<TrinaRow> build(List<LinkEntry> entries) {
    return entries.map((entry) {
      return TrinaRow(
        key: entry.key,
        cells: {
          "status": TrinaCell(value: ""),
          "url": TrinaCell(value: entry.url),
          "tags": TrinaCell(value: ""),
          "folders": TrinaCell(value: ""),
          "archived": TrinaCell(value: entry.isArchived ? "Yes" : "No"),
          "actions": TrinaCell(value: ""),
        },
      );
    }).toList();
  }
}

