import "package:signals/signals.dart";

/// Number of times something has asked the shell to open the Activity Log.
///
/// The shell's root page watches this counter and navigates on each bump,
/// pre-selecting the "failed" status filter — every producer today is a
/// failure toast whose user wants to see what went wrong.
///
/// Lives under `shared/` so widgets far from the shell (snack bar actions,
/// viewer handlers) can request the jump without importing shell state.
final activityLogOpenRequest = signal<int>(0);

/// Ask the shell to open the Activity Log with the failed filter active.
void requestActivityLogOpen() => activityLogOpenRequest.value++;
