import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder_ext.dart';
import 'package:chenron/database/types/data_types.dart';
import 'package:chenron/folder/create/steps/folder_data.dart';
import 'package:chenron/folder/create/steps/folder_info.dart';
import 'package:chenron/folder/create/steps/folder_preview.dart';
import 'package:chenron/providers/folder_content_state.dart';
import 'package:chenron/responsible_design/breakpoints.dart';
import 'package:chenron/providers/create_state.dart';
import 'package:chenron/providers/CUD_state.dart';
import 'package:chenron/providers/folder_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                  _buildStepperControls(context, details, folderState),
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
      final folderInfo = Provider.of<FolderProvider>(context, listen: false);

      final folderContent =
          Provider.of<FolderContentProvider>(context, listen: false);
      final links = folderContent.linkProvider.create;
      final documents = folderContent.documentProvider.create;
      final folders = folderContent.folderProvider.create;
      _saveToDatabase(
          context,
          FolderDataType(
              title: folderInfo.title, description: folderInfo.description),
          links);
    } else if (folderState.validateCurrentStep()) {
      folderState.nextStep();
    }
  }

  void _saveToDatabase(BuildContext context, FolderDataType folderInfo,
      List<BaseDataType> folderData) {
    final database = Provider.of<AppDatabase>(context, listen: false);
    print(" $folderInfo, $folderData");
    //final database = Provider.of<AppDatabase>(context, listen: false);
    // Perform your database operations here
    // For example:
    // database.insertFolder(folderState.folderData);
    database.addFolder(folderData: folderInfo, items: folderData);

    // After saving, you might want to navigate away or show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Folder saved successfully')),
    );
  }

  Widget _buildStepperControls(BuildContext context, ControlsDetails details,
      CreateFolderState folderState) {
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
              label: const Text('Previous'),
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
            label: Text(isLastStep ? 'Save' : 'Next'),
          ),
        ],
      ),
    );
  }

  List<Step> _buildSteps(CreateFolderState folderState) {
    return [
      Step(
        title: const Text("Folder"),
        content: FolderInfo(formKey: folderState.formKeys[FolderStep.info]!),
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
