import 'configuration.dart';
import 'constants.dart';

class CoreDefaults {
  CoreDefaults._();

  static const BootstrapConfiguration bootstrap = BootstrapConfiguration(
    printLevel: EventLevel.information,
    silent: false,
  );

  static const CoreModuleConfiguration module = CoreModuleConfiguration();
}
