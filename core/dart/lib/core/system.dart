part of 'context.dart';

final _system = System._();
System system() => _system;

class System {
  var _environment = SystemEnvironment();
  var _configuration = CoreDefaults.bootstrap;

  SystemEnvironment get environment => _environment;
  SystemConfiguration get configuration => _configuration;

  System._();

  void _bootstrap({SystemEnvironment? environmentOverrides, SystemConfiguration? configurationOverrides}) {
    _environment = environmentOverrides ?? _environment;
    _configuration = configurationOverrides ?? _configuration;
    SystemLibrary.loadCore();
    using((arena) => bootstrap_system(_configuration.toNative(arena)));
    using((arena) => _environment.entries.forEach(((key, value) => system_set_environment(key.toNativeUtf8(allocator: arena), value.toNativeUtf8(allocator: arena)))));
  }

  void _restore() {
    final nativeEnvironment = system_environment_entries();
    final loadedEnvironment = <String, String>{};
    for (var i = 0; i < nativeEnvironment.ref.size; i++) {
      Pointer<string_value_pair> entry = nativeEnvironment.ref.memory[i].cast();
      loadedEnvironment[entry.ref.key.toDartString()] = entry.ref.value.cast<Utf8>().toDartString();
    }
    _environment = SystemEnvironment.load(loadedEnvironment);
    pointer_array_destroy(nativeEnvironment);
    _configuration = SystemConfiguration.fromNative(bootstrap_configuration_get().ref);
  }
}
