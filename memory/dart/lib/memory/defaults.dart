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

  static const objectPool = MemoryObjectPoolConfiguration(
    initialCapacity: 2048,
    preallocation: 1024,
    extensionFactor: 2,
    shrinkFactor: 0.5,
  );
}
