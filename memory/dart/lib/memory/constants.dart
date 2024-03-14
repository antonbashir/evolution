import 'dart:ffi';

const memoryBufferUsed = -1;

final memoryLibraryName = bool.fromEnvironment("DEBUG") ? "libmemory_debug_${Abi.current()}.so" : "libmemory_release_${Abi.current()}.so";
final memorySharedLibraryName = bool.fromEnvironment("DEBUG") ? "libmemory_debug_${Abi.current()}_shared.so" : "libmemory_release_${Abi.current()}_shared.so";
const memoryModuleId = 1;
const memoryModuleName = "memory";
const memoryPackageName = "memory";

class MemoryErrors {
  MemoryErrors._();

  static String unknownStructurePool(String type) => "Unknown structure pool: $type";
}

class TupleErrors {
  TupleErrors._();

  static const maxStringLength = 'Max string length is 4294967295';
  static const maxBinaryLength = 'Max binary length is 4294967295';
  static const maxListLength = 'Max list length is 4294967295';
  static const maxMapLength = 'Max map length is 4294967295';
  static notBool(dynamic value) => 'Byte $value is not declare bool';
  static notInt(dynamic value) => "Byte $value is not declare int";
  static notDouble(dynamic value) => "Byte $value is not declare double";
  static notString(dynamic bytes) => "Byte $bytes is not declare string";
  static notBinary(dynamic bytes) => "Byte $bytes is not declare binary";
  static notList(dynamic bytes) => "Byte $bytes is not declare list";
  static notMap(dynamic bytes) => "Byte $bytes is not declare map";
}
