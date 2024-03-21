import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';

final _registry = List<Executor?>.filled(maximumExecutors, null);

@inline
void _awakeExecutor(int id) => _registry[id]!._awake();

typedef ExecutorProcessor = void Function(Pointer<Pointer<executor_completion_event>> completions, int count);
typedef ExecutorPending = int Function();

class Executor {
  final _callback = RawReceivePort(Zone.current.bindUnaryCallbackGuarded(_awakeExecutor));
  final ExecutorConfiguration configuration;
  final Pointer<executor_instance> native;
  final int descriptor;
  final int id;
  final Completer<void> _stopper = Completer();

  late final ExecutorProcessor _processor;
  late final ExecutorPending _pending;
  late final Pointer<Pointer<executor_completion_event>> _completions;

  @inline
  bool get active => native.ref.state & (executorStateIdle | executorStateWaking) != 0;

  @inline
  bool get needSubmit => native.ref.state & executorStateIdle != 0;

  Executor(this.native, {this.configuration = ExecutorDefaults.executor})
      : descriptor = native.ref.descriptor,
        id = native.ref.id;

  Future<void> initialize({required ExecutorProcessor processor, required ExecutorPending pending}) async {
    _processor = processor;
    _pending = pending;
    _completions = native.ref.completions;
    _registry[id] = this;
  }

  Future<void> shutdown() async {
    if (native.ref.state & (executorStateStopping | executorStateStopped) != 0) return;
    native.ref.state = executorStateStopping;
    if (_pending() != 0) await _stopper.future;
    _registry[id] = null;
    _callback.close();
    executor_destroy(native);
  }

  void activate() => executor_register_on_scheduler(native, _callback.sendPort.nativePort).systemCheck();

  void deactivate() => executor_unregister_from_scheduler(native, false).systemCheck();

  @inline
  void _awake() {
    if (native.ref.state & executorStateStopped != 0) {
      if (_stopper.isCompleted) return;
      _stopper.complete();
      return;
    }
    if (native.ref.state & executorStatePaused == 0) {
      executor_awake_begin(native).systemCheck();
      final count = executor_peek(native);
      if (count == 0) {
        if (native.ref.state & executorStateStopping != 0 && _pending() == 0) {
          executor_unregister_from_scheduler(native, true).systemCheck();
        }
        return;
      }
      _processor(_completions, count);
      executor_awake_complete(native, count);
      if (native.ref.state & executorStateStopping != 0 && _pending() == 0) {
        executor_unregister_from_scheduler(native, true).systemCheck();
        return;
      }
    }
  }
}
