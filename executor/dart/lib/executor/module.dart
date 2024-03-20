import 'dart:async';
import 'dart:ffi';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';
import 'package:memory/memory/constants.dart';

import '../executor.dart';
import 'bindings.dart';
import 'broker.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'exception.dart';
import 'executor.dart';

class ExecutorModuleState implements ModuleState {
  final List<ExecutorBroker> _brokers = [];
  final List<Executor> _customs = [];

  late final Pointer<executor_module> _module;

  void create(Pointer<executor_module> module) => _module = module;

  Future<void> destroy() async {
    await Future.wait(_brokers.map((broker) => broker.shutdown()));
    await Future.wait(_customs.map((executor) => executor.shutdown()));
  }

  Executor executor({ExecutorConfiguration configuration = ExecutorDefaults.executor}) {
    final executor = Executor(using((arena) => executor_create(configuration.toNative(arena), _module.ref.scheduler, executor_next_id(_module))).check());
    _customs.add(executor);
    return executor;
  }

  ExecutorBroker broker({ExecutorConfiguration configuration = ExecutorDefaults.executor}) {
    final executor = using((arena) => executor_create(configuration.toNative(arena), _module.ref.scheduler, executor_next_id(_module))).check();
    final broker = ExecutorBroker(Executor(executor, configuration: configuration));
    _brokers.add(broker);
    return broker;
  }
}

class ExecutorModule with Module<executor_module, ExecutorModuleConfiguration, ExecutorModuleState> {
  final name = executorModuleName;
  final dependencies = {coreModuleName, memoryModuleName};
  final state = ExecutorModuleState();
  final loader = NativeCallable<ModuleLoader<executor_module>>.listener(_load);
  static void _load(Pointer<executor_module> native) => ExecutorModule().load(ExecutorModuleConfiguration.fromNative(native.ref.configuration));

  @override
  Pointer<executor_module> create(ExecutorModuleConfiguration configuration) {
    SystemLibrary.loadByName(executorLibraryName, executorPackageName);
    return using((arena) => executor_module_create(configuration.toNative(arena)));
  }

  @override
  FutureOr<void> initialize() {
    final scheduler = using((Arena arena) => executor_scheduler_initialize(configuration.schedulerConfiguration.toNative(arena)));
    if (scheduler == nullptr || !scheduler.ref.initialized) {
      final error = scheduler.ref.initialization_error.cast<Utf8>().toDartString();
      if (scheduler != nullptr) executor_scheduler_destroy(scheduler);
      throw ExecutorException(error);
    }
    native.ref.scheduler = scheduler;
    state.create(native);
  }

  @override
  FutureOr<void> fork() {
    state.create(native);
  }

  @override
  FutureOr<void> unfork() async {
    await state.destroy();
  }

  @override
  Future<void> shutdown() async {
    await state.destroy();
    final scheduler = native.ref.scheduler;
    if (!executor_scheduler_shutdown(scheduler)) {
      final error = scheduler.ref.shutdown_error.cast<Utf8>().toDartString();
      executor_scheduler_destroy(scheduler);
      throw ExecutorException(error);
    }
    executor_scheduler_destroy(scheduler);
  }

  @override
  void destroy() {
    executor_module_destroy(native);
  }
}

extension ContextProviderExecutorExtensions on ContextProvider {
  ModuleProvider<executor_module, ExecutorModuleConfiguration, ExecutorModuleState> executorModule() => get(executorModuleName);
  Executor executor({ExecutorConfiguration configuration = ExecutorDefaults.executor}) => executorModule().state.executor(configuration: configuration);
  ExecutorBroker broker({ExecutorConfiguration configuration = ExecutorDefaults.executor}) => executorModule().state.broker(configuration: configuration);
}
