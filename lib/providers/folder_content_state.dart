import 'package:chenron/database/types/data_types.dart';
import 'package:chenron/providers/CUD_state.dart';
import 'package:flutter/material.dart';

class FolderContentProvider extends ChangeNotifier {
  final CUDProvider<DocumentDataType> documentProvider =
      CUDProvider<DocumentDataType>();
  final CUDProvider<FolderDataType> folderProvider =
      CUDProvider<FolderDataType>();
  final CUDProvider<LinkDataType> linkProvider = CUDProvider<LinkDataType>();

  @override
  void notifyListeners() {
    super.notifyListeners();
    documentProvider.notifyListeners();
    folderProvider.notifyListeners();
    linkProvider.notifyListeners();
  }
}
