import 'context.dart';

typedef Printer = void Function(String message);

class CoreModuleState implements ModuleState {
  final Printer printer;

  CoreModuleState({
    required this.printer,
  });
}
