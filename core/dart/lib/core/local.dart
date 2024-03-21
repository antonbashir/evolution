import 'dart:ffi';

import 'bindings.dart';
import 'constants.dart';
import 'event.dart';

class LocalEvent {
  static Pointer<event> _event = nullptr;

  LocalEvent._();

  static Event? consume() {
    if (_event == nullptr) return null;
    final event = Event.native(_event);
    _event = nullptr;
    return event;
  }

  @entry
  static void _produce(int address) {
    Pointer<event> native = Pointer.fromAddress(address);
    _event = native;
  }
}
