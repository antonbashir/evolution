import 'extensions.dart';

class SystemEnvironment {
  var _entries = <String, String>{
    "DEBUG": String.fromEnvironment("DEBUG"),
  };

  Map<String, String> get entries => {..._entries};
  bool get debug => _entries["DEBUG"]?.let(bool.parse) ?? false;
  set debug(bool debug) => _entries["DEBUG"] = debug.toString();
}
