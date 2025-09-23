# web_archiver

Archive.org client and helpers extracted into a reusable Dart package.

## Features
- ArchiveOrgClient with:
  - archiveUrl(): starts a capture (returns archived URL or job_id when pending)
  - checkStatus(): checks a job status by job_id
  - waitForCompletion(): polls until archive completes and returns final URL
  - archiveAndWait(): convenience wrapper to start and wait for completion
- ArchiveOrgClientFactory indirection for easy test mocking
- ArchiveOrgOptions to control capture parameters
- parseArchiveDate() helper to parse timestamps from archived URLs
- Uses package:logging (no dependency on app-specific loggers)

## Install (workspace)

Add to your workspace root pubspec.yaml:

```
workspace:
  - apps/chenron
  - packages/basedir
  - packages/web_archiver
```

In app pubspec.yaml:

```
dependencies:
  web_archiver: ^0.1.0
```

## Usage

```dart
import 'package:web_archiver/web_archiver.dart';

final client = ArchiveOrgClient('KEY', 'SECRET');
final archivedUrl = await client.archiveAndWait('https://example.com');
```

## Testing

- Offline: override the factory with a fake client

```dart
import 'package:web_archiver/web_archiver.dart';

class FakeClient extends ArchiveOrgClient {
  FakeClient() : super('', '');
  @override
  Future<String> archiveAndWait(String targetUrl) async =>
      'https://web.archive.org/web/20990101000000/$targetUrl';
}

void main() {
  archiveOrgClientFactory = (k, s) => FakeClient();
}
```

- Online: set env vars and run tests
  - CHENRON_ARCHIVE_ORG_KEY
  - CHENRON_ARCHIVE_ORG_SECRET

## Notes
- Network operations may be rate-limited by Archive.org; prefer offline tests for stability.
