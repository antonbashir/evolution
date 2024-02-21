import 'package:core/core.dart';

import 'payload.dart';
import 'bindings.dart';
import 'constants.dart';

class TransportInitializationException implements Exception {
  final String message;

  TransportInitializationException(this.message);

  @override
  String toString() => message;
}

class TransportInternalException implements Exception {
  final TransportEvent event;
  final int code;

  late final String message;

  TransportInternalException({
    required this.event,
    required this.code,
  }) : this.message = TransportMessages.internalError(event, code);

  @override
  String toString() => message;
}

class TransportCanceledException implements Exception {
  final TransportEvent event;

  late final String message;

  TransportCanceledException(this.event) : this.message = TransportMessages.canceledError(event);

  @override
  String toString() => message;
}

class TransportClosedException implements Exception {
  final String message;

  TransportClosedException._(this.message);

  factory TransportClosedException.forServer({TransportPayload? payload}) => TransportClosedException._(TransportMessages.serverClosedError);

  factory TransportClosedException.forClient({TransportPayload? payload}) => TransportClosedException._(TransportMessages.clientClosedError);

  factory TransportClosedException.forFile({TransportPayload? payload}) => TransportClosedException._(TransportMessages.fileClosedError);

  @override
  String toString() => message;
}

class TransportZeroDataException implements Exception {
  final TransportEvent event;

  late final String message;

  TransportZeroDataException(this.event) : message = TransportMessages.zeroDataError(event);

  @override
  String toString() => message;
}

@inline
Exception createTransportException(TransportEvent event, int result) {
  if (result < 0) {
    if (result == -ECANCELED) {
      return TransportCanceledException(event);
    }
    return TransportInternalException(
      event: event,
      code: result,
    );
  }
  return TransportZeroDataException(event);
}
