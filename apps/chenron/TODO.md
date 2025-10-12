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
