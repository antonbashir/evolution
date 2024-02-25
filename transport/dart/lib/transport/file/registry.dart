import 'package:core/core.dart';
import 'package:meta/meta.dart';

import 'file.dart';

class TransportFileRegistry {
  final _files = <int, TransportFileChannel>{};

  TransportFileRegistry();

  @inline
  TransportFileChannel? get(int fd) => _files[fd];

  @inline
  void remove(int fd) => _files.remove(fd);

  @inline
  void add(int fd, TransportFileChannel file) => _files[fd] = file;

  @inline
  Future<void> close({Duration? gracefulTimeout}) => Future.wait(_files.values.toList().map((file) => file.close(gracefulTimeout: gracefulTimeout)));

  @visibleForTesting
  Map<int, TransportFileChannel> get files => _files;
}
