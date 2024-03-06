import 'dart:ffi';

@Native<Uint64 Function(Pointer<Char>, Uint64)>(symbol: 'memory_tuple_next', assetId: 'memory-bindings', isLeaf: true)
external int memory_tuple_next(Pointer<Char> buffer, int offset);
