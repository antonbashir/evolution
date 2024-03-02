import 'dart:ffi';

import 'package:mediator/mediator.dart';

class TestNativeConsumer implements MediatorConsumer {
  void Function(Pointer<mediator_message> message) _checker;

  TestNativeConsumer(this._checker);

  void test(Pointer<mediator_message> message) => _checker(message);

  @override
  List<MediatorCallback> callbacks() => [test];
}
