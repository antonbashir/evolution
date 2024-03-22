import 'constants.dart';
import 'event.dart';

class ModuleException implements Exception {
  final Event event;
  final String _message;

  static String _format(Event event) {
    return "${event.format()}${newLine}${"$dartStackPart${newLine}${StackTrace.current}"}${newLine}$nativeStackPart${newLine}${event.fromDart ? newLine : event.has(CoreEventFields.stackTrace) ? event.getString(CoreEventFields.stackTrace) + newLine : newLine}";
  }

  ModuleException(this.event) : _message = _format(event) {
    event.destroy();
  }

  @override
  String toString() => _message;
}
