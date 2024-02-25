import 'package:core/core.dart';
import 'package:meta/meta.dart';

import 'client.dart';

class TransportClientRegistry {
  final _clients = <int, TransportClientChannel>{};

  TransportClientRegistry();

  @inline
  TransportClientChannel? get(int fd) => _clients[fd];

  @inline
  void remove(int fd) => _clients.remove(fd);

  @inline
  void add(int fd, TransportClientChannel channel) => _clients[fd] = channel;

  @inline
  Future<void> close({Duration? gracefulTimeout}) => Future.wait(_clients.values.toList().map((client) => client.close(gracefulTimeout: gracefulTimeout)));

  @visibleForTesting
  Map<int, TransportClientChannel> get clients => _clients;
}
