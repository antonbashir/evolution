import '../core.dart';
import 'configuration.dart';
import 'state.dart';

class CoreDefaults {
  CoreDefaults._();

  static const CoreModuleConfiguration coreConfiguration = CoreModuleConfiguration(
    printLevel: printLevelInformation,
    silent: false,
    component: "unknown",
  );

  static final CoreModuleState coreState = CoreModuleState(
    printer: print,
  );
}
