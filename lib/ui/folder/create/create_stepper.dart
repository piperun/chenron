import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/database/extensions/payload.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/folder.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:chenron/responsible_design/breakpoints.dart";
import "package:chenron/ui/folder/create/steps/data_step.dart";
import "package:chenron/ui/folder/create/steps/info_step.dart";
import "package:chenron/ui/folder/create/steps/preview_step.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

enum StepperStep { info, data, preview }

class CreateStepper extends StatefulWidget {
  const CreateStepper({super.key});

  @override
  State<CreateStepper> createState() => _CreateStepperState();
}

class _CreateStepperState extends State<CreateStepper> {
  final currentStepSignal = Signal<StepperStep>(StepperStep.info);

  final Map<StepperStep, GlobalKey<FormState>> formKeys = {
    StepperStep.info: GlobalKey<FormState>(),
    StepperStep.data: GlobalKey<FormState>(),
    StepperStep.preview: GlobalKey<FormState>(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signal Stepper"),
      ),
      body: Watch.builder(
        builder: (context) {
          return Stepper(
            type: Breakpoints.isMedium(context)
                ? StepperType.horizontal
                : StepperType.vertical,
            currentStep: currentStepSignal.value.index,
            onStepCancel: _onStepCancel,
            onStepContinue: _onStepContinue,
            onStepTapped: (index) {
              setState(() {
                currentStepSignal.value = StepperStep.values[index];
              });
            },
            steps: _buildSteps(),
          );
        },
      ),
    );
  }

  void _onStepContinue() {
    final currentStep = currentStepSignal.value;
    final formKey = formKeys[currentStep];

    if (formKey != null && formKey.currentState != null) {
      if (!formKey.currentState!.validate()) {
        return;
      }
      formKey.currentState!.save();
    }

    if (currentStep == StepperStep.values.last) {
      // Last step: Save data to the database
      final folderDraft = locator.get<Signal<FolderDraft>>().value.folder;

      _saveToDatabase(
        context,
        folderDraft.folderInfo,
        folderDraft.tags.toList(),
        folderDraft.items.toList(),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Folder saved successfully")),
        );
      }
    } else {
      // Proceed to the next step
      setState(() {
        currentStepSignal.value = StepperStep.values[currentStep.index + 1];
      });
    }
  }

  void _onStepCancel() {
    final currentStep = currentStepSignal.value;
    if (currentStep.index > 0) {
      setState(() {
        currentStepSignal.value = StepperStep.values[currentStep.index - 1];
      });
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text("Step 1"),
        isActive: currentStepSignal.value == StepperStep.info,
        content: InfoStep(
          formKey: formKeys[StepperStep.info]!,
        ),
      ),
      Step(
        title: const Text("Step 2"),
        isActive: currentStepSignal.value == StepperStep.data,
        content: DataStep(
          formKey: formKeys[StepperStep.data]!,
        ),
      ),
      Step(
        title: const Text("Step 3"),
        isActive: currentStepSignal.value == StepperStep.preview,
        content: const PreviewStep(),
      ),
    ];
  }

  void _saveToDatabase(
    BuildContext context,
    FolderInfo folderInfo,
    List<Metadata> tags,
    List<FolderItem> folderData,
  ) async {
    final database = await locator
        .get<Signal<Future<AppDatabaseHandler>>>()
        .value
        .then((db) => db.appDatabase);

    database.createFolderExtended(
        folderInfo: folderInfo, tags: tags, items: folderData);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Folder saved successfully")),
      );
    }
  }
}

// For now it's dormant, but at some point it'll be used
class StepperControls extends StatelessWidget {
  final ControlsDetails details;
  final StepperStep currentStep;

  const StepperControls({
    super.key,
    required this.details,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastStep = currentStep == StepperStep.preview;

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
