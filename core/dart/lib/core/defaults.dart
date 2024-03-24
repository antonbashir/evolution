import 'configuration.dart';
import 'constants.dart';

class CoreDefaults {
  CoreDefaults._();

  static const SystemConfiguration bootstrap = SystemConfiguration(
    printLevel: EventLevel.information,
    silent: false,
  );

  static const CoreModuleConfiguration module = CoreModuleConfiguration();
}
