import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/src/core/handlers/vepr_operation.dart";
import "package:database/src/core/id.dart";
import "package:drift/drift.dart";

typedef BackupSettingsCreateInput = ({
  BackupSetting backupSetting,
  String userConfigId,
});

class BackupSettingsCreateVEPR extends VEPROperation<ConfigDatabase,
    BackupSettingsCreateInput, String, bool, BackupSettingsResultIds> {
  BackupSettingsCreateVEPR(super.db);

  @override
  void onValidate() {
    logStep("Validate", "Validating backup settings creation input.");

    if (input.userConfigId.trim().isEmpty) {
      throw ArgumentError("userConfigId cannot be empty.");
    }

    logStep("Validate", "Validation passed.");
  }

  @override
  Future<String> onExecute() async {
    logStep("Execute", "Creating backup settings record.");

    final String id = db.generateId();
    final companion = BackupSettingsCompanion.insert(
      id: id,
      userConfigId: input.userConfigId,
      backupFilename: Value(input.backupSetting.backupFilename),
      backupPath: Value(input.backupSetting.backupPath),
      backupInterval: Value(input.backupSetting.backupInterval),
    );

    await db.into(db.backupSettings).insert(companion);
    logStep("Execute", "Backup settings created with ID: $id");
    return id;
  }

  @override
  Future<bool> onProcess() async {
    logStep("Process", "No additional processing required.");
    return true;
  }

  @override
  BackupSettingsResultIds onBuildResult() {
    logStep("BuildResult", "Building result for backup settings ID: $execResult");
    return BackupSettingsResultIds(
      backupSettingsId: execResult,
      userConfigId: input.userConfigId,
    );
  }
}
