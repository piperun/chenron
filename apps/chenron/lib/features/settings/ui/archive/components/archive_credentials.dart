import "package:flutter/material.dart";
import "package:chenron/features/settings/ui/credential_field.dart";
import "package:app_logger/app_logger.dart";

class ArchiveCredentials extends StatelessWidget {
  // Flags and callbacks for default archiving behavior
  final bool defaultArchiveIs;
  final ValueChanged<bool> onDefaultArchiveIsChanged;
  final bool defaultArchiveOrg;
  final ValueChanged<bool> onDefaultArchiveOrgChanged;

  // Controllers for archive.org credentials
  final TextEditingController accessKeyController;
  final TextEditingController secretKeyController;

  const ArchiveCredentials({
    super.key,
    required this.defaultArchiveIs,
    required this.onDefaultArchiveIsChanged,
    required this.defaultArchiveOrg,
    required this.onDefaultArchiveOrgChanged,
    required this.accessKeyController,
    required this.secretKeyController,
  });

  @override
  Widget build(BuildContext context) {
    const archiveOrgServiceName = "archive.org";

    return ExpansionTile(
      title: const Text("Default Archiving Configuration"),
      maintainState: true,
      children: [
        SwitchListTile(
          title: const Text("Archive to archive.is by Default"),
          subtitle: const Text(
              "Automatically enable archiving to archive.is for newly created items."),
          value: defaultArchiveIs,
          onChanged: (value) {
            onDefaultArchiveIsChanged(value);
            loggerGlobal.info(
                "ArchiveCredentials", "archive.is default archive: $value");
          },
        ),
        SwitchListTile(
          title: const Text("Archive to archive.org by Default"),
          subtitle: const Text(
              "Automatically enable archiving to archive.org for newly created items (requires credentials below)."),
          value: defaultArchiveOrg,
          onChanged: (value) {
            onDefaultArchiveOrgChanged(value);
            loggerGlobal.info(
                "ArchiveCredentials", "archive.org default archive: $value");
          },
        ),
        const Divider(height: 1), // Separator
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: Text(
            "$archiveOrgServiceName API Credentials (S3)",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        CredentialTextField(
          controller: accessKeyController,
          label: "Access Key",
          hint: "Enter your $archiveOrgServiceName S3 access key",
        ),
        CredentialTextField(
          controller: secretKeyController,
          label: "Secret Key",
          hint: "Enter your $archiveOrgServiceName S3 secret key",
          isPassword: true,
        ),
        Padding(
          padding: const EdgeInsets.only(
              top: 4.0,
              left: 16.0,
              right: 16.0,
              bottom: 16.0), // Added bottom padding
          child: Text(
            "These credentials are required to upload content to $archiveOrgServiceName via their S3-compatible API.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
        // No outer Divider needed if ExpansionTile is used within a list/column
      ],
    );
  }
}

