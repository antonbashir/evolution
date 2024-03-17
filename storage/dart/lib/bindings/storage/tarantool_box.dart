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

final class tarantool_space_request extends Struct {
  @Size()
  external int tuple_size;
  external Pointer<Uint8> tuple;
  @Uint32()
  external int space_id;
  external executor_task task;
}

final class tarantool_space_count_request extends Struct {
  @Size()
  external int key_size;
  external Pointer<Uint8> key;
  @Uint32()
  external int space_id;
  @Int32()
  external int iterator_type;
  external executor_task task;
}

final class tarantool_space_select_request extends Struct {
  @Size()
  external int key_size;
  external Pointer<Uint8> key;
  @Uint32()
  external int space_id;
  @Uint32()
  external int offset;
  @Uint32()
  external int limit;
  @Int32()
  external int iterator_type;
  external executor_task task;
}

final class tarantool_space_update_request extends Struct {
  @Size()
  external int key_size;
  @Size()
  external int operations_size;
  external Pointer<Uint8> key;
  external Pointer<Uint8> operations;
  @Uint32()
  external int space_id;
  external executor_task task;
}

final class tarantool_space_upsert_request extends Struct {
  @Size()
  external int tuple_size;
  external Pointer<Uint8> tuple;
  external Pointer<Uint8> operations;
  @Size()
  external int operations_size;
  @Uint32()
  external int space_id;
  external executor_task task;
}

final class tarantool_space_iterator_request extends Struct {
  @Size()
  external int key_size;
  external Pointer<Uint8> key;
  @Uint32()
  external int space_id;
  @Int32()
  external int type;
  external executor_task task;
}

final class tarantool_index_request extends Struct {
  @Size()
  external int tuple_size;
  external Pointer<Uint8> tuple;
  @Uint32()
  external int space_id;
  @Uint32()
  external int index_id;
  external executor_task task;
}

final class tarantool_index_count_request extends Struct {
  @Size()
  external int key_size;
  external Pointer<Uint8> key;
  @Uint32()
  external int space_id;
  @Uint32()
  external int index_id;
  @Int32()
  external int iterator_type;
  external executor_task task;
}

final class tarantool_index_id_by_name_request extends Struct {
  external Pointer<Utf8> name;
  @Size()
  external int name_length;
  @Uint32()
  external int space_id;
  external executor_task task;
}

final class tarantool_index_update_request extends Struct {
  external Pointer<Uint8> key;
  @Size()
  external int key_size;
  external Pointer<Uint8> operations;
  @Size()
  external int operations_size;
  @Uint32()
  external int space_id;
  @Uint32()
  external int index_id;
  external executor_task task;
}

final class tarantool_call_request extends Struct {
  external Pointer<Utf8> function;
  external Pointer<Uint8> input;
  @Size()
  external int input_size;
  @Uint32()
  external int function_length;
  external executor_task task;
}

final class tarantool_evaluate_request extends Struct {
  external Pointer<Utf8> expression;
  external Pointer<Uint8> input;
  @Size()
  external int input_size;
  @Uint32()
  external int expression_length;
  external executor_task task;
}

final class tarantool_index_iterator_request extends Struct {
  external Pointer<Uint8> key;
  @Size()
  external int key_size;
  @Uint32()
  external int space_id;
  @Uint32()
  external int index_id;
  @Int32()
  external int type;
  external executor_task task;
}

final class tarantool_index_select_request extends Struct {
  external Pointer<Uint8> key;
  @Size()
  external int key_size;
  @Uint32()
  external int space_id;
  @Uint32()
  external int index_id;
  @Uint32()
  external int offset;
  @Uint32()
  external int limit;
  @Int32()
  external int iterator_type;
  external executor_task task;
}

final class tarantool_index_id_request extends Struct {
  @Uint32()
  external int space_id;
  @Uint32()
  external int index_id;
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
