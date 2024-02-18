import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';

class InteractorMessages {
  final Pointer<interactor_dart> _interactor;

  InteractorMessages(this._interactor);

  @inline
  Pointer<interactor_message> allocate() => interactor_dart_allocate_message(_interactor);

  @inline
  void free(Pointer<interactor_message> message) => interactor_dart_free_message(_interactor, message);
}
