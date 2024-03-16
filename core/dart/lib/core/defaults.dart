import 'configuration.dart';
import 'constants.dart';

class CoreDefaults {
  CoreDefaults._();

  static const CoreModuleConfiguration module = CoreModuleConfiguration(
    printLevel: printLevelError,
    silent: false,
  );
}
