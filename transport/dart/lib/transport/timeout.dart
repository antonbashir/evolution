import 'dart:async';
import 'dart:ffi';

import 'bindings.dart';

class TransportTimeoutChecker {
  final Pointer<transport> _workerPointer;
  final Duration _period;

  late final Timer _timer;

  TransportTimeoutChecker(this._workerPointer, this._period);

  void start() => _timer = Timer.periodic(_period, _check);

  void stop() => _timer.cancel();

  void _check(Timer timer) {
    if (timer.isActive) transport_check_event_timeouts(_workerPointer);
  }
}
