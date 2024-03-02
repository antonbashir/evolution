import 'dart:ffi';

import 'package:mediator/mediator.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';

class TransportConfiguration {
  final MemoryModuleConfiguration memoryConfiguration;
  final MediatorConfiguration mediatorConfiguration;
  final Duration timeoutCheckerPeriod;
  final bool trace;

  Pointer<transport_configuration> toNative(Pointer<transport_configuration> native) {
    native.ref.memory_configuration = memoryConfiguration.toNativeValue(native.ref.memory_configuration);
    native.ref.mediator_configuration = mediatorConfiguration.fillNative(native.ref.mediator_configuration);
    native.ref.timeout_checker_period_millis = timeoutCheckerPeriod.inMilliseconds;
    native.ref.trace = trace;
    return native;
  }

  const TransportConfiguration({
    required this.mediatorConfiguration,
    required this.memoryConfiguration,
    required this.timeoutCheckerPeriod,
    required this.trace,
  });

  TransportConfiguration copyWith({
    MemoryModuleConfiguration? memoryConfiguration,
    MediatorConfiguration? mediatorConfiguration,
    Duration? timeoutCheckerPeriod,
    bool? trace,
  }) =>
      TransportConfiguration(
        memoryConfiguration: memoryConfiguration ?? this.memoryConfiguration,
        mediatorConfiguration: mediatorConfiguration ?? this.mediatorConfiguration,
        timeoutCheckerPeriod: timeoutCheckerPeriod ?? this.timeoutCheckerPeriod,
        trace: trace ?? this.trace,
      );
}

class TransportUdpMulticastConfiguration {
  final String groupAddress;
  final String localAddress;
  final String? localInterface;
  final int? interfaceIndex;
  final bool calculateInterfaceIndex;

  const TransportUdpMulticastConfiguration._(
    this.groupAddress,
    this.localAddress,
    this.localInterface,
    this.interfaceIndex,
    this.calculateInterfaceIndex,
  );

  factory TransportUdpMulticastConfiguration.byInterfaceIndex({
    required String groupAddress,
    required String localAddress,
    required int interfaceIndex,
  }) {
    return TransportUdpMulticastConfiguration._(groupAddress, localAddress, null, interfaceIndex, false);
  }

  factory TransportUdpMulticastConfiguration.byInterfaceName({
    required String groupAddress,
    required String localAddress,
    required String interfaceName,
  }) {
    return TransportUdpMulticastConfiguration._(groupAddress, localAddress, interfaceName, -1, true);
  }
}

class TransportUdpMulticastSourceConfiguration {
  final String groupAddress;
  final String localAddress;
  final String sourceAddress;

  const TransportUdpMulticastSourceConfiguration({
    required this.groupAddress,
    required this.localAddress,
    required this.sourceAddress,
  });
}

class TransportUdpMulticastManager {
  void Function(TransportUdpMulticastConfiguration configuration) _onAddMembership = (configuration) => {};
  void Function(TransportUdpMulticastConfiguration configuration) _onDropMembership = (configuration) => {};
  void Function(TransportUdpMulticastSourceConfiguration configuration) _onAddSourceMembership = (configuration) => {};
  void Function(TransportUdpMulticastSourceConfiguration configuration) _onDropSourceMembership = (configuration) => {};

  void subscribe(
      {required void Function(TransportUdpMulticastConfiguration configuration) onAddMembership,
      required void Function(TransportUdpMulticastConfiguration configuration) onDropMembership,
      required void Function(TransportUdpMulticastSourceConfiguration configuration) onAddSourceMembership,
      required void Function(TransportUdpMulticastSourceConfiguration configuration) onDropSourceMembership}) {
    _onAddMembership = onAddMembership;
    _onDropMembership = onDropMembership;
    _onAddSourceMembership = onAddSourceMembership;
    _onDropSourceMembership = onDropSourceMembership;
  }

  void addMembership(TransportUdpMulticastConfiguration configuration) => _onAddMembership(configuration);

  void dropMembership(TransportUdpMulticastConfiguration configuration) => _onDropMembership(configuration);

  void addSourceMembership(TransportUdpMulticastSourceConfiguration configuration) => _onAddSourceMembership(configuration);

  void dropSourceMembership(TransportUdpMulticastSourceConfiguration configuration) => _onDropSourceMembership(configuration);
}
