import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart"; // Import signals
import "package:chenron/features/settings/controller/config_controller.dart"; // Import controller
// Import the specific widget (assuming it's adapted or we adapt it here)
import "package:chenron/features/settings/ui/archive/components/archive_org_credentials.dart";
import "package:logger/logger.dart";

class ArchiveSettings extends StatelessWidget {
  // Changed to StatelessWidget
  final ConfigController controller; // Accept the controller

  const ArchiveSettings({
    super.key,
    required this.controller, // Require the controller
  });

  @override
  Widget build(BuildContext context) {
    // Watch relevant signals for reactive UI updates
    final useDefaultIs = controller.defaultArchiveIs.watch(context);
    final useDefaultOrg = controller.defaultArchiveOrg.watch(context);
    final accessKey = controller.archiveOrgS3AccessKey.watch(context);
    final secretKey = controller.archiveOrgS3SecretKey.watch(context);

    // Determine if S3 keys are present directly from controller signals
    final bool s3KeysPresent = (accessKey?.trim().isNotEmpty ?? false) &&
        (secretKey?.trim().isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Default Archive Toggles
        Text(
          "Default Archiving Behavior",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text("Archive to archive.is by Default"),
          subtitle: const Text(
              "Automatically attempt archiving to archive.is for new items."),
          value: useDefaultIs,
          onChanged: (value) {
            controller.updateDefaultArchiveIs(enabled: value);
            loggerGlobal.info(
                "ArchiveSettings", "Default archive.is changed: $value");
          },
        ),
        SwitchListTile(
          title: const Text("Archive to archive.org by Default"),
          subtitle: Text(
            s3KeysPresent
                ? "Automatically attempt archiving to archive.org for new items."
                : "Enter S3 Access Key and Secret Key below to enable this option.",
            style: !s3KeysPresent
                ? TextStyle(color: Theme.of(context).disabledColor)
                : null,
          ),
          value: useDefaultOrg,
          onChanged: s3KeysPresent
              ? (value) {
                  controller.updateDefaultArchiveOrg(enabled: value);
                  loggerGlobal.info(
                      "ArchiveSettings", "Default archive.org changed: $value");
                }
              : null,
        ),
        const Divider(),
        ArchiveOrgCredentialsWidget(
          controller: controller,
        ),
      ],
    );
  }
}
