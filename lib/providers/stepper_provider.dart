import "package:flutter/material.dart";

enum FolderType { link, document, folder }

enum FolderStep { info, data, preview }

class StepperProvider extends ChangeNotifier {
  FolderStep _currentStep = FolderStep.info;
  FolderType? _selectedFolderType;

  final Map<FolderStep, GlobalKey<FormState>> formKeys = {
    for (var step in FolderStep.values) step: GlobalKey<FormState>(),
  };

  FolderStep get currentStep => _currentStep;
  FolderType? get selectedFolderType => _selectedFolderType;

  bool validateCurrentStep() {
    return _currentStep == FolderStep.preview ||
        formKeys[_currentStep]?.currentState?.validate() == true;
  }

  void setCurrentStep(FolderStep step) {
    if (_currentStep != step) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void setFolderType(FolderType? type) {
    if (_selectedFolderType != type) {
      _selectedFolderType = type;
      notifyListeners();
    }
  }

  void nextStep() {
    if (_currentStep != FolderStep.preview) {
      formKeys[_currentStep]!.currentState?.save();
      final nextIndex =
          (_currentStep.index + 1).clamp(0, FolderStep.values.length - 1);
      setCurrentStep(FolderStep.values[nextIndex]);
    }
  }

  void previousStep() {
    if (_currentStep.index > 0) {
      setCurrentStep(FolderStep.values[_currentStep.index - 1]);
    }
  }
}
