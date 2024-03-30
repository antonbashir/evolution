import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'environment.dart';
import 'errors.dart';
import 'library.dart';
import 'module.dart';
import 'signals.dart';

part 'system.dart';
part 'launcher.dart';
part 'blocking.dart';

late _Context _context;
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

  FutureOr<void> reload() {}

  void destroy() {}

  void unload() {}

  bool validate() => true;
}

mixin ContextProvider {
  dynamic get(String id);
  bool has(String id);
}

class _Context implements ContextProvider {
  var _modules = LinkedHashMap<String, Module>();
  var _native = LinkedHashMap<String, Pointer<Void>>();

  _Context._create() {
    context_create();
    _context = this;
  }

  _Context._restore() {
    final context = context_get();
    final modules = context.ref.containers;
    for (var i = 0; i < context.ref.size; i++) _native[modules[i].name.toDartString()] = modules[i].module;
    _context = this;
    context_load();
  }

  void _clear() {
    _modules.keys.forEach((module) => using((arena) => context_remove_module(module.toNativeUtf8(allocator: arena))));
    _modules.clear();
    _native.clear();
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

  @override
  bool has(String id) => _modules[id] != null;

  @override
  Module get(String id) {
    final module = _modules[id];
    if (module == null) throw CoreModuleError(CoreErrors.moduleNotFound(id));
    return module;
  }
}
