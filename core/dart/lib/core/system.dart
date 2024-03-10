import 'bindings.dart';
import 'constants.dart';
import 'context.dart';
import 'defaults.dart';
import 'module.dart';
import 'printer.dart';

@inline
void systemShutdownDescriptor(int descriptor) => system_shutdown_descriptor(descriptor);

void main(List<String> args) => launch((creator) => creator.create(CoreModule(), CoreDefaults.coreConfiguration.copyWith(component: "test"))).activate(
      () async {
        print(context().core().configuration.component);
        trace("hello");
        information("hello");
        warning("hello");
        throw Exception("fuck");
      },
    );
