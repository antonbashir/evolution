import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';

import '../bindings.dart';
import '../channel.dart';
import '../constants.dart';
import '../exception.dart';
import '../payload.dart';
import 'file.dart';
import 'provider.dart';
import 'registry.dart';

class TransportFilesFactory {
  final TransportFileRegistry _registry;
  final Pointer<transport> _workerPointer;
  final MemoryStaticBuffers _buffers;
  final TransportPayloadPool _payloadPool;

  const TransportFilesFactory(
    this._registry,
    this._workerPointer,
    this._buffers,
    this._payloadPool,
  );

  TransportFile open(
    String path, {
    TransportFileMode mode = TransportFileMode.readWriteAppend,
    bool create = false,
    bool truncate = false,
  }) {
    final delegate = File(path);
    final fd = using((Arena arena) => transport_file_open(path.toNativeUtf8(allocator: arena).cast(), mode.mode, truncate, create));
    if (fd < 0) throw TransportInitializationException(TransportMessages.fileOpenError(path));
    final file = TransportFileChannel(
      path,
      fd,
      _workerPointer,
      TransportChannel(_workerPointer, fd, _buffers),
      _buffers,
      _payloadPool,
      _registry,
    );
    _registry.add(fd, file);
    return TransportFile(file, delegate);
  }

  @visibleForTesting
  TransportFileRegistry get registry => _registry;
}
