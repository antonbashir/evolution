// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../transport/bindings.dart';

final class transport_configuration extends Struct {
  external memory_configuration memory_instance_configuration;
  external executor_configuration executor_instance_configuration;
  @Uint64()
  external int timeout_checker_period_milliseconds;
  @Bool()
  external bool trace;
}
