import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import 'package:signals/signals_flutter.dart';

final Signal<ViewerPresenter> viewerViewModelSignal =
    Signal(ViewerPresenter(), autoDispose: true);
