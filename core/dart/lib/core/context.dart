import 'dart:async';
import 'dart:ffi';

import '../bindings/context/context.dart';
import '../core.dart';

final _context = _Context._();
ContextProvider context() => _context;

typedef ModuleLoader = ContextLoader Function(ContextLoader loader);
typedef ModuleCreator = ContextCreator Function(ContextCreator preloader);

mixin ModuleProvider<ConfigurationType extends ModuleConfiguration> {
  int get id;
  String get name;
  ConfigurationType get configuration;
}

mixin Module<NativeType extends Struct, ConfigurationType extends ModuleConfiguration> implements ModuleProvider<ConfigurationType> {
  int get id;
  String get name;
  late final Pointer<NativeType> native;
  late final ConfigurationType configuration;

  Pointer<NativeType> create(ConfigurationType configuration);

  ConfigurationType load(Pointer<NativeType> native);

  FutureOr<void> initialize() {}

  FutureOr<void> shutdown() {}

  FutureOr<void> fork() {}

  FutureOr<void> unfork() {}

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

mixin ModuleConfiguration {}

mixin ContextProvider {
  Module get(int id);
  bool has(int id);
}

mixin ContextCreator {
  ContextCreator create(Module module, ModuleConfiguration configuration);
}

mixin ContextLoader {
  ContextLoader load(Module module);
}

class _Context with ContextCreator, ContextLoader, ContextProvider {
  final _modules = List<Module?>.generate(modules_maximum, (index) => null, growable: false);
  final _native = List<Pointer<Void>>.generate(modules_maximum, (index) => nullptr, growable: false);

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

  @override
  bool has(int id) => _modules[id] != null;

  @override
  Module get(int id) => _modules[id]!;

  @override
  ContextCreator create(Module module, ModuleConfiguration configuration) {
    if (_native[module.id] != nullptr) throw Error();
    _modules[module.id] = module.._spawn(configuration);
    context_put_module(module.id, module.native.cast());
    _native[module.id] = module.native.cast();
    return this;
  }

  @override
  ContextLoader load(Module module) {
    if (_native[module.id] == nullptr) throw Error();
    _modules[module.id] = module.._fetch(_native[module.id].cast());
    return this;
  }
}

final _launcher = Launcher._();
final _forker = Forker._();

class Launcher {
  Launcher._();

  Future<void> activate(FutureOr<void> Function() main) async {
    await Future.wait(_context._modules.map((module) => Future.value(module?.initialize())));
    await main();
    await Future.wait(_context._modules.map((module) => Future.value(module?.shutdown())));
    _context._modules.forEach((module) => module?.destroy());
  }
}

class Forker {
  Forker._();

  Future<void> activate(FutureOr<void> Function() main) async {
    await Future.wait(_context._modules.map((module) => Future.value(module?.fork())));
    await main();
    await Future.wait(_context._modules.map((module) => Future.value(module?.unfork())));
    _context._modules.forEach((module) => module?.unload());
  }
}

Launcher launch(ModuleCreator creator) {
  creator(_context);
  return _launcher;
}

Forker fork(ModuleLoader loader) {
  loader(_context);
  return _forker;
}
