import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:stack_trace/stack_trace.dart';

import 'bindings.dart';
import 'constants.dart';
import 'errors.dart';
import 'exceptions.dart';
import 'extensions.dart';

class EventField {
  final dynamic value;
  final String name;
  final EventFieldType type;

  EventField._(this.value, this.name, this.type);

  EventField.string(this.name, this.value) : type = EventFieldType.string;
  EventField.integer(this.name, this.value) : type = EventFieldType.integer;
  EventField.boolean(this.name, this.value) : type = EventFieldType.boolean;
  EventField.double(this.name, this.value) : type = EventFieldType.double;
  EventField.object(this.name, this.value) : type = EventFieldType.object;
}

class Event {
  final isolate = Isolate.current;
  final Map<String, EventField> fields;
  final DateTime timestamp = DateTime.now();

  final String module;
  final EventSource source;
  final int level;
  final String location;
  final String caller;

  late final Pointer<event> native;

  Event.panic(List<EventField> fields)
      : level = eventLevelPanic,
        module = Frame.caller().package ?? unknown,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        source = EventSource.dart,
        fields = fields.groupBy((field) => field.name);

  Event.error(List<EventField> fields)
      : level = eventLevelError,
        module = Frame.caller().package ?? unknown,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        source = EventSource.dart,
        fields = fields.groupBy((field) => field.name);

  Event.warning(List<EventField> fields)
      : level = eventLevelWarning,
        module = Frame.caller().package ?? unknown,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        source = EventSource.dart,
        fields = fields.groupBy((field) => field.name);

  Event.information(List<EventField> fields)
      : level = eventLevelInformation,
        module = Frame.caller().package ?? unknown,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        source = EventSource.dart,
        fields = fields.groupBy((field) => field.name);

  Event.trace(List<EventField> fields)
      : level = eventLevelTrace,
        module = Frame.caller().package ?? unknown,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        source = EventSource.dart,
        fields = fields.groupBy((field) => field.name);

  Event.native(this.native)
      : fields = {},
        source = EventSource.native,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        level = event_get_level(native),
        module = event_get_module(native).toDartString();

  Event.system(SystemError error, [List<EventField>? fields])
      : fields = {
          eventFieldCode: EventField.integer(eventFieldCode, error.code),
          eventFieldMessage: EventField.string(eventFieldMessage, error.message),
          ...(fields ?? []).groupBy((field) => field.name)
        },
        module = Frame.caller().package ?? unknown,
        source = EventSource.dart,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        level = eventLevelError;

  void raise() => throw ModuleException(this);

  bool has(String name) {
    if (source == EventSource.native) return using((arena) => event_has_field(native, name.toNativeUtf8(allocator: arena)));
    return fields.containsKey(name);
  }

  double getDouble(String name) {
    if (source == EventSource.native) return using((arena) => event_get_double(native, name.toNativeUtf8(allocator: arena)));
    final field = fields[name];
    if (field == null) throw CoreError("Event field $name is not found");
    if (field.type != EventFieldType.double) throw CoreError("Event field $name is not double");
    return field.value;
  }

  bool getBoolean(String name) {
    if (source == EventSource.native) return using((arena) => event_get_boolean(native, name.toNativeUtf8(allocator: arena)));
    final field = fields[name];
    if (field == null) throw CoreError("Event field $name is not found");
    if (field.type != EventFieldType.boolean) throw CoreError("Event field $name is not boolean");
    return field.value;
  }

  int getInteger(String name) {
    if (source == EventSource.native) {
      return using((arena) => event_field_is_signed(native, name.toNativeUtf8(allocator: arena))
          ? event_get_signed(native, name.toNativeUtf8(allocator: arena))
          : event_field_is_unsigned(native, name.toNativeUtf8(allocator: arena))
              ? event_get_signed(native, name.toNativeUtf8(allocator: arena))
              : throw CoreError("Event field $name is not found"));
    }
    final field = fields[name];
    if (field == null) throw CoreError("Event field $name is not found");
    if (field.type != EventFieldType.integer) throw CoreError("Event field $name is not integer");
    return field.value;
  }

  String getString(String name) {
    if (source == EventSource.native) return using((arena) => event_get_string(native, name.toNativeUtf8(allocator: arena)).toDartString());
    final field = fields[name];
    if (field == null) throw CoreError("Event field $name is not found");
    if (field.type != EventFieldType.string) throw CoreError("Event field $name is not string");
    return field.value;
  }

  Object getObject(String name) {
    if (source == EventSource.native) throw CoreError("Native events can't have object field");
    final field = fields[name];
    if (field == null) throw CoreError("Event field $name is not found");
    if (field.type != EventFieldType.object) throw CoreError("Event field $name is not object");
    return field.value;
  }

  void setInteger(String name, int value) {
    if (source == EventSource.native) {
      if (value < 0) {
        using((arena) => event_set_signed(native, name.toNativeUtf8(allocator: arena), value));
        return;
      }
      using((arena) => event_set_unsigned(native, name.toNativeUtf8(allocator: arena), value));
      return;
    }
    fields[name] = EventField.integer(name, value);
  }

  void setDouble(String name, double value) {
    if (source == EventSource.native) {
      using((arena) => event_set_double(native, name.toNativeUtf8(allocator: arena), value));
      return;
    }
    fields[name] = EventField.double(name, value);
  }

  void setBoolean(String name, bool value) {
    if (source == EventSource.native) {
      using((arena) => event_set_boolean(native, name.toNativeUtf8(allocator: arena), value));
      return;
    }
    fields[name] = EventField.boolean(name, value);
  }

  void setString(String name, String value) {
    if (source == EventSource.native) {
      using((arena) => event_set_string(native, name.toNativeUtf8(allocator: arena), value.toNativeUtf8(allocator: arena)));
      return;
    }
    fields[name] = EventField.string(name, value);
  }

  void setObject(String name, dynamic value) {
    if (source == EventSource.native) throw CoreError("Native events can't have object field");
    fields[name] = EventField.object(name, value);
  }

  String format() {
    if (source == EventSource.native) {
      final formatted = event_format(native).toDartString();
      return "$formatted${newLine}isolate = ${isolate.debugName}";
    }
    final formatted = StringBuffer();
    formatted.writeln("[$timestamp] ${eventLevelFormat(level)}: $caller(...) $location");
    formatted.writeln("module = $module");
    formatted.writeln("isolate = ${isolate.debugName}");
    fields.values.forEach((field) => formatted.writeln("${field.name} = ${field.value}"));
    return formatted.toString();
  }
}
