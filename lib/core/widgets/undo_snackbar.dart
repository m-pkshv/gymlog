import 'dart:async';

import 'package:flutter/material.dart';

import '../constants.dart';

/// Shows an "X deleted / Undo" snackbar (DM 10's soft-delete pattern) with
/// an explicit [Timer] driving the auto-dismiss, instead of relying on
/// [SnackBar.duration] alone.
///
/// [SnackBar]'s own auto-dismiss timer is only scheduled once its entrance
/// animation reaches [AnimationStatus.completed] (see
/// `ScaffoldMessengerState.build()` in the Flutter SDK) -- which depends on
/// that animation's [Ticker] actually progressing. Owner-reported (Stage 10
/// redesign, on-device check): while the app sits idle (no touch input for
/// a while), that Ticker can stall, so the countdown never even starts and
/// the snackbar never goes away -- reproduced both on-device and in a bare
/// widget test (a single large `tester.pump(Duration(seconds: 6))` never
/// dismisses it, while many small pumps do; the real device's equivalent of
/// "one big pump" is a period with no frames).
///
/// A plain [Timer] isn't tied to the rendering pipeline the same way and
/// fires reliably regardless, then [ScaffoldFeatureController.close] tears
/// down exactly *this* snackbar. Tapping "Undo" cancels the [Timer] first --
/// `SnackBarAction` already removes the snackbar itself as part of handling
/// the tap, and calling `close()` a second time on an already-removed one
/// throws (its internal `assert(_snackBars.first == controller)` evaluates
/// `_snackBars.first` on a queue that's since gone empty, even outside
/// debug mode's `assert` gate).
void showUndoSnackbar(
  BuildContext context, {
  required String message,
  required String actionLabel,
  required VoidCallback onUndo,
}) {
  late final Timer timer;
  final controller = ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: undoSnackbarDuration,
      action: SnackBarAction(
        label: actionLabel,
        onPressed: () {
          timer.cancel();
          onUndo();
        },
      ),
    ),
  );
  timer = Timer(undoSnackbarDuration, controller.close);
}
