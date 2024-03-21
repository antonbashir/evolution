import 'dart:ffi';
import 'dart:typed_data';

import 'bindings.dart';
import 'constants.dart';
import 'event.dart';
import 'local.dart';

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
  Pointer<T> systemCheck() {
    if (this == nullptr) {
      LocalEvent.consume()?.let((event) => event.raise());
      Event.system(SystemErrors.ENOMEM).raise();
    }
    return this;
  }
}

extension IntegerExtensions on int {
  @inline
  int systemCheck() {
    if (this == moduleErrorCode) {
      LocalEvent.consume()?.let((event) => event.raise());
      Event.error((event) => event.code(moduleErrorCode).message(moduleErrorMessage)).raise();
    }
    if (SystemErrors.contains(-this)) {
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
}

extension StringNullableExtensions on String? {
  @inline
  bool get isEmpty => this == null || this! == "";

  @inline
  bool get isNotEmpty => this != null && this! != "";
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
