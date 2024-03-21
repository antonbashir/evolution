import 'bindings.dart';
import 'constants.dart';
import 'event.dart';

class ModuleException implements Exception {
  final Event event;
  final String _message;

  ModuleException(this.event)
      : _message =
            "${event.format()}${newLine}${"$dartStackPart${newLine}${StackTrace.current}"}${newLine}$nativeStackPart${newLine}${event.fromDart ? newLine : event.has(eventFieldStackTrace) ? event.getString(eventFieldStackTrace) + newLine : newLine}" {
    if (event.fromNative) event_destroy(event.native);
  }

  @override
  String toString() => _message;
}
