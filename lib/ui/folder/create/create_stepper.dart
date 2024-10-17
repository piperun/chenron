import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/database/extensions/payload.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/folder.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:chenron/ui/folder/create/steps/data_step.dart";
import "package:chenron/ui/folder/create/steps/info_step.dart";
import "package:chenron/ui/folder/create/steps/preview_step.dart";
import "package:chenron/responsible_design/breakpoints.dart";
import "package:chenron/providers/stepper_provider.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

enum FolderType { link, document, folder }

class CreateFolderStepper extends StatefulWidget {
  const CreateFolderStepper({super.key});

  @override
  State<CreateFolderStepper> createState() => _CreateFolderStepperState();
}

class _CreateFolderStepperState extends State<CreateFolderStepper> {
  final folderStep = locator.get<Signal<FolderStepper>>();
  FolderType folderType = FolderType.folder; // Local state for folderType

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stepper(
          type: Breakpoints.isMedium(context)
              ? StepperType.horizontal
              : StepperType.vertical,
          currentStep: folderStep.value.state.index,
          controlsBuilder: (context, details) => StepperControls(
            details: details,
            currentStep: folderStep.value.state,
          ),
          onStepCancel: folderStep.value.previousStep,
          onStepContinue: () {
            _nextStep(context);
          },
          onStepTapped: (index) =>
              folderStep.value.setCurrentStep(FolderStep.values[index]),
          steps: _buildSteps(folderStep.value),
        ),
      ),
    );
  }

  void _nextStep(BuildContext context) {
    if (folderStep.value.state == FolderStep.preview) {
      final folderDraft = locator.get<Signal<FolderDraft>>().value.folder;

      _saveToDatabase(
        context,
        folderDraft.folderInfo,
        folderDraft.tags.toList(),
        folderDraft.items.toList(),
      );
    } else if (folderStep.value.validateCurrentStep()) {
      folderStep.value.nextStep();
    }
  }

  void _saveToDatabase(BuildContext context, FolderInfo folderInfo,
      List<Metadata> tags, List<FolderItem> folderData) async {
    final database = await locator
        .get<FutureSignal<AppDatabaseHandler>>()
        .future
        .then((db) => db.appDatabase);

    database.createFolderExtended(
        folderInfo: folderInfo, tags: tags, items: folderData);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Folder saved successfully")),
      );
    }
  }

  List<Step> _buildSteps(FolderStepper folderState) {
    return [
      Step(
        title: const Text("Folder"),
        content: FolderInfoStep(
          formKey: folderState.formKeys[FolderStep.info]!,
          onFolderTypeChanged: (type) {
            setState(() {
              folderType = type;
            });
          },
        ),
      ),
      Step(
        title: const Text("Data"),
        content: FolderDataStep(
          dataKey: folderState.formKeys[FolderStep.data]!,
          folderType: folderType,
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
  final FolderStep currentStep;

  const StepperControls({
    super.key,
    required this.details,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastStep = currentStep == FolderStep.preview;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          if (currentStep.index > 0)
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
