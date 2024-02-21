import 'dart:ffi';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';

import 'bindings.dart';

extension InteractorMessageExtensions on Pointer<interactor_message> {
  @inline
  int get id => ref.id;

  @inline
  Pointer<Void> get inputPointer => ref.input;

  @inline
  int get inputSize => ref.input_size;

  @inline
  void set inputSize(int size) => ref.input_size = size;

  @inline
  bool get inputBool => ref.input.address == 1;

  @inline
  int get inputInt => ref.input.address;

  @inline
  double get inputDouble => ref.input.cast<Double>().value;

  @inline
  Uint8List get inputBytes => ref.input.cast<Uint8>().asTypedList(ref.input_size);

  @inline
  (Pointer<Uint8>, int) get inputTuple => (ref.input.cast<Uint8>(), ref.input_size);

  @inline
  String getInputString({int? length}) => ref.input.cast<Utf8>().toDartString(length: length);

  @inline
  Pointer<T> getInputObject<T extends NativeType>() => Pointer.fromAddress(ref.input.address).cast();

  @inline
  T parseInputObject<T, O extends Struct>(T Function(Pointer<O> object) mapper) => mapper(getInputObject<O>());

  @inline
  set inputInt(int data) {
    ref.input = Pointer.fromAddress(data);
    ref.input_size = sizeOf<Int>();
  }

  @inline
  set inputBool(bool data) {
    ref.input = Pointer.fromAddress(data ? 1 : 0);
    ref.input_size = sizeOf<Bool>();
  }

  @inline
  void setInputDouble(Pointer<Double> data) {
    ref.input = data.cast();
    ref.input_size = sizeOf<Double>();
  }

  @inline
  void setInputPointer(Pointer pointer, int size) {
    ref.input = pointer.cast();
    ref.input_size = size;
  }

  @inline
  void setInputTuple((Pointer<Uint8>, int) tuple) {
    ref.input = tuple.$1.cast();
    ref.input_size = tuple.$2;
  }

  @inline
  int get outputSize => ref.output_size;

  @inline
  Pointer<Void> get outputPointer => ref.output;

  @inline
  bool get outputBool => ref.output.address == 1;

  @inline
  int get outputInt => ref.output.address;

  @inline
  double get outputDouble => ref.output.cast<Double>().value;

  @inline
  Uint8List get outputBytes => ref.output.cast<Uint8>().asTypedList(ref.output_size);

  @inline
  (Pointer<Uint8>, int) get outputTuple => (ref.output.cast<Uint8>(), ref.output_size);

  @inline
  String getOutputString({int? length}) => ref.output.cast<Utf8>().toDartString(length: length);

  @inline
  Pointer<T> getOutputObject<T extends Struct>() => Pointer.fromAddress(ref.output.address).cast();

  @inline
  T parseOutputObject<T, O extends Struct>(T Function(Pointer<O> object) mapper) => mapper(getOutputObject<O>());
}

final interactorMessageSize = sizeOf<interactor_message>();
