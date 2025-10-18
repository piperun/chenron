# TODO: Post-Save Navigation Settings

## Feature: Customizable Post-Save Navigation Behavior

### Overview
Allow users to customize where they navigate after successfully saving a new item (Link, Folder, Document).

### User Story
**As a user**, I want to configure what happens after I save a new item, so that the app matches my workflow preferences.

### Configuration Options

1. **Return to Previous Page** (Default)
   - After saving, navigate back to where user was before (Dashboard, Viewer, etc.)
   - Best for: Users who add items occasionally

2. **Go to Viewer**
   - After saving, navigate to Viewer to see the newly added item
   - Best for: Users who want immediate verification

3. **Stay in Create Mode**
   - After saving, clear the form and allow adding another item of the same type
   - Best for: Users doing bulk additions

4. **Show Type Selector Again**
   - After saving, show the "Create New" type selector modal
   - Best for: Users adding multiple different types of items

### Implementation Tasks

- [ ] Add setting in `ConfigPage` under a new "Workflow" section
- [ ] Create enum for post-save navigation options:
  ```dart
  enum PostSaveNavigation {
    returnToPrevious,
    goToViewer,
    stayInCreateMode,
    showTypeSelector,
  }
  ```
- [ ] Store preference in config database
- [ ] Update `CreateLinkPage` to read preference and navigate accordingly
- [ ] Update `CreateFolderPage` to read preference and navigate accordingly
- [ ] Add tooltip/help text explaining each option

### Database Schema Addition
```sql
-- Add to config table
post_save_navigation TEXT DEFAULT 'returnToPrevious'
```

### UI Mockup (Settings Page)
```
┌─────────────────────────────────────────┐
│ Workflow Settings                       │
├─────────────────────────────────────────┤
│                                         │
│ After Saving an Item:                   │
│                                         │
│ ○ Return to previous page (Default)    │
│   Continue working where you left off   │
│                                         │
│ ○ Go to Viewer                          │
│   See your new item immediately         │
│                                         │
│ ○ Stay in create mode                   │
│   Add multiple items quickly            │
│                                         │
│ ○ Show type selector                    │
│   Choose what to add next               │
│                                         │
└─────────────────────────────────────────┘
```

### Priority
**Medium** - Quality of life improvement, not critical for MVP

### Related Features
- Quick "Add Another" snackbar action (can work alongside this)
- Keyboard shortcuts for creating items (Ctrl+N, etc.)
- Recent item history in type selector

### Testing Notes
- Test each navigation option with all item types (Link, Folder, Document)
- Verify preference persists across app restarts
- Test behavior when creating from different pages (Dashboard vs Viewer)
- Ensure "Cancel" always returns to previous page regardless of setting

---

## Notes
- Default should remain "Return to Previous Page" for least surprising behavior
- Consider A/B testing or analytics to see which option users prefer
- May want to have different preferences per item type (e.g., always go to Viewer for Links, stay in create mode for Folders)

---

# TODO: Bulk Link Validation Performance Optimization

## Feature: Multi-threaded Bulk Validation for Large Inputs

### Overview
Optimize bulk link validation performance for very large inputs (thousands of URLs) using Dart isolates and chunked processing.

### Current Implementation
- `BulkValidatorService.validateBulkInput()` processes all lines synchronously on the main thread
- Works well for typical use cases (< 1000 URLs)
- May cause UI lag with very large inputs

### Optimization Strategy

#### Phase 1: Chunked Processing (Future)
```dart
// Process validation in chunks to allow UI updates
static Future<BulkValidationResult> validateBulkInputAsync(String input, {
  int chunkSize = 100,
}) async {
  final lines = input.split("\n");
  final results = <LineValidationResult>[];
  
  for (int i = 0; i < lines.length; i += chunkSize) {
    final chunk = lines.skip(i).take(chunkSize);
    final chunkResults = _validateChunk(chunk, startIndex: i);
    results.addAll(chunkResults);
    
    // Allow UI to update between chunks
    await Future.delayed(Duration.zero);
  }
  
  return BulkValidationResult(lines: results);
}
```

#### Phase 2: Multi-threading with Isolates (Future)
```dart
// Use Dart isolates for true parallel processing
static Future<BulkValidationResult> validateBulkInputParallel(String input) async {
  final lines = input.split("\n");
  final numIsolates = Platform.numberOfProcessors;
  final chunkSize = (lines.length / numIsolates).ceil();
  
  final futures = <Future<List<LineValidationResult>>>[];
  
  for (int i = 0; i < numIsolates; i++) {
    final start = i * chunkSize;
    final end = min((i + 1) * chunkSize, lines.length);
    final chunk = lines.sublist(start, end);
    
    // Spawn isolate for this chunk
    futures.add(Isolate.run(() => _validateChunk(chunk, startIndex: start)));
  }
  
  final results = await Future.wait(futures);
  return BulkValidationResult(lines: results.expand((r) => r).toList());
}
```

### Performance Targets
- < 100 URLs: No optimization needed (< 50ms)
- 100-1000 URLs: Chunked processing (show progress)
- 1000+ URLs: Multi-threaded isolates (show progress bar)

### Implementation Tasks

- [ ] Benchmark current implementation with various input sizes
- [ ] Implement chunked validation with progress callback
- [ ] Create progress indicator UI for bulk validation
- [ ] Implement isolate-based parallel validation
- [ ] Add unit tests for concurrent validation
- [ ] Add setting to enable/disable parallel validation
- [ ] Document performance characteristics in code comments

### Testing Strategy
- Test with 10, 100, 1000, 10000 URLs
- Measure validation time and UI responsiveness
- Test cancellation of in-progress validation
- Verify validation results are identical between sync and async methods

### Priority
**Low** - Current implementation is sufficient for most use cases. Implement only if performance issues are reported.

