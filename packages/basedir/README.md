# basedir

Directory utilities for Chenron applications. Provides a consistent, cross-platform base layout and helpers for directory creation and writability checks.

## Features

- ChenronDirectories class that resolves application directories:
  - chenron/(debug/)/database
  - chenron/(debug/)/backup/app
  - chenron/(debug/)/backup/config
  - chenron/(debug/)/log
- Respect debug/release:
  - Debug: path_provider.getApplicationDocumentsDirectory()
  - Release: path_provider.getApplicationSupportDirectory()
- getDefaultApplicationDirectory(): picks a writable directory or throws
- isDirWritable(): quickly verifies write access

## Install (workspace)

This package is part of your Dart/Flutter workspace. Root `pubspec.yaml` includes:

```
workspace:
  - apps/chenron
  - packages/basedir
```

In `apps/chenron/pubspec.yaml`:

```
dependencies:
  basedir: ^0.1.0
```

## Usage

```dart
import 'package:basedir/directory.dart';

final baseDirs = ChenronDirectories(
  databaseName: File('app.sqlite'),
  baseDir: await getDefaultApplicationDirectory(debugMode: kDebugMode),
);
await baseDirs.createDirectories();
print(baseDirs.databaseDir.path);
```

## Testing

- The package includes its own tests under `packages/basedir/test`.
- Run them with:

```
flutter test packages/basedir
```

## Notes

- On Windows, directory ACLs can block writes. Use `isDirWritable()` to confirm the chosen base dir is writable before continuing.
- In tests, prefer using temporary directories to avoid permission issues.
