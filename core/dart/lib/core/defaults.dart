import '../core.dart';
import 'configuration.dart';

class CoreDefaults {
  CoreDefaults._();

  static const CoreModuleConfiguration core = CoreModuleConfiguration(
    printLevel: printLevelInformation,
    component: "unknown",
  );
}
