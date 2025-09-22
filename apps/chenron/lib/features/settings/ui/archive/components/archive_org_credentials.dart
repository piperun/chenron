import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/features/settings/ui/credential_field.dart";

class ArchiveOrgCredentialsWidget extends StatefulWidget {
  final ConfigController controller;

  const ArchiveOrgCredentialsWidget({
    super.key,
    required this.controller,
  });

  @override
  State<ArchiveOrgCredentialsWidget> createState() =>
      _ArchiveOrgCredentialsWidgetState();
}

class _ArchiveOrgCredentialsWidgetState
    extends State<ArchiveOrgCredentialsWidget> {
  late final TextEditingController _accessKeyController;
  late final TextEditingController _secretKeyController;

  @override
  void initState() {
    super.initState();
    _accessKeyController = TextEditingController(
        text: widget.controller.archiveOrgS3AccessKey.peek());
    _secretKeyController = TextEditingController(
        text: widget.controller.archiveOrgS3SecretKey.peek());

    _accessKeyController.addListener(_onAccessKeyChanged);
    _secretKeyController.addListener(_onSecretKeyChanged);
  }

  void _onAccessKeyChanged() {
    if (widget.controller.archiveOrgS3AccessKey.peek() !=
        _accessKeyController.text) {
      widget.controller.updateArchiveOrgS3AccessKey(_accessKeyController.text);
    }
  }

  void _onSecretKeyChanged() {
    if (widget.controller.archiveOrgS3SecretKey.peek() !=
        _secretKeyController.text) {
      widget.controller.updateArchiveOrgS3SecretKey(_secretKeyController.text);
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
    final externalAccessKey =
        widget.controller.archiveOrgS3AccessKey.watch(context);
    final externalSecretKey =
        widget.controller.archiveOrgS3SecretKey.watch(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (_accessKeyController.text != (externalAccessKey ?? "")) {
          _accessKeyController.value = _accessKeyController.value.copyWith(
            text: externalAccessKey ?? "",
            selection: TextSelection.collapsed(
                offset: (externalAccessKey ?? "").length),
          );
        }
        if (_secretKeyController.text != (externalSecretKey ?? "")) {
          _secretKeyController.value = _secretKeyController.value.copyWith(
            text: externalSecretKey ?? "",
            selection: TextSelection.collapsed(
                offset: (externalSecretKey ?? "").length),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const String serviceName = "archive.org";

    return ExpansionTile(
      title: Text("$serviceName Configuration (S3 API)"),
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
