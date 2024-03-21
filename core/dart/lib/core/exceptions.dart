import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'constants.dart';
import 'event.dart';
import 'context.dart' as context;

class ModuleException implements Exception {
  final Event event;
  final StackTrace _dartStackTrace = StackTrace.current;
  Pointer<Utf8> _nativeStackTrace = stacktrace_to_string(0);

  ModuleException(this.event);

  ModuleException.local() : event = context.context().lastNativeEvent;

  @override
  String toString() {
    final formatted = event.format();
    final result = "$formatted${newLine}${_dartStackTrace.toString()}${newLine}${_nativeStackTrace.toDartString()}";
    return result;
  }
}