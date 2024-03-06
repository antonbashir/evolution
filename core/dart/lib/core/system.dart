import '../bindings/bindings.dart';
import '../core.dart';

@inline
String systemError(code) => "code = $code, message = ${SystemErrors.of(-code)}";

@inline
void systemShutdownDescriptor(int descriptor) => system_shutdown_descriptor(descriptor);
