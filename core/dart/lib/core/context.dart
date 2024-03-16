import 'dart:async';
import 'dart:ffi';

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
  int get id;
  String get name;
  ConfigurationType get configuration;
  StateType get state;
  Pointer<NativeType> get native;
}

mixin ModuleState {}

mixin ModuleConfiguration {}

mixin Module<NativeType extends Struct, ConfigurationType extends ModuleConfiguration, StateType extends ModuleState> implements ModuleProvider<NativeType, ConfigurationType, StateType> {
  int get id;
  String get name;
  StateType get state;
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
  dynamic get(int id);
  bool has(int id);
}

mixin ContextCreator {
  ContextCreator create(Module module, ModuleConfiguration configuration);
}

mixin ContextLoader {
  ContextLoader load(Module module);
}

class _Context with ContextCreator, ContextLoader, ContextProvider {
  var _modules = List<Module?>.generate(modulesMaximum, (index) => null, growable: false);
  var _native = List<Pointer<Void>>.generate(modulesMaximum, (index) => nullptr, growable: false);

  _Context._() {
    SystemLibrary.loadByName(coreLibraryName, corePackageName);
    final context = context_get();
    if (context.ref.initialized) {
      final modules = context.ref.modules;
      for (var i = 0; i < context.ref.size; i++) {
        _native[i] = modules[i];
      }
      return;
    }
    context_create();
  }

  void _clear() {
    _modules.where((module) => module != null).forEach((module) => context_remove_module(module!.id));
    _modules = List<Module?>.generate(modulesMaximum, (index) => null, growable: false);
    _native = List<Pointer<Void>>.generate(modulesMaximum, (index) => nullptr, growable: false);
  }

  @override
  bool has(int id) => _modules[id] != null;

  @override
  Module get(int id) {
    final module = _modules[id];
    if (module == null) throw CoreException(CoreErrors.moduleNotFound(id));
    return module;
  }

  @override
  ContextCreator create(Module module, ModuleConfiguration configuration) {
    if (_native[module.id] != nullptr) throw CoreException(CoreErrors.moduleAlreadyLoaded(module.id));
    final failedDependencies = module.dependencies.where((dependency) => !_modules.any((existing) => existing?.name == dependency)).toList();
    if (failedDependencies.isNotEmpty) throw CoreException(CoreErrors.moduleDependenciesNotFound(failedDependencies));
    _modules[module.id] = module.._spawn(configuration);
    context_put_module(module.id, module.native.cast());
    _native[module.id] = module.native.cast();
    return this;
  }

  @override
  ContextLoader load(Module module) {
    if (_native[module.id] == nullptr) throw CoreException(CoreErrors.moduleNotLoaded(module.id));
    _modules[module.id] = module.._fetch(_native[module.id].cast());
    return this;
  }
}

final _launcher = Launcher._();
final _forker = Forker._();

class Launcher {
  Launcher._();

  Future<void> activate(FutureOr<void> Function() main) async {
    information(CoreMessages.modulesCreated);
    for (var module in _context._modules) {
      await Future.value(module?.initialize());
    }
    await main();
    for (var module in _context._modules.reversed) {
      await Future.value(module?.shutdown());
    }
    for (var module in _context._modules.reversed) {
      if (module != null) {
        module.destroy();
      }
    }
    information(CoreMessages.modulesDestroyed);
    _context._clear();
  }
}

class Forker {
  Forker._();

  Future<void> activate(FutureOr<void> Function() main) async {
    information(CoreMessages.modulesLoaded);
    for (var module in _context._modules) {
      await Future.value(module?.fork());
    }
    await main();
    for (var module in _context._modules.reversed) {
      await Future.value(module?.unfork());
    }
    for (var module in _context._modules.reversed) {
      module?.unload();
    }
    information(CoreMessages.modulesUnloaded);
  }
}

Launcher launch(ModuleCreator creator) {
  creator(_context);
  for (var module in _context._modules) module?.validate();
  return _launcher;
}

Forker fork(ModuleLoader loader) {
  loader(_context);
  return _forker;
}
