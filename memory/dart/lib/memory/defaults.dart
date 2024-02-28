import 'configuration.dart';

class MemoryDefaults {
  MemoryDefaults._();

  static const module = MemoryModuleConfiguration(
    staticBuffersCapacity: 4096,
    staticBufferSize: 4096,
    slabSize: 64 * 1024,
    preallocationSize: 64 * 1024,
    quotaSize: 1 * 1024 * 1024,
  );

  static const objects = MemoryObjectsConfiguration(
    initialCapacity: 16,
    minimalAvailableCapacity: 8,
    preallocation: 16,
    extensionFactor: 2,
    shrinkFactor: 0.5,
  );
}
