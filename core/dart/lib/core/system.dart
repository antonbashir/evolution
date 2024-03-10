import 'dart:isolate';

import 'bindings.dart';
import 'constants.dart';
import 'context.dart';
import 'core.dart';
import 'defaults.dart';

@inline
String systemError(code) => "code = $code, message = ${SystemErrors.of(-code)}";

@inline
void systemShutdownDescriptor(int descriptor) => system_shutdown_descriptor(descriptor);

void main(List<String> args) => launch((creator) => creator.create(CoreModule(), CoreDefaults.core.copyWith(component: "test"))).activate(
      () async {
        print(context().core().configuration.component);
        print("hello");
        await Isolate.run(() => fork((loader) => loader.load(CoreModule())).activate(() {
              print("isolate");
              print(context().core().configuration.component);
            }));
      },
    );
