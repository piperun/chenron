enum DocumentFileType {
  markdown,
  typst,
  pdf,
  html,
  docx,
}

extension DocumentFileTypeExtension on DocumentFileType {
  /// Whether this file type can be edited (by external editor)
  bool get isEditable {
    return this == DocumentFileType.markdown || this == DocumentFileType.typst;
  }

  /// Display name for UI (e.g., "Markdown", "PDF")
  String get displayName {
    return switch (this) {
      DocumentFileType.markdown => "Markdown",
      DocumentFileType.typst => "Typst",
      DocumentFileType.pdf => "PDF",
      DocumentFileType.html => "HTML",
      DocumentFileType.docx => "Word Document",
    };
  }

  /// Common file extensions for this type
  List<String> get extensions {
    return switch (this) {
      DocumentFileType.markdown => [".md", ".markdown"],
      DocumentFileType.typst => [".typ"],
      DocumentFileType.pdf => [".pdf"],
      DocumentFileType.html => [".html", ".htm"],
      DocumentFileType.docx => [".docx"],
    };
  }

  /// Detect file type from file path extension
  static DocumentFileType fromFilePath(String filePath) {
    final ext = filePath.toLowerCase();

    if (ext.endsWith(".md") || ext.endsWith(".markdown")) {
      return DocumentFileType.markdown;
    }
    if (ext.endsWith(".typ")) {
      return DocumentFileType.typst;
    }
    if (ext.endsWith(".pdf")) {
      return DocumentFileType.pdf;
    }
    if (ext.endsWith(".html") || ext.endsWith(".htm")) {
      return DocumentFileType.html;
    }
    if (ext.endsWith(".docx")) {
      return DocumentFileType.docx;
    }

    // Default to markdown for unknown types
    return DocumentFileType.markdown;
  }
}
