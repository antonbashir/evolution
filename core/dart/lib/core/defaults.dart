import '../core.dart';
import 'configuration.dart';
import 'state.dart';

class CoreDefaults {
  CoreDefaults._();

  static const CoreModuleConfiguration coreConfiguration = CoreModuleConfiguration(
    printLevel: printLevelInformation,
    component: "unknown",
  );

  static final CoreModuleState coreState = CoreModuleState(
    errorPrinter: (error, stack) => print("[${DateTime.now()}] (error): ${error.toString()}\nError stack:\n${error.stackTrace}Zoned stack:\n$stack"),
    exceptionPrinter: (exception, stack) => print("[${DateTime.now()}] (error): ${exception.toString()}\n$stack"),
    printer: print,
   );
}
