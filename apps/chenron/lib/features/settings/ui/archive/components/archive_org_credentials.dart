import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/state/archive_settings.dart";
import "package:chenron/features/settings/ui/credential_field.dart";
import "package:chenron/locator.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

class ArchiveOrgCredentialsWidget extends StatefulWidget {
  const ArchiveOrgCredentialsWidget({super.key});

  @override
  State<ArchiveOrgCredentialsWidget> createState() =>
      _ArchiveOrgCredentialsWidgetState();
}

class _ArchiveOrgCredentialsWidgetState
    extends State<ArchiveOrgCredentialsWidget> {
  late final ArchiveSettingsNotifier _notifier;
  late final TextEditingController _accessKeyController;
  late final TextEditingController _secretKeyController;

  @override
  void initState() {
    super.initState();
    _notifier = locator.get<SettingsCoordinator>().archive;
    final initial = _notifier.current.peek();
    _accessKeyController =
        TextEditingController(text: initial.archiveOrgS3AccessKey);
    _secretKeyController =
        TextEditingController(text: initial.archiveOrgS3SecretKey);

    _accessKeyController.addListener(_onAccessKeyChanged);
    _secretKeyController.addListener(_onSecretKeyChanged);
  }

  void _onAccessKeyChanged() {
    final current = _notifier.current.peek();
    if (current.archiveOrgS3AccessKey != _accessKeyController.text) {
      _notifier.update((s) =>
          s.copyWith(archiveOrgS3AccessKey: _accessKeyController.text));
    }
  }

  void _onSecretKeyChanged() {
    final current = _notifier.current.peek();
    if (current.archiveOrgS3SecretKey != _secretKeyController.text) {
      _notifier.update((s) =>
          s.copyWith(archiveOrgS3SecretKey: _secretKeyController.text));
    }
  }

  @override
  void dispose() {
    _accessKeyController.removeListener(_onAccessKeyChanged);
    _secretKeyController.removeListener(_onSecretKeyChanged);
    _accessKeyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final snapshot = _notifier.current.watch(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final externalAccess = snapshot.archiveOrgS3AccessKey ?? "";
      final externalSecret = snapshot.archiveOrgS3SecretKey ?? "";
      if (_accessKeyController.text != externalAccess) {
        _accessKeyController.value = _accessKeyController.value.copyWith(
          text: externalAccess,
          selection: TextSelection.collapsed(offset: externalAccess.length),
        );
      }
      if (_secretKeyController.text != externalSecret) {
        _secretKeyController.value = _secretKeyController.value.copyWith(
          text: externalSecret,
          selection: TextSelection.collapsed(offset: externalSecret.length),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const String serviceName = "archive.org";

    return ExpansionTile(
      title: const Text("$serviceName Configuration (S3 API)"),
      maintainState: true,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
          child: Text(
            "$serviceName API Credentials",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        CredentialTextField(
          controller: _accessKeyController,
          label: "S3 Access Key",
          hint: "Enter your $serviceName S3 access key",
        ),
        CredentialTextField(
          controller: _secretKeyController,
          label: "S3 Secret Key",
          hint: "Enter your $serviceName S3 secret key",
          isPassword: true,
        ),
        Padding(
          padding: const EdgeInsets.only(
              top: 4.0, left: 16.0, right: 16.0, bottom: 16.0),
          child: Text(
            "These credentials are required to upload content to $serviceName via their S3-compatible API. Leave blank if not using default archive.org uploads.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
      ],
    );
  }
}
