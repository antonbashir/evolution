import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';

import 'bindings.dart';
import 'constants.dart';
import 'event.dart';
import 'local.dart';

const int _oneByteLimit = 0x7f;
const int _twoByteLimit = 0x7ff;
const int _surrogateTagMask = 0xFC00;
const int _surrogateValueMask = 0x3FF;
const int _leadSurrogateMin = 0xD800;

extension NullableExtensions<T> on T? {
  @inline
  R? let<R>(R Function(T) action) {
    if (this != null) return action(this as T);
    return null;
  }

  @inline
  void run<R>(R Function(T) action) {
    if (this != null) action(this as T);
    return null;
  }
}

extension PointerExtensions<T extends NativeType> on Pointer<T> {
  @inline
  Pointer<T> systemCheck([void Function()? finalizer]) {
    if (this == nullptr) {
      finalizer?.call();
      LocalEvent.consume()?.let((event) => event.raise());
      Event.system(SystemErrors.ENOMEM).raise();
    }
    return this;
  }
}

extension IntegerExtensions on int {
  int systemCheck([void Function()? finalizer]) {
    if (this == moduleErrorCode) {
      finalizer?.call();
      LocalEvent.consume()?.let((event) => event.raise());
      Event.error((event) => event.code(moduleErrorCode).message(moduleUnknownErrorMessage)).raise();
    }
    if (SystemErrors.contains(-this)) {
      finalizer?.call();
      Event.system(SystemErrors.of(-this)).raise();
    }
    return this;
  }
}

extension IterableExtension<T> on Iterable<T> {
  @inline
  Map<K, T> groupBy<K>(K Function(T value) keyExtractor) => toMap((value) => value, (value) => keyExtractor(value));

  @inline
  Map<K, V> toMap<K, V>(V Function(T value) valueMapper, K Function(T value) keyExtractor) => Map.fromEntries(map((element) => MapEntry(keyExtractor(element), valueMapper(element))));
}

extension StringExtensions on String {
  @inline
  DateTime? parseUtc() => DateTime.tryParse(this)?.toUtc();

  @inline
  int encode(Uint8List buffer, int offset) {
    final startOffset = offset;
    for (var stringIndex = 0; stringIndex < length; stringIndex++) {
      final codeUnit = codeUnitAt(stringIndex);
      if (codeUnit <= _oneByteLimit) {
        buffer[offset++] = codeUnit;
      } else if ((codeUnit & _surrogateTagMask) == _leadSurrogateMin) {
        final nextCodeUnit = codeUnitAt(++stringIndex);
        final rune = 0x10000 + ((codeUnit & _surrogateValueMask) << 10) | (nextCodeUnit & _surrogateValueMask);
        buffer[offset++] = 0xF0 | (rune >> 18);
        buffer[offset++] = 0x80 | ((rune >> 12) & 0x3f);
        buffer[offset++] = 0x80 | ((rune >> 6) & 0x3f);
        buffer[offset++] = 0x80 | (rune & 0x3f);
      } else if (codeUnit <= _twoByteLimit) {
        buffer[offset++] = 0xC0 | (codeUnit >> 6);
        buffer[offset++] = 0x80 | (codeUnit & 0x3f);
      } else {
        buffer[offset++] = 0xE0 | (codeUnit >> 12);
        buffer[offset++] = 0x80 | ((codeUnit >> 6) & 0x3f);
        buffer[offset++] = 0x80 | (codeUnit & 0x3f);
      }
    }
    return offset - startOffset;
  }

  Directory asDirectory() => Directory(dirname(this));
}

extension StringNullableExtensions on String? {
  @inline
  bool get isEmpty => this == null || this! == "";

  @inline
  bool get isNotEmpty => this != null && this! != "";

  @inline
  R? ifNotEmpty<R>(R Function(String) action) => isNotEmpty ? action(this!) : null;
}

extension IterableNullableExtensions<T> on Iterable<T>? {
  @inline
  bool get isEmpty => this == null || this!.isEmpty;

  @inline
  bool get isNotEmpty => this != null && this!.isNotEmpty;
}

extension SetExtensions<T> on Set<T> {
  @inline
  Set<T> copyRemove(T element) => where((current) => current != element).toSet();

  @inline
  Set<T> copyAdd(T element) => {...this, element};

  @inline
  Set<T> copyUpdate(T? from, T to) {
    remove(from);
    return copyAdd(to);
  }
}

extension ListExtensions<T> on List<T> {
  @inline
  List<T> copyAdd(T element) => [...this, element];

  @inline
  List<T> copyUpdate(T from, T to) => toSet().copyUpdate(from, to).toList();

  @inline
  List<O> mapIndexed<O>(O Function(int index, T element) callback) {
    var index = 0;
    final returnList = <O>[];
    for (var element in this) {
      returnList.add(callback(index++, element));
    }
    return returnList;
  }

  @inline
  List<T> copyRemove(T element) => where((current) => current != element).toList();
}

extension MapExtensions<K, V> on Map<K, V>? {
  @inline
  Map<K, V> copyAdd(K key, V value) => {...this ?? {}, key: value};

  @inline
  Map<K, V> copyUpdate(K key, V value) {
    final currentValue = (this ?? {})[key];
    if (currentValue == null) return this ?? {};
    return copyAdd(key, value);
  }

  @inline
  Map<K, V> copyReplaceKey(K key, K newKey) {
    if (key == newKey) return {...this ?? {}};
    final self = (this ?? {});
    final currentValue = self[key];
    if (currentValue == null) return this ?? {};
    return copyAdd(newKey, currentValue)..remove(key);
  }

  @inline
  Map<K, V> copyReplaceValue(K key, K newKey, V newValue) {
    if (key == newKey) return copyUpdate(key, newValue);
    return copyAdd(newKey, newValue)..remove(key);
  }

  @inline
  Map<K, V> copyModify(K key, V Function(V value) current) {
    final currentValue = (this ?? {})[key];
    if (currentValue == null) return this ?? {};
    return copyAdd(key, current(currentValue));
  }

  @inline
  Map<K, V> copyRemove(K key) => {...this ?? {}}..removeWhere((checkingKey, value) => checkingKey == key);
}

extension FutureExtensions<T> on Future<T> {
  @inline
  Future<T> consumeError(void Function(dynamic error, StackTrace? stack) onError) => catchError((error, stack) {
        onError(error, stack);
        return this;
      });
}

extension SystemIovecExtensions on Pointer<iovec> {
  @inline
  Uint8List collect(int count) {
    final builder = BytesBuilder(copy: false);
    for (var i = 0; i < count; i++) {
      final current = this[i];
      builder.add(current.iov_base.asTypedList(current.iov_len));
    }
    return builder.takeBytes();
  }

  @inline
  int collectTo(Uint8List output, int count) {
    var written = 0;
    for (var i = 0; i < count; i++) {
      final current = this[i];
      output.setRange(written, current.iov_len, current.iov_base.asTypedList(current.iov_len));
      written += output.length;
    }
    return written;
  }
}

extension Uint8StringExtensions on Pointer<Uint8> {
  set string(String value) {
    final buffer = asTypedList(value.length);
    final length = value.encode(buffer, 0);
    buffer[length] = 0;
  }
}
