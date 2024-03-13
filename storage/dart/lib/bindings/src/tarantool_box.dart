// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../storage/bindings.dart';

final class tarantool_box extends Struct {
  @Uint64()
  external int tarantool_evaluate_address;
  @Uint64()
  external int tarantool_call_address;
  @Uint64()
  external int tarantool_iterator_next_single_address;
  @Uint64()
  external int tarantool_iterator_next_many_address;
  @Uint64()
  external int tarantool_iterator_destroy_address;
  @Uint64()
  external int tarantool_free_output_buffer_address;
  @Uint64()
  external int tarantool_space_id_by_name_address;
  @Uint64()
  external int tarantool_space_count_address;
  @Uint64()
  external int tarantool_space_length_address;
  @Uint64()
  external int tarantool_space_iterator_address;
  @Uint64()
  external int tarantool_space_insert_single_address;
  @Uint64()
  external int tarantool_space_insert_many_address;
  @Uint64()
  external int tarantool_space_put_single_address;
  @Uint64()
  external int tarantool_space_put_many_address;
  @Uint64()
  external int tarantool_space_delete_single_address;
  @Uint64()
  external int tarantool_space_delete_many_address;
  @Uint64()
  external int tarantool_space_update_single_address;
  @Uint64()
  external int tarantool_space_update_many_address;
  @Uint64()
  external int tarantool_space_get_address;
  @Uint64()
  external int tarantool_space_min_address;
  @Uint64()
  external int tarantool_space_max_address;
  @Uint64()
  external int tarantool_space_truncate_address;
  @Uint64()
  external int tarantool_space_upsert_address;
  @Uint64()
  external int tarantool_index_count_address;
  @Uint64()
  external int tarantool_index_length_address;
  @Uint64()
  external int tarantool_index_iterator_address;
  @Uint64()
  external int tarantool_index_get_address;
  @Uint64()
  external int tarantool_index_max_address;
  @Uint64()
  external int tarantool_index_min_address;
  @Uint64()
  external int tarantool_index_update_single_address;
  @Uint64()
  external int tarantool_index_update_many_address;
  @Uint64()
  external int tarantool_index_select_address;
  @Uint64()
  external int tarantool_index_id_by_name_address;
}

final class tarantool_index_select_request extends Struct {
  external Pointer<Uint8> key;
}

@Native<Void Function(Pointer<tarantool_box> box)>(isLeaf: true)
external void tarantool_initialize_box(Pointer<tarantool_box> box);

@Native<Void Function(Pointer<tarantool_box> box)>(isLeaf: true)
external void tarantool_destroy_box(Pointer<tarantool_box> box);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_evaluate(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_call(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_iterator(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_count(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_length(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_truncate(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_put_single(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_insert_single(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_update_single(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_delete_single(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_put_many(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_insert_many(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_update_many(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_delete_many(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_upsert(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_get(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_min(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_max(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_select(Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void tarantool_space_id_by_name(Pointer<executor_task> message);
