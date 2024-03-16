class SystemEnvironment {
  SystemEnvironment._();
  
  static var _debug = bool.fromEnvironment("DEBUG");
  static bool get debug => _debug;
  static set debug(bool debug) => _debug = debug;
}
