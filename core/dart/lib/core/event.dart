import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:stack_trace/stack_trace.dart';

import '../core.dart';
import 'bindings.dart';
import 'errors.dart';
import 'printer.dart';

class EventField {
  final dynamic value;
  final String name;
  final EventFieldType type;

  EventField._(this.value, this.name, this.type);
  EventField.string(this.name, String value)
      : type = EventFieldType.string,
        this.value = value;
  EventField.integer(this.name, int value)
      : type = EventFieldType.integer,
        this.value = value;
  EventField.boolean(this.name, bool value)
      : type = EventFieldType.boolean,
        this.value = value;
  EventField.double(this.name, double value)
      : type = EventFieldType.double,
        this.value = value;
  EventField.object(this.name, this.value) : type = EventFieldType.object;
  EventField.message(String value)
      : name = CoreEventFields.message,
        value = value,
        type = EventFieldType.string;
  EventField.code(int value)
      : name = CoreEventFields.code,
        value = value,
        type = EventFieldType.integer;
}

class EventBuilder {
  final _events = <EventField>[];

  EventBuilder string(String name, String value) {
    _events.add(EventField.string(name, value));
    return this;
  }

  EventBuilder integer(String name, int value) {
    _events.add(EventField.integer(name, value));
    return this;
  }

  EventBuilder boolean(String name, bool value) {
    _events.add(EventField.boolean(name, value));
    return this;
  }

  EventBuilder double(String name, dynamic value) {
    _events.add(EventField.double(name, value));
    return this;
  }

  EventBuilder object(String name, dynamic value) {
    _events.add(EventField.object(name, value));
    return this;
  }

  EventBuilder message(String value) => string(CoreEventFields.message, value);

  EventBuilder code(int value) => integer(CoreEventFields.code, value);
}

class Event {
  final isolate = Isolate.current;
  final Map<String, EventField> fields;
  final DateTime timestamp = DateTime.now();

  final String module;
  final EventSource source;
  final EventLevel level;
  final String location;
  final String caller;

  late final Pointer<event> native;

  Event.panic([EventBuilder Function(EventBuilder builder)? builder])
      : level = EventLevel.panic,
        module = Frame.caller().package ?? unknown,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        source = EventSource.dart,
        fields = (builder?.call(EventBuilder()) ?? EventBuilder())._events.groupBy((field) => field.name);

  Event.error([EventBuilder Function(EventBuilder builder)? builder])
      : level = EventLevel.error,
        module = Frame.caller().package ?? unknown,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        source = EventSource.dart,
        fields = (builder?.call(EventBuilder()) ?? EventBuilder())._events.groupBy((field) => field.name);

  Event.warning([EventBuilder Function(EventBuilder builder)? builder])
      : level = EventLevel.warning,
        module = Frame.caller().package ?? unknown,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        source = EventSource.dart,
        fields = (builder?.call(EventBuilder()) ?? EventBuilder())._events.groupBy((field) => field.name);

  Event.information([EventBuilder Function(EventBuilder builder)? builder])
      : level = EventLevel.information,
        module = Frame.caller().package ?? unknown,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        source = EventSource.dart,
        fields = (builder?.call(EventBuilder()) ?? EventBuilder())._events.groupBy((field) => field.name);

  Event.trace([EventBuilder Function(EventBuilder builder)? builder])
      : level = EventLevel.trace,
        module = Frame.caller().package ?? unknown,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        source = EventSource.dart,
        fields = (builder?.call(EventBuilder()) ?? EventBuilder())._events.groupBy((field) => field.name);

  Event.native(this.native)
      : fields = {},
        source = EventSource.native,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        level = EventLevel.ofLevel(event_get_level(native)),
        module = event_get_module(native) == nullptr ? unknown : event_get_module(native).toDartString();

  Event.system(SystemError error, [EventBuilder Function(EventBuilder builder)? builder])
      : fields = {
          CoreEventFields.code: EventField.integer(CoreEventFields.code, error.code),
          CoreEventFields.message: EventField.string(CoreEventFields.message, error.message),
          ...(builder?.call(EventBuilder()) ?? EventBuilder())._events.groupBy((field) => field.name)
        },
        module = Frame.caller().package ?? unknown,
        source = EventSource.dart,
        location = Frame.caller().location,
        caller = Frame.caller().member ?? unknown,
        level = EventLevel.error;

