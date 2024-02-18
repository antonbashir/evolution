import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:math';
import 'package:ffi/ffi.dart';
import 'package:memory/memory.dart';
import 'bindings.dart';
import 'constants.dart';
import 'declaration.dart';
import 'messages.dart';
import 'registry.dart';

class Interactor {
  final _fromInteractors = ReceivePort();

  late final InteractorConsumerRegistry _consumers;
  late final InteractorProducerRegistry _producers;

  late final Pointer<interactor_dart> _pointer;
  late final Pointer<Pointer<interactor_dart_completion_event>> _completions;
  late final RawReceivePort _closer;
  late final SendPort _destroyer;
  late final List<Duration> _delays;

  var _active = false;
  final _done = Completer();

  late final int descriptor;
  late final InteractorMessages messages;
  late final Memory memory;
  bool get active => _active;
  int get id => _pointer.ref.id;

  Interactor(SendPort toInteractor) {
    _closer = RawReceivePort((_) async {
      await deactivate();
      memory.destroy();
      interactor_dart_destroy(_pointer);
      calloc.free(_pointer);
      _closer.close();
      _destroyer.send(null);
    });
    toInteractor.send([_fromInteractors.sendPort, _closer.sendPort]);
  }

  Future<void> initialize() async {
    final configuration = await _fromInteractors.first as List;
    _pointer = Pointer.fromAddress(configuration[0] as int).cast<interactor_dart>();
    _destroyer = configuration[1] as SendPort;
    descriptor = configuration[2] as int;
    _fromInteractors.close();
    _completions = _pointer.ref.completions;
    memory = Memory()..initialize();
    messages = InteractorMessages(memory);
    _consumers = InteractorConsumerRegistry(_pointer);
    _producers = InteractorProducerRegistry(_pointer);
  }

  void activate() {
    _active = true;
    _delays = _calculateDelays();
    unawaited(_listen());
  }

  Future<void> deactivate() async {
    if (_active) {
      _active = false;
      await _done.future;
    }
  }

  void consumer(InteractorConsumer declaration) => _consumers.register(declaration);

  T producer<T extends InteractorProducer>(T provider) => _producers.register(provider);

  Future<void> _listen() async {
    final baseDelay = _pointer.ref.base_delay_micros;
    final regularDelayDuration = Duration(microseconds: baseDelay);
    var attempt = 0;
    while (_active) {
      attempt++;
      if (_handleCqes()) {
        attempt = 0;
        await Future.delayed(regularDelayDuration);
        continue;
      }
      await Future.delayed(_delays[min(attempt, 31)]);
    }
    _done.complete();
  }

  bool _handleCqes() {
    final cqeCount = interactor_dart_peek(_pointer);
    if (cqeCount == 0) return false;
    for (var cqeIndex = 0; cqeIndex < cqeCount; cqeIndex++) {
      Pointer<interactor_completion_event> cqe = (_completions + cqeIndex).value.cast();
      final data = cqe.ref.user_data;
      final result = cqe.ref.res;
      if (data > 0) {
        if (result & interactorDartCall > 0) {
          Pointer<interactor_message> message = Pointer.fromAddress(data);
          _consumers.call(message);
          continue;
        }
        if (result & interactorDartCallback > 0) {
          Pointer<interactor_message> message = Pointer.fromAddress(data);
          _producers.callback(message);
          continue;
        }
        continue;
      }
    }
    interactor_dart_cqe_advance(_pointer, cqeCount);
    return true;
  }

  List<Duration> _calculateDelays() {
    final baseDelay = _pointer.ref.base_delay_micros;
    final delayRandomizationFactor = _pointer.ref.delay_randomization_factor;
    final maxDelay = _pointer.ref.max_delay_micros;
    final random = Random();
    final delays = <Duration>[];
    for (var i = 0; i < 32; i++) {
      final randomization = (delayRandomizationFactor * (random.nextDouble() * 2 - 1) + 1);
      final exponent = min(i, 31);
      final delay = (baseDelay * pow(2.0, exponent) * randomization).toInt();
      delays.add(Duration(microseconds: delay < maxDelay ? delay : maxDelay));
    }
    return delays;
  }
}
