import 'constants.dart';
import 'event.dart';

class ModuleException implements Exception {
  final Event event;
  final String _message;

  static String _format(Event event) =>
      "${event.format()}${newLine}${"$dartStackPart${newLine}${StackTrace.current}"}${newLine}$nativeStackPart${newLine}${event.fromDart ? newLine : event.has(eventFieldStackTrace) ? event.getString(eventFieldStackTrace) + newLine : newLine}";

  ModuleException(this.event) : _message = _format(event) {
    event.destroy();
  }

  @override
  String toString() => _message;
}
