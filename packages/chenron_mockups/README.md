# chenron_mockups

Test support utilities, mocks, and fixtures for Chenron project.

## Contents

### Mocks
- `archive_org_mock.dart` - Mock implementation of Archive.org client
- `mock_database.dart` - Mock database for testing
- `path_provider_fake.dart` - Fake path provider implementation
- `path_provider_mocks.dart` - Path provider mocks

### Factories & Fixtures
- `folder_factory.dart` - Factory for creating test Folder instances
- `link_factory.dart` - Factory for creating test Link instances
- `folder_test_data.json` - Test data for folders

### Utilities
- `logger_setup.dart` - Logger setup for tests
- `test_app.dart` - Test app wrapper

## Usage

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  chenron_mockups:
    path: ../../packages/chenron_mockups
```

Then import:

```dart
import 'package:chenron_mockups/chenron_mockups.dart';

// Use mocks
final mockDb = MockDatabase();

// Use factories
final testFolders = FolderFactory.createTestFolders();
final testLinks = LinkFactory.createTestLinks();
```
