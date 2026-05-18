import "package:database/database.dart";
import "package:signals/signals.dart";

final appDatabaseAccessorSignal = signal(_buildLifecycle());

AppDatabaseLifecycle _buildLifecycle() {
  // Database location is assigned in MainSetup once base directories
  // resolve — mirrors the ConfigDatabase wiring.
  return AppDatabaseLifecycle();
}
