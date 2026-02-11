import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/src/core/handlers/vepr_operation.dart";
import "package:database/src/core/id.dart";
import "package:drift/drift.dart";

typedef UserConfigCreateInput = UserConfig;

class UserConfigCreateVEPR extends VEPROperation<ConfigDatabase,
    UserConfigCreateInput, String, bool, UserConfigResultIds> {
  UserConfigCreateVEPR(super.db);

  @override
  void onValidate() {
    logStep("Validate", "Validating user config creation input.");
    logStep("Validate", "Validation passed.");
  }

  @override
  Future<String> onExecute() async {
    logStep("Execute", "Creating user config record.");

    final String id = db.generateId();
    final companion = UserConfigsCompanion.insert(
      id: id,
      darkMode: Value(input.darkMode),
      archiveOrgS3AccessKey: Value(input.archiveOrgS3AccessKey),
      archiveOrgS3SecretKey: Value(input.archiveOrgS3SecretKey),
      copyOnImport: Value(input.copyOnImport),
      defaultArchiveIs: Value(input.defaultArchiveIs),
      defaultArchiveOrg: Value(input.defaultArchiveOrg),
      selectedThemeType: Value(input.selectedThemeType),
      timeDisplayFormat: Value(input.timeDisplayFormat),
      itemClickAction: Value(input.itemClickAction),
      selectedThemeKey: Value(input.selectedThemeKey),
      cacheDirectory: Value(input.cacheDirectory),
    );

    await db.into(db.userConfigs).insert(companion);
    logStep("Execute", "User config created with ID: $id");
    return id;
  }

  @override
  Future<bool> onProcess() async {
    logStep("Process", "No additional processing required.");
    return true;
  }

  @override
  UserConfigResultIds onBuildResult() {
    logStep("BuildResult", "Building result for config ID: $execResult");
    return UserConfigResultIds(userConfigId: execResult);
  }
}
