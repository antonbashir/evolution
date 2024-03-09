import '../core.dart';
import 'configuration.dart';

@inline
String systemError(code) => "code = $code, message = ${SystemErrors.of(-code)}";

@inline
void systemShutdownDescriptor(int descriptor) => system_shutdown_descriptor(descriptor);

void main(List<String> args) {
  CoreModule(CoreModuleConfiguration(printLevel: 3));
  
}
