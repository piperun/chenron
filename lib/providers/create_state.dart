import "package:chenron/folder/create/create_stepper.dart";
import "package:chenron/folder/create/steps/folder_info.dart";
import "package:flutter/material.dart";

class CreateFolderState extends ChangeNotifier {
  FolderStep _currentStep = FolderStep.info;
  FolderType? _selectedFolderType;

  final Map<FolderStep, GlobalKey<FormState>> formKeys = {
    FolderStep.info: GlobalKey<FormState>(),
    FolderStep.data: GlobalKey<FormState>(),
    FolderStep.preview: GlobalKey<FormState>(),
  };

  FolderStep get currentStep => _currentStep;
  FolderType? get selectedFolderType => _selectedFolderType;

  bool validateCurrentStep() {
    return currentStep == FolderStep.preview ||
        formKeys[currentStep]?.currentState?.validate() == true;
  }

  void setCurrentStep(FolderStep step) {
    _currentStep = step;
    notifyListeners();
  }

  void setFolderType(FolderType? type) {
    _selectedFolderType = type;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep != FolderStep.preview) {
      formKeys[_currentStep]!.currentState?.save();
      _currentStep = FolderStep.values[
          (_currentStep.index + 1).clamp(0, FolderStep.values.length - 1)];
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep.index > 0) {
      _currentStep = FolderStep.values[_currentStep.index - 1];
      notifyListeners();
    }
  }
}
