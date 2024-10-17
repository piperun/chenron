import "package:flutter/material.dart";

enum FolderStep { info, data, preview }

class FolderStepper {
  FolderStep state = FolderStep.info;
  final Map<FolderStep, GlobalKey<FormState>> formKeys = {
    for (var step in FolderStep.values) step: GlobalKey<FormState>(),
  };

  bool validateCurrentStep() {
    return state == FolderStep.preview ||
        formKeys[state]?.currentState?.validate() == true;
  }

  void setCurrentStep(FolderStep step) {
    if (state != step) {
      state = step;
    }
  }

  void nextStep() {
    if (state != FolderStep.preview) {
      formKeys[state]!.currentState?.save();
      final nextIndex =
          (state.index + 1).clamp(0, FolderStep.values.length - 1);
      setCurrentStep(FolderStep.values[nextIndex]);
    }
  }

  void previousStep() {
    if (state.index > 0) {
      setCurrentStep(FolderStep.values[state.index - 1]);
    }
  }
}
