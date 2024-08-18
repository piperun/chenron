import 'package:chenron/folder/create/steps/folder_data.dart';
import 'package:chenron/folder/create/steps/folder_info.dart';
import 'package:chenron/folder/create/steps/folder_preview.dart';
import 'package:chenron/responsible_design/breakpoints.dart';
import 'package:flutter/material.dart';

enum FolderStep { info, data, preview }

class CreateFolderStepper extends StatefulWidget {
  const CreateFolderStepper({super.key});

  @override
  State<CreateFolderStepper> createState() => _CreateFolderStepperState();
}

class _CreateFolderStepperState extends State<CreateFolderStepper> {
  final Map<FolderStep, GlobalKey<FormState>> _formKeys = {
    FolderStep.info: GlobalKey<FormState>(),
    FolderStep.data: GlobalKey<FormState>(),
    FolderStep.preview: GlobalKey<FormState>(),
  };

  FolderStep _currentStep = FolderStep.info;
  FolderType? _selectedFolderType;

  bool _validateCurrentStep() {
    return _currentStep == FolderStep.preview ||
        _formKeys[_currentStep]!.currentState?.validate() == true;
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep != FolderStep.preview) {
        _formKeys[_currentStep]!.currentState?.save();
      }

      setState(() {
        _currentStep = FolderStep.values[
            (_currentStep.index + 1).clamp(0, FolderStep.values.length - 1)];
      });
    }
  }

  void _gotoStep(int index) {
    if (_validateCurrentStep() || index == FolderStep.preview.index) {
      setState(() {
        _currentStep = FolderStep.values[index];
      });
    }
  }

  void _updateFolderType(FolderType? folderType) {
    setState(() {
      _selectedFolderType = folderType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stepper(
          type: Breakpoints.isMedium(context)
              ? StepperType.horizontal
              : StepperType.vertical,
          currentStep: _currentStep.index,
          controlsBuilder: _buildStepperControls,
          onStepCancel: _onStepCancel,
          onStepContinue: _nextStep,
          onStepTapped: _gotoStep,
          steps: _buildSteps(),
        ),
      ),
    );
  }

  Widget _buildStepperControls(BuildContext context, ControlsDetails details) {
    final theme = Theme.of(context);
    final isLastStep = _currentStep == FolderStep.preview;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          if (_currentStep.index > 0)
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

  void _onStepCancel() {
    if (_currentStep.index > 0) {
      setState(() {
        _currentStep = FolderStep.values[_currentStep.index - 1];
      });
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text("Folder"),
        content: FolderInfo(formKey: _formKeys[FolderStep.info]!),
      ),
      Step(
        title: const Text("Data"),
        content: FolderData(
          dataKey: _formKeys[FolderStep.data]!,
          folderType: _selectedFolderType,
        ),
      ),
      Step(
        title: const Text("Preview"),
        content: FolderPreview(previewKey: _formKeys[FolderStep.preview]!),
      ),
    ];
  }
}
