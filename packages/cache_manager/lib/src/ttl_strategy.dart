import "dart:math";

/// Default base TTL for content pages, in days.
const int kDefaultBaseTtlDays = 7;

/// Base TTL applied when a title is detected as a site default, in days.
const int kDefaultTitleBaseTtlDays = 30;

/// Absolute upper bound for any computed TTL, in days.
const int kMaxTtlDays = 90;

// ---------------------------------------------------------------------------
// 1. computeAdaptiveTtl
// ---------------------------------------------------------------------------

/// Exponential back-off for unchanged refreshes.
///
/// Returns `baseDays * 2^consecutiveUnchanged`, clamped to [maxDays].
int computeAdaptiveTtl({
  int baseDays = kDefaultBaseTtlDays,
  required int consecutiveUnchanged,
  int maxDays = kMaxTtlDays,
}) {
  final exponent = consecutiveUnchanged.clamp(0, 30);
  final ttl = baseDays * (1 << exponent);
  return ttl.clamp(1, maxDays);
}

// ---------------------------------------------------------------------------
// 2. isDefaultTitle
// ---------------------------------------------------------------------------

/// Returns `true` when [title] appears to be the site's default homepage
/// title (i.e. it just repeats the domain name rather than describing
/// specific content).
///
/// Normalizes both strings to lowercase, strips `www.` from the host, and
/// extracts the domain core (first segment before the TLD). Returns `false`
/// for null/empty titles, titles shorter than 3 characters, or malformed
/// URLs.
bool isDefaultTitle(String? title, String url) {
  if (title == null || title.isEmpty || title.length < 3) return false;

  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;

  // Strip www. and lowercase.
  final host = uri.host.toLowerCase().replaceFirst(RegExp(r"^www\."), "");
  final normalizedTitle = title.toLowerCase();

  // Extract domain core: first segment of the host, excluding TLD.
  // e.g. "rule34.xxx" → "rule34", "docs.github.io" → "docs"
  final parts = host.split(".");
  if (parts.length < 2) return false;

  // The domain core is everything except the last part (TLD).
  // For two-part domains like "example.com", core = "example".
  // For three-part like "docs.github.io", core = "docs.github".
  // We check the first meaningful segment individually.
  final domainCore = parts.first;
  if (domainCore.length < 3) return false;

  // Check either direction: domain in title, or title in domain core.
  return normalizedTitle.contains(domainCore) ||
      domainCore.contains(normalizedTitle);
}

// ---------------------------------------------------------------------------
// 3. TtlTier enum + classifyUrlTtlTier
// ---------------------------------------------------------------------------

/// URL-based TTL classification tiers.
enum TtlTier {
  /// Homepages and static info pages — 30 days.
  long(30),

  /// Content pages and unrecognized patterns — 7 days.
  medium(7),

  /// Dynamic / personalized pages — 3 days.
  short(3);

  const TtlTier(this.baseDays);

  /// The default TTL in days for this tier.
  final int baseDays;
}

/// Path prefixes (first segment) that map to [TtlTier.long].
const _longPrefixes = [
  "about",
  "contact",
  "privacy",
  "terms",
  "tos",
  "legal",
  "imprint",
  "faq",
  "help",
];

/// Path prefixes (first segment) that map to [TtlTier.medium].
const _mediumPrefixes = [
  "post",
  "posts",
  "article",
  "articles",
  "blog",
  "news",
  "wiki",
  "thread",
];

/// Path prefixes (first segment) that map to [TtlTier.short].
const _shortPrefixes = [
  "user",
  "profile",
  "account",
  "search",
  "feed",
  "trending",
  "latest",
  "dashboard",
];

/// Search-related query parameter keys that indicate a short-lived page.
const _searchQueryKeys = ["q", "query", "search"];

/// Classify [url] into a [TtlTier] based on its path and query parameters.
///
/// Returns [TtlTier.medium] for unrecognized or malformed URLs.
TtlTier classifyUrlTtlTier(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) return TtlTier.medium;

  // Check search-related query params first — they override path.
  for (final key in _searchQueryKeys) {
    if (uri.queryParameters.containsKey(key)) return TtlTier.short;
  }

  final path = uri.path;

  // Homepage detection.
  if (path.isEmpty || path == "/") return TtlTier.long;

  // Extract the first non-empty segment and lowercase it.
  final segments = path.split("/").where((s) => s.isNotEmpty);
  if (segments.isEmpty) return TtlTier.long;
  final first = segments.first.toLowerCase();

  // Check short prefixes.
  for (final prefix in _shortPrefixes) {
    if (first == prefix || first.startsWith(prefix)) return TtlTier.short;
  }

  // Check long prefixes — also match compound forms like "terms-of-service".
  for (final prefix in _longPrefixes) {
    if (first == prefix ||
        first.startsWith(prefix) ||
        first.endsWith(prefix)) {
      return TtlTier.long;
    }
  }

  // Check medium prefixes.
  for (final prefix in _mediumPrefixes) {
    if (first == prefix || first.startsWith(prefix)) return TtlTier.medium;
  }

  // Default: medium.
  return TtlTier.medium;
}

// ---------------------------------------------------------------------------
// 4. computeInitialTtl
// ---------------------------------------------------------------------------

/// Determine the initial TTL (in days) for a freshly fetched page.
///
/// If [title] looks like the site's default title ([isDefaultTitle]), the
/// page probably has low-value metadata and gets a longer TTL
/// ([kDefaultTitleBaseTtlDays]). Otherwise the TTL comes from the URL tier.
int computeInitialTtl({String? title, required String url}) {
  if (isDefaultTitle(title, url)) return kDefaultTitleBaseTtlDays;
  return classifyUrlTtlTier(url).baseDays;
}

// ---------------------------------------------------------------------------
// 5. applyJitter
// ---------------------------------------------------------------------------

/// Apply +/-20 % random jitter to [ttlDays].
///
/// Result is rounded and clamped to `[1, kMaxTtlDays]`.
/// Pass a seeded [Random] for deterministic tests.
int applyJitter(int ttlDays, {Random? random}) {
  final rng = random ?? Random();
  final jittered = ttlDays * (0.8 + rng.nextDouble() * 0.4);
  return jittered.round().clamp(1, kMaxTtlDays);
}

// ---------------------------------------------------------------------------
// 6. hasContentChanged
// ---------------------------------------------------------------------------

/// Compare old vs new metadata fields. Returns `true` if any field differs.
///
/// All parameters are nullable — `null` is treated as a distinct value
/// (so `null` -> `"foo"` is a change, but `null` -> `null` is not).
bool hasContentChanged({
  String? oldTitle,
  String? newTitle,
  String? oldDescription,
  String? newDescription,
  String? oldImage,
  String? newImage,
}) {
  return oldTitle != newTitle ||
      oldDescription != newDescription ||
      oldImage != newImage;
}
