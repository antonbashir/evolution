import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../core.dart';
import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'environment.dart';
import 'errors.dart';
import 'library.dart';
import 'module.dart';

final _defaultEnvironment = SystemEnvironment();
late final _Context _context;
Completer? _blocker = null;
var _initialized = false;

ContextProvider context() => _context;

SystemEnvironment environment() => _initialized ? _context._environment : _defaultEnvironment;

Future<void> launch(
  List<Module Function()> factories,
  FutureOr<void> Function() main, {
  BootstrapConfiguration configuration = CoreDefaults.bootstrap,
  SystemEnvironment Function(SystemEnvironment current)? environment,
}) async {
  SystemLibrary.loadCore();
  using((arena) => bootstrap(configuration.toNative(arena)));
  _context = _Context._(configuration, environment?.call(_context.environment));
  for (var module in factories) _context._create(module());
  for (var module in _context._modules.values) module.validate();
  for (var module in _context._modules.values) await Future.value(module.initialize());
  await runZonedGuarded(
      main,
      (error, stack) => error is Error
          ? context().coreModule().state.errorHandler(error, stack)
          : error is Exception
              ? context().coreModule().state.exceptionHandler(error, stack)
              : context().coreModule().state.errorHandler(UnimplementedError(error.toString()), stack));
  for (var module in _context._modules.values.toList().reversed) await Future.value(module.shutdown());
  for (var module in _context._modules.values.toList().reversed) module.destroy();
  _context._clear();
}

Future<void> fork(FutureOr<void> Function() main, {SystemEnvironment Function(SystemEnvironment current)? environment}) async {
  _context._restore(environment?.call(_context.environment));
  for (var module in _context._modules.values) await Future.value(module.fork());
  await runZonedGuarded(
      main,
      (error, stack) => error is Error
          ? context().coreModule().state.errorHandler(error, stack)
          : error is Exception
              ? context().coreModule().state.exceptionHandler(error, stack)
              : context().coreModule().state.errorHandler(UnimplementedError(error.toString()), stack));
  for (var module in _context._modules.values.toList().reversed) await Future.value(module.unfork());
  for (var module in _context._modules.values.toList().reversed) module.unload();
}

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

mixin ModuleProvider<Native extends NativeType, Configuration extends ModuleConfiguration, State extends ModuleState> {
  String get name;
  Configuration get configuration;
  State get state;
  Pointer<Native> get native;
}

mixin ModuleState {}

mixin ModuleConfiguration {}

abstract class Module<Native extends NativeType, Configuration extends ModuleConfiguration, State extends ModuleState> implements ModuleProvider<Native, Configuration, State> {
  final Configuration configuration;
  final Pointer<Native> native;
  final SystemLibrary library;

  Set<String> get dependencies => {};
  State get state;

  Module(this.configuration, this.library, this.native);

  Module.load(int address, SystemLibrary Function(Pointer<Native> native) library, Configuration Function(Pointer<Native> native) configurator)
      : native = Pointer.fromAddress(address),
        library = library(Pointer.fromAddress(address)),
        configuration = configurator(Pointer.fromAddress(address)) {
    _context._load(this);
  }

  FutureOr<void> initialize() {}

  FutureOr<void> shutdown() {}

  FutureOr<void> fork() {}

  FutureOr<void> unfork() {}

  void destroy() {}

  void unload() {}

  bool validate() => true;
}

mixin ContextProvider {
  dynamic get(String id);
  bool has(String id);
  SystemEnvironment get environment;
  BootstrapConfiguration get configuration;
}

class _Context implements ContextProvider {
  var _modules = <String, Module>{};
  var _native = <String, Pointer<Void>>{};
  SystemEnvironment _environment;
  BootstrapConfiguration _configuration;
  BootstrapConfiguration get configuration => _configuration;

  _Context._(BootstrapConfiguration configuration, SystemEnvironment? environment)
      : _configuration = configuration,
        _environment = environment ?? _defaultEnvironment {
    final context = context_get();
    if (context.ref.initialized) {
      final modules = context.ref.containers;
      for (var i = 0; i < context.ref.size; i++) _native[modules[i].name.toDartString()] = modules[i].module;
      final nativeEnvironment = context_environment_entries();
      final loadedEnvironment = <String, String>{};
      for (var i = 0; i < nativeEnvironment.ref.size; i++) {
        Pointer<string_value_pair> entry = nativeEnvironment.ref.memory[i].cast();
        loadedEnvironment[entry.ref.key.toDartString()] = entry.ref.value.cast<Utf8>().toDartString();
      }
      _environment = SystemEnvironment.load(loadedEnvironment);
      _configuration = BootstrapConfiguration.fromNative(context.ref.configuration.ref);
      pointer_array_destroy(nativeEnvironment);
      _initialized = true;
      return;
    }
    using((arena) => context_create(configuration.toNative(arena)));
    _environment.entries.forEach((key, value) => using((arena) => context_set_environment(key.toNativeUtf8(allocator: arena), value.toNativeUtf8(allocator: arena))));
    _initialized = true;
  }

  void _clear() {
    _modules.keys.forEach((module) => using((arena) => context_remove_module(module.toNativeUtf8(allocator: arena))));
    _modules = {};
    _native = {};
  }

  void _create(Module module) {
    if (_native[module.name] != null) throw CoreModuleError(CoreErrors.moduleAlreadyLoaded(module.name));
    final failedDependencies = module.dependencies.where((dependency) => !_modules.containsKey(dependency)).toList();
    if (failedDependencies.isNotEmpty) throw CoreModuleError(CoreErrors.moduleDependenciesNotFound(failedDependencies));
    _modules[module.name] = module;
    using((arena) => context_put_module(module.name.toNativeUtf8(allocator: arena), module.native.cast(), module.runtimeType.toString().toNativeUtf8()));
    _native[module.name] = module.native.cast();
  }

  void _load(Module module) {
    if (_native[module.name] == null) throw CoreModuleError(CoreErrors.moduleNotLoaded(module.name));
    _modules[module.name] = module;
  }

  void _restore(SystemEnvironment? environment) {
    _context._environment = environment ?? _context._environment;
    context_load();
  }

  @override
  bool has(String id) => _modules[id] != null;

  @override
  Module get(String id) {
    final module = _modules[id];
    if (module == null) throw CoreModuleError(CoreErrors.moduleNotFound(id));
    return module;
  }

  @override
  SystemEnvironment get environment => _environment;
}
