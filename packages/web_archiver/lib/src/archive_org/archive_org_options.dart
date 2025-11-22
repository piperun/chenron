/// Options for configuring the archiving process.
class ArchiveOrgOptions {
  /// Whether to capture all resources (images, css, etc.) even if they are already archived.
  final bool captureAll;

  /// Whether to capture outlinks (links on the page) as well.
  final bool captureOutlinks;

  /// Whether to capture a screenshot of the page.
  final bool captureScreenshot;

  /// Whether to delay the availability of the archived snapshot in the Wayback Machine.
  final bool delayWbAvailability;

  /// Whether to force a fresh capture even if a recent one exists.
  final bool forceGet;

  /// Whether to skip the first archive attempt if it fails.
  final bool skipFirstArchive;

  /// Only archive if the page hasn't been archived within this duration (e.g., "1d", "2h").
  final String? ifNotArchivedWithin;

  /// Whether to check for the availability of outlinks in the Wayback Machine.
  final bool outlinksAvailability;

  /// Whether to email the result of the archiving process.
  final bool emailResult;

  /// The timeout for JavaScript behavior during capture, in seconds.
  final int jsBehaviorTimeout;

  /// Creates a new [ArchiveOrgOptions] instance.
  ArchiveOrgOptions({
    this.captureAll = false,
    this.captureOutlinks = false,
    this.captureScreenshot = false,
    this.delayWbAvailability = false,
    this.forceGet = false,
    this.skipFirstArchive = false,
    this.ifNotArchivedWithin,
    this.outlinksAvailability = false,
    this.emailResult = false,
    this.jsBehaviorTimeout = 5,
  });

  /// Converts the options to a JSON map suitable for the API.
  Map<String, dynamic> toJson() {
    return {
      "capture_all": captureAll ? 1 : 0,
      "capture_outlinks": captureOutlinks ? 1 : 0,
      "capture_screenshot": captureScreenshot ? 1 : 0,
      "delay_wb_availability": delayWbAvailability ? 1 : 0,
      "force_get": forceGet ? 1 : 0,
      "skip_first_archive": skipFirstArchive ? 1 : 0,
      if (ifNotArchivedWithin != null)
        "if_not_archived_within": ifNotArchivedWithin,
      "outlinks_availability": outlinksAvailability ? 1 : 0,
      "email_result": emailResult ? 1 : 0,
      "js_behavior_timeout": jsBehaviorTimeout,
    };
  }
}
