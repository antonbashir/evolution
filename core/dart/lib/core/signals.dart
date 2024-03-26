import 'dart:async';
import 'dart:io';

final _signals = Signals();
Signals signals() => _signals;

class Signals {
  final reload = Signal();
}

class Signal {
  final List<FutureOr<void> Function()> _callbacks = [];
  final List<StreamSubscription<ProcessSignal>> _subscriptions = [];

  void callback(FutureOr<void> Function() listener) {
    _callbacks.add(listener);
  }

  void system(ProcessSignal signal) {
    _subscriptions.add(ProcessSignal.sighup.watch().listen((event) async => await notify()));
  }

  Future<void> notify() async {
    for (var listener in _callbacks) {
      await listener();
    }
  }

  Future<void> destroy() async {
    for (var systemListener in _subscriptions) {
      await systemListener.cancel();
    }
  }
}
