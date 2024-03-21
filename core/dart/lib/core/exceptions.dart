import 'bindings.dart';
import 'constants.dart';
import 'event.dart';

class ModuleException implements Exception {
  final Event event;
  final String _dartStackTrace;
  final String _nativeStackTrace;

  ModuleException(this.event)
      : _dartStackTrace = "$dartStackPart${newLine}${StackTrace.current}",
        _nativeStackTrace = "$nativeStackPart${newLine}${event.fromDart ? newLine : event.has(eventFieldStackTrace) ? event.getString(eventFieldStackTrace) + newLine : newLine}";

  @override
  String toString() {
    final formatted = event.format();
    final result = "$formatted${newLine}$_dartStackTrace${newLine}$_nativeStackTrace";
    if (event.fromNative) event_destroy(event.native);
    return result;
  }
}
