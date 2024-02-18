import 'configuration.dart';

class MemoryDefaults {
  MemoryDefaults._();

  static const memory = MemoryConfiguration(
    staticBuffersCapacity: 4096,
    staticBufferSize: 4096,
    slabSize: 64 * 1024,
    preallocationSize: 64 * 1024,
    quotaSize: 1 * 1024 * 1024,
  );
}
