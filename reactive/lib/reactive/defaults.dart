import 'package:transport/transport.dart';

import 'codec.dart';
import 'configuration.dart';
import 'constants.dart';

class ReactiveTransportDefaults {
  ReactiveTransportDefaults._();

  static const module = ReactiveModuleConfiguration(
    tracer: null,
    gracefulTimeout: null,
    workerConfiguration: TransportDefaults.transport,
  );

  static const channel = ReactiveChannelConfiguration(
    initialRequestCount: 1,
    chunksLimit: 8,
    frameMaxSize: 5 * 1024 * 1024,
    fragmentSize: 10 * 1024 * 1024,
  );

  static const broker = ReactiveBrokerConfiguration(
    codecs: {
      octetStreamMimeType: ReactiveRawCodec(),
      textMimeType: ReactiveUtf8Codec(),
      applicationJsonMimeType: ReactiveJsonCodec(),
    },
  );

  static const setup = ReactiveSetupConfiguration(
    metadataMimeType: applicationJsonMimeType,
    dataMimeType: applicationJsonMimeType,
    keepAliveInterval: Duration(seconds: 20),
    keepAliveMaxLifetime: Duration(seconds: 90),
    lease: false,
  );
}
