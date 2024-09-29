class ArchiveOrgOptions {
  final bool captureAll;
  final bool captureOutlinks;
  final bool captureScreenshot;
  final bool delayWbAvailability;
  final bool forceGet;
  final bool skipFirstArchive;
  final String? ifNotArchivedWithin;
  final bool outlinksAvailability;
  final bool emailResult;
  final int jsBehaviorTimeout;

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

  Map<String, dynamic> toJson() {
    return {
      'capture_all': captureAll ? 1 : 0,
      'capture_outlinks': captureOutlinks ? 1 : 0,
      'capture_screenshot': captureScreenshot ? 1 : 0,
      'delay_wb_availability': delayWbAvailability ? 1 : 0,
      'force_get': forceGet ? 1 : 0,
      'skip_first_archive': skipFirstArchive ? 1 : 0,
      if (ifNotArchivedWithin != null)
        'if_not_archived_within': ifNotArchivedWithin,
      'outlinks_availability': outlinksAvailability ? 1 : 0,
      'email_result': emailResult ? 1 : 0,
      'js_behavior_timeout': jsBehaviorTimeout,
    };
  }
}
