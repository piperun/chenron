# basedir

Typed, unbiased directory utilities for Flutter/Dart apps. Define your app’s directory structure with an enum and a small schema, then resolve and create directories in a cross-platform way.

## Features

- Enum-driven schemas: map enum keys to relative path segments
- No defaults or app bias: create exactly what you specify
- Debug/release aware app root
  - Debug: path_provider.getApplicationDocumentsDirectory()
  - Release: path_provider.getApplicationSupportDirectory()
- Helpers: getDefaultApplicationDirectory(), isDirWritable()

## Install (workspace)

This package is part of your Dart/Flutter workspace. Root `pubspec.yaml` includes:

```
workspace:
  - apps/chenron
  - packages/basedir
  - packages/web_archiver
```

In an app package:

```
dependencies:
  basedir: ^0.1.0
```

## Usage

Define your own enum and schema in your app:

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:basedir/directory.dart';

enum MyDirs { database, backupApp, backupConfig, log }

const mySchema = DirSchema<MyDirs>(paths: {
  MyDirs.database: ['database'],
  MyDirs.backupApp: ['backup', 'app'],
  MyDirs.backupConfig: ['backup', 'config'],
  MyDirs.log: ['log'],
});

final base = BaseDirectories<MyDirs>(
  appName: 'my_app',
  platformBaseDir: await getDefaultApplicationDirectory(debugMode: kDebugMode),
  schema: mySchema,
  debugMode: kDebugMode,
);

// Explicit creation: you decide what to create (no implicit defaults)
await base.create(include: {
  MyDirs.database,
  MyDirs.backupApp,
  MyDirs.backupConfig,
  MyDirs.log,
});

print(base[MyDirs.database].path); // <platform>/<my_app>/debug/database (in debug)
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
