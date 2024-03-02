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

class Mediator {
  final _fromMediators = ReceivePort();
  final wakingStopwatch = Stopwatch();
  final _callback = RawReceivePort(_awakeMediator);

  late final MediatorConsumerRegistry _consumers;
  late final MediatorProducerRegistry _producers;

  late final Pointer<mediator_dart> _pointer;
  late final Pointer<Pointer<mediator_dart_completion_event>> _completions;
  late final RawReceivePort _closer;
  late final SendPort _destroyer;

  late final int descriptor;
  late final MediatorMessages messages;
  late final MemoryModule memory;

  @inline
  int get id => _pointer.ref.id;

  @inline
  bool get active => _pointer.ref.state & mediatorStateStopped == 0;

  Mediator(SendPort toMediator) {
    _closer = RawReceivePort((_) async {
      deactivate();
      _mediators.remove(_pointer.ref.id);
      _callback.close();
      memory.destroy();
      calloc.free(_pointer);
      _closer.close();
      _destroyer.send(null);
    });
    toMediator.send([_fromMediators.sendPort, _closer.sendPort]);
  }

  Future<void> initialize() async {
    final configuration = await _fromMediators.first as List;
    _pointer = Pointer.fromAddress(configuration[0] as int).cast<mediator_dart>();
    _destroyer = configuration[1] as SendPort;
    descriptor = configuration[2] as int;
    _fromMediators.close();
    _completions = _pointer.ref.completions;
    memory = MemoryModule(load: false)..initialize();
    messages = MediatorMessages(memory);
    _consumers = MediatorConsumerRegistry(_pointer);
    _producers = MediatorProducerRegistry(_pointer);
    while (_pointer.ref.id >= _mediators.length) _mediators.add(this);
    _mediators[_pointer.ref.id] = this;
  }

  void activate() {
    if (mediator_dart_register(_pointer, _callback.sendPort.nativePort) == mediatorErrorRingFull) {
      throw MediatorException(MediatorErrors.mediatorRingFullError);
    }
  }

  void deactivate() {
    if (mediator_dart_unregister(_pointer) == mediatorErrorRingFull) {
      throw MediatorException(MediatorErrors.mediatorRingFullError);
    }
  }

  void consumer(MediatorConsumer declaration) => _consumers.register(declaration);

  T producer<T extends MediatorProducer>(T provider) => _producers.register(provider);

  void _awake() {
    if (_pointer.ref.state & mediatorStateStopped == 0) {
      if (mediator_dart_awake(_pointer) == mediatorErrorRingFull) {
        mediator_dart_sleep(_pointer, 0);
        throw MediatorException(MediatorErrors.mediatorRingFullError);
      }
      final cqeCount = mediator_dart_peek(_pointer);
      if (cqeCount == 0) return;
      for (var cqeIndex = 0; cqeIndex < cqeCount; cqeIndex++) {
        Pointer<mediator_completion_event> cqe = (_completions + cqeIndex).value.cast();
        final data = cqe.ref.user_data;
        final result = cqe.ref.res;
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
      mediator_dart_sleep(_pointer, cqeCount);
    }
  }
}
