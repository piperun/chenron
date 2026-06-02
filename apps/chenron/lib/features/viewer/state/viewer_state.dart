import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:signals/signals_flutter.dart";

/// App-lifetime holder for the single [ViewerPresenter].
///
/// The presenter owns a live `watchAllItems()` subscription, a
/// StreamController, a SearchController, and four signals. `Viewer`
/// mounts/unmounts repeatedly but shares this one presenter, so the
/// presenter must outlive any single page (hence a global signal, not
/// per-page state). `init()` is idempotent so repeated mounts reuse the
/// one subscription instead of stacking new ones.
///
/// `onDispose` ties the presenter's teardown to the signal wrapper's
/// lifecycle: when the wrapper is disposed (e.g. at app shutdown, or
/// when `autoDispose` reclaims it after the last `Watch` unsubscribes),
/// the presenter releases its subscription/controllers/signals. Without
/// this the custom `dispose()` would never run and every resource would
/// leak for the process lifetime.
final Signal<ViewerPresenter> viewerViewModelSignal = (() {
  final presenter = ViewerPresenter();
  final s = Signal<ViewerPresenter>(presenter, autoDispose: true);
  s.onDispose(presenter.dispose);
  return s;
})();
