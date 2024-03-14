import 'dart:ffi';

import 'constants.dart';

class CoreException implements Exception {
  final String message;

  const CoreException(this.message);

  @override
  String toString() => "[$coreModuleName] $message";
}

class SystemException implements Exception {
  final int code;
  final String message;

  SystemException(this.code) : message = SystemErrors.of(code).message;

  @inline
  static Pointer<T> checkPointer<T extends NativeType>(Pointer<T> result, [void Function()? finalizer]) {
    if (result == nullptr) {
      finalizer?.call();
      throw SystemException(SystemErrors.ENOMEM.code);
    }
    return result;
  }

  @inline
  static int checkResult(int result, [void Function()? finalizer]) {
    if (result < 0) {
      finalizer?.call();
      throw SystemException(-result);
    }
    return result;
  }

  @override
  String toString() => "[$printSystemExceptionTag] ($code) $dash $message";
}

extension SystemExceptionPointerExtensions<T extends NativeType> on Pointer<T> {
  Pointer<T> check([void Function()? finalizer]) => SystemException.checkPointer(this, finalizer);
}

extension SystemExceptionIntExtensions on int {
  int check([void Function()? finalizer]) => SystemException.checkResult(this, finalizer);
}
