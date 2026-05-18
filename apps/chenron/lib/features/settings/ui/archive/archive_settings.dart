import "package:app_logger/app_logger.dart";
import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/state/archive_settings.dart";
import "package:chenron/features/settings/ui/archive/components/archive_org_credentials.dart";
import "package:chenron/locator.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

class ArchiveSettingsPanel extends StatelessWidget {
  const ArchiveSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = locator.get<SettingsCoordinator>().archive;
    final ArchiveSettings snapshot = notifier.current.watch(context);

    final bool s3KeysPresent =
        (snapshot.archiveOrgS3AccessKey?.trim().isNotEmpty ?? false) &&
            (snapshot.archiveOrgS3SecretKey?.trim().isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Default Archiving Behavior",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text("Archive to archive.is by Default"),
          subtitle: const Text(
              "Automatically attempt archiving to archive.is for new items."),
          value: snapshot.defaultArchiveIs,
          onChanged: (value) {
            notifier.update((s) => s.copyWith(defaultArchiveIs: value));
            loggerGlobal.info(
                "ArchiveSettingsPanel", "Default archive.is changed: $value");
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
          value: snapshot.defaultArchiveOrg,
          onChanged: s3KeysPresent
              ? (value) {
                  notifier
                      .update((s) => s.copyWith(defaultArchiveOrg: value));
                  loggerGlobal.info(
                    "ArchiveSettingsPanel",
                    "Default archive.org changed: $value",
                  );
                }
              : null,
        ),
        const Divider(),
        const ArchiveOrgCredentialsWidget(),
      ],
    );
  }
}
