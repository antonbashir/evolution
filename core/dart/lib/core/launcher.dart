part of 'context.dart';

var _launched = false;
var _forked = false;

Future<void> launch(
  List<Module Function()> factories,
  FutureOr<void> Function() main, {
  SystemConfiguration configuration = CoreDefaults.bootstrap,
  SystemEnvironment Function(SystemEnvironment current)? environment,
}) async {
  if (_launched) return;
  _launched = true;
  _system._bootstrap();
  _context = _Context._();
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
  if (_forked) return;
  _forked = true;
  _system._restore();
  _context._restore();
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
