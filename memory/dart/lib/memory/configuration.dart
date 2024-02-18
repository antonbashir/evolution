class MemoryConfiguration {
  final int staticBuffersCapacity;
  final int staticBufferSize;
  final int slabSize;
  final int preallocationSize;
  final int quotaSize;

  const MemoryConfiguration({
    required this.staticBuffersCapacity,
    required this.staticBufferSize,
    required this.slabSize,
    required this.preallocationSize,
    required this.quotaSize,
  });

  MemoryConfiguration copyWith({
    int? staticBuffersCapacity,
    int? staticBufferSize,
    int? slabSize,
    int? preallocationSize,
    int? quotaSize,
  }) =>
      MemoryConfiguration(
        staticBuffersCapacity: staticBuffersCapacity ?? this.staticBuffersCapacity,
        staticBufferSize: staticBufferSize ?? this.staticBufferSize,
        slabSize: slabSize ?? this.slabSize,
        preallocationSize: preallocationSize ?? this.preallocationSize,
        quotaSize: quotaSize ?? this.quotaSize,
      );
}
