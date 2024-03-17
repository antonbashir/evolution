import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'exception.dart';

final _executors = List<Executor?>.filled(maximumExecutors, null);

@inline
void _awakeExecutor(int id) => _executors[id]!._awake();

typedef ExecutorProcessor = void Function(Pointer<Pointer<executor_completion_event>> completions, int count);

class Executor {
  final _callback = RawReceivePort(Zone.current.bindUnaryCallbackGuarded(_awakeExecutor));
  final ExecutorConfiguration configuration;

  late final Pointer<executor_instance> native;
  late final int descriptor;

  late int _id = -1;
  late final ExecutorProcessor _processor;
  late final Pointer<Pointer<executor_completion_event>> _completions;
  late final Pointer<executor_scheduler> _scheduler;

  @inline
  int get id => _id;

  @inline
  bool get active => native.ref.state & executorStateStopped == 0;

  Executor(this._scheduler, this._id, {this.configuration = ExecutorDefaults.executor});

  Future<void> initialize(ExecutorProcessor processor) async {
    native = using((arena) => executor_create(configuration.toNative(arena<executor_configuration>()), _scheduler, _id)).check();
    descriptor = native.ref.descriptor;
    _processor = processor;
    _completions = native.ref.completions;
    _executors[_id] = this;
  }

  Future<void> shutdown() async {
    deactivate();
    _executors[_id] = null;
    _callback.close();
    executor_destroy(native);
  }

  void activate() {
    ExecutorException.checkRing(executor_register_on_scheduler(native, _callback.sendPort.nativePort));
  }

  void deactivate() {
    ExecutorException.checkRing(executor_unregister_from_scheduler(native));
  }

  @inline
  void _awake() {
    if (native.ref.state & executorStateStopped == 0) {
      ExecutorException.checkRing(executor_awake_begin(native), () => executor_awake_complete(native, 0));
      final count = executor_peek(native);
      if (count == 0) return;
      _processor(_completions, count);
      executor_awake_complete(native, count);
    }
  }
}
