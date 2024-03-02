import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'constants.dart';
import 'declaration.dart';
import 'exception.dart';
import 'messages.dart';
import 'registry.dart';

final _mediators = List<Mediator>.empty(growable: true);

@inline
void _awakeMediator(int id) => _mediators[id]._awake();

typedef MediatorProcessor = void Function(Pointer<Pointer<mediator_dart_completion_event>> completions, int count);

class Mediator {
  final _fromModule = ReceivePort();
  final _callback = RawReceivePort(Zone.current.bindUnaryCallbackGuarded(_awakeMediator));

  late final MediatorConsumerRegistry _consumers;
  late final MediatorProducerRegistry _producers;

  late final Pointer<Pointer<mediator_dart_completion_event>> _completions;
  late final RawReceivePort _closer;
  late final SendPort _destroyer;

  late final int descriptor;
  late final MediatorMessages messages;
  late final MemoryModule memory;
  late final Pointer<mediator_dart> pointer;

  late MediatorProcessor _processor = _process;

  @inline
  int get id => pointer.ref.id;

  @inline
  bool get active => pointer.ref.state & mediatorStateStopped == 0;

  Mediator(SendPort toModule) {
    _closer = RawReceivePort(shutdown);
    toModule.send([_fromModule.sendPort, _closer.sendPort]);
  }

  Future<void> initialize({MediatorProcessor? processor}) async {
    _processor = processor ?? _processor;
    final configuration = await _fromModule.first as List;
    pointer = Pointer.fromAddress(configuration[0] as int).cast<mediator_dart>();
    _destroyer = configuration[1] as SendPort;
    descriptor = configuration[2] as int;
    _fromModule.close();
    _completions = pointer.ref.completions;
    memory = MemoryModule(load: false)..initialize();
    messages = MediatorMessages(memory);
    _consumers = MediatorConsumerRegistry(pointer);
    _producers = MediatorProducerRegistry(pointer);
    while (pointer.ref.id >= _mediators.length) _mediators.add(this);
    _mediators[pointer.ref.id] = this;
  }

  Future<void> shutdown() async {
    deactivate();
    _mediators.remove(pointer.ref.id);
    _callback.close();
    memory.destroy();
    calloc.free(pointer);
    _closer.close();
    _destroyer.send(null);
  }

  void activate() {
    if (mediator_dart_register(pointer, _callback.sendPort.nativePort) == mediatorErrorRingFull) {
      throw MediatorException(MediatorErrors.mediatorRingFullError);
    }
  }

  void deactivate() {
    if (mediator_dart_unregister(pointer) == mediatorErrorRingFull) {
      throw MediatorException(MediatorErrors.mediatorRingFullError);
    }
  }

  void consumer(MediatorConsumer declaration) => _consumers.register(declaration);

  T producer<T extends MediatorProducer>(T provider) => _producers.register(provider);

  @inline
  void _awake() {
    if (pointer.ref.state & mediatorStateStopped == 0) {
      if (mediator_dart_awake(pointer) == mediatorErrorRingFull) {
        mediator_dart_sleep(pointer, 0);
        throw MediatorException(MediatorErrors.mediatorRingFullError);
      }
      final count = mediator_dart_peek(pointer);
      if (count == 0) return;
      _processor(_completions, count);
      mediator_dart_sleep(pointer, count);
    }
  }

  @inline
  void _process(Pointer<Pointer<mediator_dart_completion_event>> completions, int count) {
    for (var index = 0; index < count; index++) {
      Pointer<mediator_completion_event> completion = (completions + index).value.cast();
      final data = completion.ref.user_data;
      final result = completion.ref.res;
      if (data > 0) {
        if (result & mediatorDartCall != 0) {
          Pointer<mediator_message> message = Pointer.fromAddress(data);
          _consumers.call(message);
          continue;
        }
        if (result & mediatorDartCallback != 0) {
          Pointer<mediator_message> message = Pointer.fromAddress(data);
          _producers.callback(message);
          continue;
        }
        continue;
      }
    }
  }
}
