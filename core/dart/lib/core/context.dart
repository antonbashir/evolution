import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'constants.dart';
import 'exceptions.dart';
import 'library.dart';
import 'printer.dart';

final _context = _Context._();
ContextProvider context() => _context;

typedef ModuleLoader = ContextLoader Function(ContextLoader loader);
typedef ModuleCreator = ContextCreator Function(ContextCreator creator);

mixin ModuleProvider<NativeType extends Struct, ConfigurationType extends ModuleConfiguration, StateType extends ModuleState> {
  String get name;
  ConfigurationType get configuration;
  StateType get state;
  Pointer<NativeType> get native;
}

mixin ModuleState {}
mixin ModuleConfiguration {}

mixin Module<NativeType extends Struct, ConfigurationType extends ModuleConfiguration, StateType extends ModuleState> implements ModuleProvider<NativeType, ConfigurationType, StateType> {
  Set<String> get dependencies => {};

  late final Pointer<NativeType> native;
  late final ConfigurationType configuration;

  Pointer<NativeType> create(ConfigurationType configuration);

  ConfigurationType load(Pointer<NativeType> native);

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

  void _fetch(Pointer<NativeType> native) {
    this.native = native;
    this.configuration = load(native);
  }
}

mixin ContextProvider {
  dynamic get(String id);
  bool has(String id);
}

mixin ContextCreator {
  ContextCreator create(Module module, ModuleConfiguration configuration);
}

mixin ContextLoader {
  ContextLoader load(Module module);
}

class _Context with ContextCreator, ContextLoader, ContextProvider {
  var _modules = <String, Module>{};
  var _native = <String, Pointer<Void>>{};

  _Context._() {
    SystemLibrary.loadCore();
    final context = context_get();
    if (context.ref.initialized) {
      final modules = context.ref.containers;
      for (var i = 0; i < context.ref.size; i++) {
        _native[modules[i].name.toDartString()] = modules[i].module;
      }
      return;
    }
    context_create();
  }

  void _clear() {
    _modules.keys.forEach((module) => using((arena) => context_remove_module(module.toNativeUtf8(allocator: arena))));
    _modules = {};
    _native = {};
  }

  @override
  bool has(String id) => _modules[id] != null;

  @override
  Module get(String id) {
    final module = _modules[id];
    if (module == null) throw CoreException(CoreErrors.moduleNotFound(id));
    return module;
  }

  @override
  ContextCreator create(Module module, ModuleConfiguration configuration) {
    if (_native[module.name] != null) throw CoreException(CoreErrors.moduleAlreadyLoaded(module.name));
    final failedDependencies = module.dependencies.where((dependency) => !_modules.containsKey(dependency)).toList();
    if (failedDependencies.isNotEmpty) throw CoreException(CoreErrors.moduleDependenciesNotFound(failedDependencies));
    _modules[module.name] = module.._spawn(configuration);
    using((arena) => context_put_module(module.name.toNativeUtf8(allocator: arena), module.native.cast()));
    _native[module.name] = module.native.cast();
    return this;
  }

  @override
  ContextLoader load(Module module) {
    if (_native[module.name] == null) throw CoreException(CoreErrors.moduleNotLoaded(module.name));
    _modules[module.name] = module.._fetch(_native[module.name]!.cast());
    return this;
  }
}

final _launcher = Launcher._();
final _forker = Forker._();

class Launcher {
  Launcher._();

  Future<void> activate(FutureOr<void> Function() main) async {
    information(CoreMessages.modulesCreated);
    for (var module in _context._modules.values) {
      await Future.value(module.initialize());
    }
    await main();
    for (var module in _context._modules.values.toList().reversed) {
      await Future.value(module.shutdown());
    }
    for (var module in _context._modules.values.toList().reversed) {
      module.destroy();
    }
    information(CoreMessages.modulesDestroyed);
    _context._clear();
  }
}

class Forker {
  Forker._();

  Future<void> activate(FutureOr<void> Function() main) async {
    information(CoreMessages.modulesLoaded);
    for (var module in _context._modules.values) {
      await Future.value(module.fork());
    }
    await main();
    for (var module in _context._modules.values.toList().reversed) {
      await Future.value(module.unfork());
    }
    for (var module in _context._modules.values.toList().reversed) {
      module.unload();
    }
    information(CoreMessages.modulesUnloaded);
  }
}

Launcher launch(ModuleCreator creator) {
  creator(_context);
  for (var module in _context._modules.values) module.validate();
  return _launcher;
}

Forker fork(ModuleLoader loader) {
  loader(_context);
  return _forker;
}
