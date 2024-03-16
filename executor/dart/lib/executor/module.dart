import 'dart:async';
import 'dart:ffi';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';
import 'package:memory/memory/constants.dart';

import '../executor.dart';
import 'constants.dart';

class ExecutorModuleState implements ModuleState {
  final List<Executor> _executors = [];
  late final Pointer<executor_scheduler> _scheduler;

  ExecutorModuleState();

  (Pointer<executor_scheduler>, int) register(Executor executor) {
    _executors.add(executor);
    return (_scheduler, executor_next(context().executor().native));
  }
}

class ExecutorModule with Module<executor_module, ExecutorModuleConfiguration, ExecutorModuleState> {
  final id = executorModuleId;
  final name = executorModuleName;
  final dependencies = {coreModuleName, memoryModuleName};
  final ExecutorModuleState state;

  ExecutorModule({ExecutorModuleState? state}) : state = state ?? ExecutorModuleState();

  @override
  Pointer<executor_module> create(ExecutorModuleConfiguration configuration) {
    SystemLibrary.loadByName(executorLibraryName, executorPackageName);
    return using((arena) => executor_module_create(configuration.toNative(arena)));
  }

  @override
  ExecutorModuleConfiguration load(Pointer<executor_module> native) => ExecutorModuleConfiguration.fromNative(native.ref.configuration);

  @override
  FutureOr<void> initialize() {
    state._scheduler = using((Arena arena) => executor_scheduler_initialize(configuration.schedulerConfiguration.toNative(arena)));
    if (state._scheduler == nullptr || !state._scheduler.ref.initialized) {
      final error = state._scheduler.ref.initialization_error.cast<Utf8>().toDartString();
      if (state._scheduler != nullptr) executor_scheduler_destroy(state._scheduler);
      throw ExecutorException(error);
    }
  }

  Future<void> shutdown() async {
    await Future.wait(state._executors.map((executor) => executor.shutdown()));
    if (!executor_scheduler_shutdown(state._scheduler)) {
      final error = state._scheduler.ref.shutdown_error.cast<Utf8>().toDartString();
      executor_scheduler_destroy(state._scheduler);
      throw ExecutorException(error);
    }
    executor_scheduler_destroy(state._scheduler);
  }

  @override
  FutureOr<void> fork() {
    state._scheduler = native.ref.scheduler;
  }

  @override
  void destroy() {
    executor_module_destroy(native);
  }
}

extension ContextProviderExecutorExtensions on ContextProvider {
  ModuleProvider<executor_module, ExecutorModuleConfiguration, ExecutorModuleState> executor() => get(executorModuleId);
}