### Related Components
- `lib/features/create/link/services/bulk_validator_service.dart`
- `lib/features/create/link/widgets/link_input_section.dart`
- `lib/components/TextBase/validating_text_controller.dart`

---

# TODO: URL Security Scanning Integration

## Feature: Phishing/Malware Detection for Links

### Overview
Integrate with open-source threat intelligence platforms and databases to scan URLs for phishing attempts, malware, and other security threats before adding them to the collection.

### User Story
**As a user**, I want to be notified if a URL I'm adding is flagged as potentially malicious, so that I can protect myself from phishing and malware threats.

### Potential Services/Databases

1. **AbuseIPDB** - https://www.abuseipdb.com/
   - IP reputation database
   - API for checking domain/IP abuse reports
   - Free tier available for limited queries

2. **OpenPhish** - https://openphish.com/
   - Timely phishing intelligence
   - Free phishing feed available
   - 7-day trends and active phishing URL database

3. **Phishing.Database** - https://github.com/Phishing-Database/Phishing.Database
   - Open-source phishing domains database
   - Regularly updated via GitHub
   - Free and open-source (MIT license)
   - Uses PyFunceble for validation

4. **GoPhish** - https://getgophish.com/
   - Open-source phishing framework
   - Could be used for internal phishing awareness testing
   - REST API available

5. **MISP** - https://www.misp-project.org/
   - Open Source Threat Intelligence Platform
   - Malware information sharing platform
   - Supports taxonomies, galaxy clusters, and IOC sharing
   - Can correlate data across multiple sources

### Implementation Considerations

#### Integration Approach
- [ ] Research API terms of service and rate limits for each service
- [ ] Design abstraction layer for multiple threat intelligence sources
- [ ] Implement caching to avoid repeated checks for same URLs
- [ ] Add user preference to enable/disable security scanning
- [ ] Consider offline mode with periodic database updates

#### UI/UX Design
```dart
enum ThreatLevel {
  safe,      // No threats detected
  suspicious, // Flagged by one source
  dangerous,  // Flagged by multiple sources
  unknown,    // Could not verify
}
```

**Visual Indicators:**
- ✅ Green checkmark for verified safe URLs
- ⚠️ Yellow warning for suspicious URLs (allow with confirmation)
- 🛑 Red block for dangerous URLs (require explicit override)
- ❓ Gray question mark for unverified URLs

#### Database Schema
```sql
-- Add to link table
CREATE TABLE url_security_scans (
  id TEXT PRIMARY KEY,
  url TEXT NOT NULL,
  threat_level TEXT NOT NULL, -- safe, suspicious, dangerous, unknown
  scanned_at INTEGER NOT NULL,
  sources_checked TEXT, -- JSON array of sources
  threat_details TEXT, -- JSON with details from each source
  expires_at INTEGER, -- Cache expiration
  FOREIGN KEY (url) REFERENCES links(url)
);
```

### Configuration Options

**Settings Page Section:**
```
┌─────────────────────────────────────────┐
│ Security Settings                       │
├─────────────────────────────────────────┤
│                                         │
│ URL Security Scanning:                  │
│ ☑ Enable automatic URL scanning         │
│                                         │
│ When to Scan:                           │
│ ○ Before adding to collection (Default) │
│ ○ After adding (background scan)        │
│ ○ Manual scan only                      │
│                                         │
│ Action on Threat Detection:             │
│ ○ Warn but allow (Default)              │
│ ○ Block and require override            │
│ ○ Automatically reject                  │
│                                         │
│ Cache Duration: [7 days ▼]              │
│                                         │
│ Data Sources: [Configure...]            │
│                                         │
└─────────────────────────────────────────┘
```

### Implementation Tasks

#### Phase 1: Foundation
- [ ] Research and document API requirements for each service
- [ ] Create `ThreatIntelligenceService` interface
- [ ] Implement local phishing database (Phishing.Database integration)
- [ ] Add security scan results to validation flow
- [ ] Create UI indicators for threat levels

#### Phase 2: API Integration
- [ ] Implement OpenPhish API client
- [ ] Implement AbuseIPDB API client
- [ ] Add API key management in settings
- [ ] Implement rate limiting and caching

#### Phase 3: Advanced Features
- [ ] MISP integration for enterprise users
- [ ] Automated database updates from GitHub sources
- [ ] Security scan history and reporting
- [ ] Bulk re-scan of existing links
- [ ] Export flagged URLs for review

### Privacy Considerations

⚠️ **Important Privacy Notes:**
- Scanning URLs means sending them to third-party services
- Users must be informed about data being sent externally
- Consider privacy setting to disable all external checks
- Local database mode for maximum privacy
- Clear disclosure in privacy policy

### Testing Strategy

- Test with known safe URLs (e.g., https://example.com)
- Test with known phishing URLs from test databases
- Test with recently reported threats
- Test offline mode and caching
- Test rate limiting behavior
- Test bulk scanning performance

### Priority
**Medium-High** - Security feature that adds value, especially for users managing large link collections or sharing links with others.

### Related Features
- Link validation service
- Bulk URL processing
- User preferences/settings
- Database caching layer
- Background job processing

### Open Questions

- Should we scan existing links periodically?
- How to handle false positives?
- Should users be able to whitelist domains?
- Integration with browser safe browsing APIs?
- Compliance with data protection regulations?

### Resources

- [AbuseIPDB Documentation](https://www.abuseipdb.com/api)
- [OpenPhish Feed](https://openphish.com/feed.txt)
- [Phishing.Database GitHub](https://github.com/Phishing-Database/Phishing.Database)
- [MISP API Documentation](https://www.misp-project.org/documentation/)
- [OWASP Phishing Guide](https://owasp.org/www-community/attacks/Phishing)
