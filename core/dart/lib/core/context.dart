import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'constants.dart';
import 'exceptions.dart';
import 'library.dart';
import 'printer.dart';

final _context = _Context._();
ContextProvider context() => _context;

typedef ModuleLoader<ModuleNative extends NativeType> = Void Function(Pointer<ModuleNative> native);

mixin ModuleProvider<ModuleNative extends NativeType, ConfigurationType extends ModuleConfiguration, StateType extends ModuleState> {
  String get name;
  ConfigurationType get configuration;
  StateType get state;
  Pointer<ModuleNative> get native;
}

mixin ModuleState {}
mixin ModuleConfiguration {}

mixin Module<ModuleNative extends NativeType, ConfigurationType extends ModuleConfiguration, StateType extends ModuleState> implements ModuleProvider<ModuleNative, ConfigurationType, StateType> {
  Set<String> get dependencies => {};

  late final Pointer<ModuleNative> native;
  late final ConfigurationType configuration;

  Pointer<ModuleNative> create(ConfigurationType configuration);

  FutureOr<void> initialize() {}

  FutureOr<void> shutdown() {}

  FutureOr<void> fork() {}

  FutureOr<void> unfork() {}

  bool validate() => true;

  void destroy() {}

  void unload() {}

  void _spawn(ConfigurationType configuration) {
    this.native = create(configuration);
    this.configuration = configuration;
  }

  void restore(int address, ConfigurationType Function(Pointer<ModuleNative>) configuration) {
    this.native = Pointer.fromAddress(address);
    this.configuration = configuration(native);
    _context._load(this);
  }
}

mixin ContextProvider {
  dynamic get(String id);
  bool has(String id);
}

class _Context implements ContextProvider {
  var _modules = <String, Module>{};
  var _native = <String, Pointer<Void>>{};

  late Completer _restoreCompleter;

  _Context._() {
    SystemLibrary.loadCore();
    final context = context_get();
    if (context.ref.initialized) {
      final modules = context.ref.containers;
      for (var i = 0; i < context.ref.size; i++) _native[modules[i].name.toDartString()] = modules[i].module;
      return;
    }
    context_create();
  }

  void _clear() {
    _modules.keys.forEach((module) => using((arena) => context_remove_module(module.toNativeUtf8(allocator: arena))));
    _modules = {};
    _native = {};
  }

  void _create(Module module, ModuleConfiguration configuration) {
    if (_native[module.name] != null) throw CoreException(CoreErrors.moduleAlreadyLoaded(module.name));
    final failedDependencies = module.dependencies.where((dependency) => !_modules.containsKey(dependency)).toList();
    if (failedDependencies.isNotEmpty) throw CoreException(CoreErrors.moduleDependenciesNotFound(failedDependencies));
    _modules[module.name] = module.._spawn(configuration);
    using((arena) => context_put_module(module.name.toNativeUtf8(allocator: arena), module.native.cast(), module.runtimeType.toString().toNativeUtf8()));
    _native[module.name] = module.native.cast();
  }

  void _load(Module module) {
    if (_native[module.name] == null) throw CoreException(CoreErrors.moduleNotLoaded(module.name));
    _modules[module.name] = module;
    if (_modules.length == _native.length) _restoreCompleter.complete();
  }

  Future<void> _restore() async {
    _restoreCompleter = Completer();
    context_load_modules();
    await _restoreCompleter.future;
  }

  @override
  bool has(String id) => _modules[id] != null;

  @override
  Module get(String id) {
    final module = _modules[id];
    if (module == null) throw CoreException(CoreErrors.moduleNotFound(id));
    return module;
  }
}

Future<void> launch(List<(Module, ModuleConfiguration)> modules, FutureOr<void> Function() main) async {
  for (var (module, configuration) in modules) _context._create(module, configuration);
  for (var module in _context._modules.values) module.validate();
  information(CoreMessages.modulesCreated);
  for (var module in _context._modules.values) await Future.value(module.initialize());
  await main();
  for (var module in _context._modules.values.toList().reversed) await Future.value(module.shutdown());
  for (var module in _context._modules.values.toList().reversed) module.destroy();
  information(CoreMessages.modulesDestroyed);
  _context._clear();
}

Future<void> fork(FutureOr<void> Function() main) async {
  await _context._restore();
  information(CoreMessages.modulesLoaded);
  for (var module in _context._modules.values) await Future.value(module.fork());
  await main();
  for (var module in _context._modules.values.toList().reversed) await Future.value(module.unfork());
  for (var module in _context._modules.values.toList().reversed) module.unload();
  information(CoreMessages.modulesUnloaded);
}

RawReceivePort? _killer = null;
SendPort join() {
  if (_killer != null) return _killer!.sendPort;
  _killer = RawReceivePort(() => _killer?.close());
  return _killer!.sendPort;
}
