import 'dart:ffi';

import 'package:executor/executor.dart';

class TestNativeConsumer implements ExecutorConsumer {
  void Function(Pointer<executor_task> message) _checker;

  TestNativeConsumer(this._checker);

  void test(Pointer<executor_task> message) => _checker(message);

  @override
  List<ExecutorCallback> callbacks() => [test];
}
