part of 'context.dart';

Completer? _blocker = null;
Future<void> block() async {
  if (_blocker != null) {
    await _blocker!.future;
    _blocker = null;
    return;
  }
  _blocker = Completer();
  await _blocker!.future;
  _blocker = null;
}

void unblock() {
  if (_blocker == null) {
    return;
  }
  if (_blocker!.isCompleted) {
    return;
  }
  _blocker!.complete();
}
