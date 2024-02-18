import 'package:meta/meta.dart';

import '../constants.dart';
import 'server.dart';

class TransportServerRegistry {
  final _servers = <int, TransportServerChannel>{};
  final _serverConnections = <int, TransportServerConnectionChannel>{};

  TransportServerRegistry();

  @inline
  TransportServerChannel? getServer(int fd) => _servers[fd];

  @inline
  TransportServerConnectionChannel? getConnection(int fd) => _serverConnections[fd];

  @inline
  void addConnection(int connectionFd, TransportServerConnectionChannel connection) => _serverConnections[connectionFd] = connection;

  @inline
  void removeConnection(int fd) => _serverConnections.remove(fd);

  @inline
  void removeServer(int fd) => _servers.remove(fd);

  @inline
  void addServer(int fd, TransportServerChannel channel) => _servers[fd] = channel;

  @inline
  Future<void> close({Duration? gracefulTimeout}) => Future.wait(_servers.values.toList().map((server) => server.close(gracefulTimeout: gracefulTimeout)));

  @visibleForTesting
  Map<int, TransportServerChannel> get servers => _servers;

  @visibleForTesting
  Map<int, TransportServerConnectionChannel> get serverConnections => _serverConnections;
}