  bool get fromNative => source == EventSource.native;

  bool get fromDart => source == EventSource.dart;

  void raise() => throw ModuleException(this);

  void print() => printEvent(this);

  void destroy() {
    if (fromNative) {
      event_destroy(native);
      return;
    }
    fields.clear();
  }

  bool has(String name) {
    if (source == EventSource.native) return using((arena) => event_has_field(native, name.toNativeUtf8(allocator: arena)));
    return fields.containsKey(name);
  }

  double getDouble(String name) {
    if (source == EventSource.native) return using((arena) => event_get_double(native, name.toNativeUtf8(allocator: arena)));
    final field = fields[name];
    if (field == null) throw CoreModuleError(CoreErrors.eventFieldNotFound(name));
    if (field.type != EventFieldType.double) throw CoreModuleError(CoreErrors.eventFieldNotDouble(name));
    return field.value;
  }

  bool getBoolean(String name) {
    if (source == EventSource.native) return using((arena) => event_get_boolean(native, name.toNativeUtf8(allocator: arena)));
    final field = fields[name];
    if (field == null) throw CoreModuleError(CoreErrors.eventFieldNotFound(name));
    if (field.type != EventFieldType.boolean) throw CoreModuleError(CoreErrors.eventFieldNotBoolean(name));
    return field.value;
  }

  int getInteger(String name) {
    if (source == EventSource.native) {
      return using((arena) => event_field_is_signed(native, name.toNativeUtf8(allocator: arena))
          ? event_get_signed(native, name.toNativeUtf8(allocator: arena))
          : event_field_is_unsigned(native, name.toNativeUtf8(allocator: arena))
              ? event_get_signed(native, name.toNativeUtf8(allocator: arena))
              : throw CoreModuleError(CoreErrors.eventFieldNotFound(name)));
    }
    final field = fields[name];
    if (field == null) throw CoreModuleError(CoreErrors.eventFieldNotFound(name));
    if (field.type != EventFieldType.integer) throw CoreModuleError(CoreErrors.eventFieldNotInteger(name));
    return field.value;
  }

  String getString(String name) {
    if (source == EventSource.native) return using((arena) => event_get_string(native, name.toNativeUtf8(allocator: arena)).toDartString());
    final field = fields[name];
    if (field == null) throw CoreModuleError(CoreErrors.eventFieldNotFound(name));
    if (field.type != EventFieldType.string) throw CoreModuleError(CoreErrors.eventFieldNotString(name));
    return field.value;
  }

  Object getObject(String name) {
    if (source == EventSource.native) throw CoreModuleError(CoreErrors.eventNativeFieldsObjectType);
    final field = fields[name];
    if (field == null) throw CoreModuleError(CoreErrors.eventFieldNotFound(name));
    if (field.type != EventFieldType.object) throw CoreModuleError(CoreErrors.eventFieldNotObject(name));
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
    if (source == EventSource.native) throw CoreModuleError(CoreErrors.eventNativeFieldsObjectType);
    fields[name] = EventField.object(name, value);
  }

  String format() {
    if (source == EventSource.native) {
      final formatted = StringBuffer(event_format(native).toDartString());
      formatted.writeln(CoreFormatters.formatNativeEventDartFields(isolate.debugName ?? empty, location, caller));
      return formatted.toString();
    }
    final formatted = StringBuffer();
    formatted.writeln("[$timestamp] ${level.label}: $caller(...) $location");
    formatted.writeln(CoreFormatters.formatEventField(CoreEventFields.module, module));
    formatted.writeln(CoreFormatters.formatEventField(CoreEventFields.isolate, isolate.debugName ?? empty));
    fields.values.forEach((field) => formatted.writeln(CoreFormatters.formatEventField(field.name, field.value)));
    return formatted.toString();
  }
}
