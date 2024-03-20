import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'constants.dart';
import 'exceptions.dart';
import 'printer.dart';

final _context = _Context._();
ContextProvider context() => _context;

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

  Set<String> get dependencies => {};
  State get state;

  Module(this.configuration, Pointer<Native> Function() creator) : native = creator();

  Module.load(int address, Configuration Function(Pointer<Native> native) configurator)
      : native = Pointer.fromAddress(address),
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
}

class _Context implements ContextProvider {
  var _modules = <String, Module>{};
  var _native = <String, Pointer<Void>>{};

  _Context._() {
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

  void _create(Module module) {
    if (_native[module.name] != null) throw CoreException(CoreErrors.moduleAlreadyLoaded(module.name));
    final failedDependencies = module.dependencies.where((dependency) => !_modules.containsKey(dependency)).toList();
    if (failedDependencies.isNotEmpty) throw CoreException(CoreErrors.moduleDependenciesNotFound(failedDependencies));
    _modules[module.name] = module;
    using((arena) => context_put_module(module.name.toNativeUtf8(allocator: arena), module.native.cast(), module.runtimeType.toString().toNativeUtf8()));
    _native[module.name] = module.native.cast();
  }

  void _load(Module module) {
    if (_native[module.name] == null) throw CoreException(CoreErrors.moduleNotLoaded(module.name));
    _modules[module.name] = module;
  }

  void _restore() {
    context_load_modules();
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

Future<void> launch(List<Module> modules, FutureOr<void> Function() main) async {
  for (var module in modules) _context._create(module);
  for (var module in _context._modules.values) module.validate();
  information(CoreMessages.modulesCreated(_context._modules.keys));
  for (var module in _context._modules.values) await Future.value(module.initialize());
  await main();
  for (var module in _context._modules.values.toList().reversed) await Future.value(module.shutdown());
  for (var module in _context._modules.values.toList().reversed) module.destroy();
  information(CoreMessages.modulesDestroyed(_context._modules.keys));
  _context._clear();
}

Future<void> fork(FutureOr<void> Function() main) async {
  _context._restore();
  information(CoreMessages.modulesLoaded(_context._modules.keys));
  for (var module in _context._modules.values) await Future.value(module.fork());
  await main();
  for (var module in _context._modules.values.toList().reversed) await Future.value(module.unfork());
  for (var module in _context._modules.values.toList().reversed) module.unload();
  information(CoreMessages.modulesUnloaded(_context._modules.keys));
}

RawReceivePort? _killer = null;
SendPort join() {
  if (_killer != null) return _killer!.sendPort;
  _killer = RawReceivePort(() => _killer?.close());
  return _killer!.sendPort;
}
