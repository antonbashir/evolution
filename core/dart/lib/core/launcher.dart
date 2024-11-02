part of 'context.dart';

var _launched = false;
var _forked = false;

Future<void> launch(List<Module> Function() factory, FutureOr<void> Function() main, {SystemConfiguration? configuration, SystemEnvironment? environment}) async {
  if (_launched) return;
  _launched = true;
  signals().reload.callback(() async {
    for (var module in _context._modules.values) await module.reload();
  });
  signals().reload.register(ProcessSignal.sighup);
  _system._bootstrap(configurationOverrides: configuration, environmentOverrides: environment);
  _Context._create();
  final modules = factory();
  for (var module in modules) _context._create(module);
  for (var module in _context._modules.values) module.validate();
  for (var module in _context._modules.values) await Future.value(module.initialize());
  final errorHandler = context().coreModule().state.errorHandler;
  final exceptionHandler = context().coreModule().state.exceptionHandler;
  await runZonedGuarded(
      main,
      (error, stack) => error is Error
          ? errorHandler
          : error is Exception
              ? exceptionHandler
              : errorHandler);
  await signals().reload.destroy();
  for (var module in _context._modules.values.toList().reversed) await Future.value(module.shutdown());
  for (var module in _context._modules.values.toList().reversed) module.destroy();
  _context._clear();
  _launched = false;
}

Future<void> fork(FutureOr<void> Function() main, {SystemEnvironment Function(SystemEnvironment current)? environment}) async {
  if (_forked) return;
  _forked = true;
  signals().reload.callback(() async {
    for (var module in _context._modules.values) await module.reload();
  });
  signals().reload.register(ProcessSignal.sighup);
  _system._restore();
  _Context._restore();
  for (var module in _context._modules.values) await Future.value(module.fork());
  await runZonedGuarded(
      main,
      (error, stack) => error is Error
          ? context().coreModule().state.errorHandler(error, stack)
          : error is Exception
              ? context().coreModule().state.exceptionHandler(error, stack)
              : context().coreModule().state.errorHandler(UnimplementedError(error.toString()), stack));
  await signals().reload.destroy();
  for (var module in _context._modules.values.toList().reversed) await Future.value(module.unfork());
  for (var module in _context._modules.values.toList().reversed) module.unload();
  _forked = false;
}
