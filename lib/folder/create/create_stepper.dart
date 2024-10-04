import "package:chenron/database/extensions/payload.dart";
import "package:chenron/models/folder.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/database/database.dart";
import "package:chenron/folder/create/steps/folder_data.dart";
import "package:chenron/folder/create/steps/folder_info.dart";
import "package:chenron/folder/create/steps/folder_preview.dart";
import "package:chenron/responsible_design/breakpoints.dart";
import "package:chenron/providers/create_state.dart";
import "package:chenron/providers/cud_state.dart";
import "package:chenron/providers/folder_info_state.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

enum FolderStep { info, data, preview }

class CreateFolderStepper extends StatelessWidget {
  const CreateFolderStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<CreateFolderState>(
          builder: (context, folderState, child) {
            return Stepper(
              type: Breakpoints.isMedium(context)
                  ? StepperType.horizontal
                  : StepperType.vertical,
              currentStep: folderState.currentStep.index,
              controlsBuilder: (context, details) =>
                  StepperControls(details: details, folderState: folderState),
              onStepCancel: folderState.previousStep,
              onStepContinue: () {
                _nextStep(context, folderState);
              },
              onStepTapped: (index) =>
                  folderState.setCurrentStep(FolderStep.values[index]),
              steps: _buildSteps(folderState),
            );
          },
        ),
      ),
    );
  }

  void _nextStep(BuildContext context, CreateFolderState folderState) {
    if (folderState.currentStep == FolderStep.preview) {
      final folderInfo =
          Provider.of<FolderInfoProvider>(context, listen: false);

      final folderContent =
          Provider.of<CUDProvider<FolderItem>>(context, listen: false);

      _saveToDatabase(
          context,
          FolderInfo(
              title: folderInfo.title, description: folderInfo.description),
          folderInfo.tags
              .map((tag) => Metadata(type: MetadataTypeEnum.tag, value: tag))
              .toList(),
          folderContent.create);
    } else if (folderState.validateCurrentStep()) {
      folderState.nextStep();
    }
  }

  void _saveToDatabase(BuildContext context, FolderInfo folderInfo,
      List<Metadata> tags, List<FolderItem> folderData) async {
    final database = Provider.of<AppDatabase>(context, listen: false);
    database.createFolderExtended(
        folderInfo: folderInfo, tags: tags, items: folderData);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Folder saved successfully")),
      );
    }
  }

  List<Step> _buildSteps(CreateFolderState folderState) {
    return [
      Step(
        title: const Text("Folder"),
        content:
            FolderInfoStep(formKey: folderState.formKeys[FolderStep.info]!),
      ),
      Step(
        title: const Text("Data"),
        content: FolderData(
          dataKey: folderState.formKeys[FolderStep.data]!,
          folderType: folderState.selectedFolderType,
        ),
      ),
      Step(
        title: const Text("Preview"),
        content: FolderPreview(
            previewKey: folderState.formKeys[FolderStep.preview]!),
      ),
    ];
  }
}

class StepperControls extends StatelessWidget {
  final ControlsDetails details;
  final CreateFolderState folderState;

  const StepperControls({
    super.key,
    required this.details,
    required this.folderState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastStep = folderState.currentStep == FolderStep.preview;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          if (folderState.currentStep.index > 0)
            ElevatedButton.icon(
              onPressed: details.onStepCancel,
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary,
                backgroundColor: theme.colorScheme.primary,
              ),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Previous"),
            ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: details.onStepContinue,
            style: ElevatedButton.styleFrom(
              foregroundColor: theme.colorScheme.onPrimary,
              backgroundColor: isLastStep
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
            ),
            icon: Icon(isLastStep ? Icons.save : Icons.arrow_forward),
            label: Text(isLastStep ? "Save" : "Next"),
          ),
        ],
      ),
    );
  }
}
