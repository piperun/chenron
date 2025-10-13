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
