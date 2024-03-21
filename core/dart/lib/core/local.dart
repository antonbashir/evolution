import 'dart:ffi';

import 'bindings.dart';
import 'constants.dart';
import 'event.dart';

final _localEvent = _LocalEvent._();
_LocalEvent localEvent() => _localEvent;

class _LocalEvent {
  Pointer<event> _event = nullptr;

  _LocalEvent._();

  Event? consume() {
    if (_event == nullptr) return null;
    final event = Event.native(_event);
    _event = nullptr;
    return event;
  }

  @entry
  void _produce(int address) {
    Pointer<event> native = Pointer.fromAddress(address);
    _event = native;
  }
}
