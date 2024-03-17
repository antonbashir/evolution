import 'dart:async';
import 'dart:io';

final ffiTypeMapping = {
  "bool": "Bool",
  "double": "Double",
  "int": "Int",
  "float": "Float",
  "size_t": "Size",
  "int8_t": "Int8",
  "uint8_t": "Uint8",
  "int16_t": "Int16",
  "uint16_t": "Uint16",
  "int32_t": "Int32",
  "uint32_t": "Uint32",
  "int64_t": "Int64",
  "uint64_t": "Uint64",
  "intptr_t": "Int64",
  "uintptr_t": "Uint64",
  "__s8": "Int8",
  "__u8": "Uint8",
  "__s16": "Int16",
  "__u16": "Uint16",
  "__s32": "Int32",
  "__u32": "Uint32",
  "__s64": "Int64",
  "__u64": "Uint64",
  "char": "Uint8",
  "void": "Void",
};

final dartTypeMapping = {
  "bool": "bool",
  "void": "void",
  "int": "int",
  "double": "double",
  "float": "double",
  "size_t": "int",
  "int8_t": "int",
  "uint8_t": "int",
  "int16_t": "int",
  "uint16_t": "int",
  "int32_t": "int",
  "uint32_t": "int",
  "int64_t": "int",
  "uint64_t": "int",
  "intptr_t": "int",
  "uintptr_t": "int",
  "__s8": "int",
  "__u8": "int",
  "__s16": "int",
  "__u16": "int",
  "__s32": "int",
  "__u32": "int",
  "__s64": "int",
  "__u64": "int",
  "char": "int",
};

const dartField = "DART_FIELD";
const dartStructure = "DART_STRUCTURE";
const dartFunction = "DART_FUNCTION";
const dartInlineFunction = "DART_LEAF_FUNCTION";
const dartLeafFunction = "DART_LEAF_FUNCTION";
const dartLeafInlineFunction = "DART_INLINE_LEAF_FUNCTION";
const dartType = "DART_TYPE";
const dartSubstitute = "DART_SUBSTITUTE";
final dartSubstituteRegexp = RegExp(r"DART_SUBSTITUTE\((.+)\)");

const structWord = "struct";
const constWord = "const";

const dartFormatLine = 500;

const generatedFilePrefix = "// Generated\n// ignore_for_file: unused_import\n\n";
const generatedFileImports = "import 'dart:ffi';\nimport 'package:ffi/ffi.dart';";

const exclusions = [
  "CMakeFiles",
];

class StructureDeclaration {
  String name = "";
  Map<String, String> fields = {};

  @override
  String toString() => "$name$fields";
}

class FunctionDeclaration {
  String returnType = "";
  String functionName = "";
  Map<String, String> arguments = {};
  bool leaf = false;
}

class FileDeclarations {
  Set<String> types = {};
  List<StructureDeclaration> structures = [];
  List<FunctionDeclaration> functions = [];
}

Future<void> main(List<String> args) async {
  final current = Directory.current.path;
  final nativeDirectory = current + '/' + 'native';
  final dartDirectory = current + '/' + 'dart/lib/bindings';
  final natives = collectNative(nativeDirectory);
  generateDart(natives, nativeDirectory, dartDirectory);
}

extension ArgumentsExtension on List<String> {
  Iterable<MapEntry<String, String>> toArguments(FileDeclarations fileDeclarations) => map((element) => element.trim())
      .map((line) {
        if (line.contains(dartSubstitute)) {
          final type = dartSubstituteRegexp.allMatches(line).first.group(1)!;
          final name = line.replaceAll(dartSubstituteRegexp, "").clear().split(" ")[1];
          return MapEntry(name, type);
        }
        if (line.contains(dartType)) {
          line = line.replaceAll(dartType, "");
          if (line.isEmpty || !line.contains(" ")) null;
          if (!(line.contains(structWord))) null;
          final name = line.substring(line.lastIndexOf(' '));
          final type = line.substring(0, line.lastIndexOf(' '));
          fileDeclarations.types.add(type.clear().replaceAll("*", ""));
          return MapEntry(name, type);
        }
        if (line.isNotEmpty && line.contains(" ")) {
          return MapEntry(line.substring(line.lastIndexOf(' ')), line.substring(0, line.lastIndexOf(' ')));
        }
        return null;
      })
      .where((element) => element != null)
      .map((entry) => entry!);
}

extension StringExtension on String {
  String clear() => replaceAll(constWord, "").replaceAll(structWord, "").replaceAll(";", "").trim();
}

Map<String, FileDeclarations> collectNative(String nativeDirectory) {
  final nativeFiles = <String, FileDeclarations>{};
  Directory(nativeDirectory).listSync(recursive: false).forEach((child) {
    if (child.statSync().type == FileSystemEntityType.directory) {
      if (exclusions.any(child.path.endsWith)) return;
      nativeFiles.addAll(collectNative(child.path));
      return;
    }
    if (!child.path.endsWith(".h")) return;
    if (child.statSync().type != FileSystemEntityType.file) return;
    Process.runSync("clang-format", ["-i", "${child.path}"], workingDirectory: nativeDirectory);
    final fileName = child.path.replaceRange(0, child.path.lastIndexOf('native/') + 7, "").substring(0, child.path.replaceRange(0, child.path.lastIndexOf('native/') + 7, "").indexOf('.'));
    if (nativeFiles.containsKey(fileName)) return;
    final fileDeclarations = FileDeclarations();
    nativeFiles[fileName] = fileDeclarations;
    bool commentBlock = false;
    StructureDeclaration? currentStructureDeclaration = null;
    FunctionDeclaration? currentFunctionDeclaration = null;
    File(child.absolute.path).readAsLinesSync().forEach((line) {
      if (line.trimLeft().startsWith("//") || line.trimLeft().startsWith("/*")) {
        commentBlock = commentBlock || (line.trimLeft().startsWith("/*") && !line.contains("*/"));
        return;
      }
      if (line.contains("*/")) {
        commentBlock = false;
        line = line.substring(line.lastIndexOf("*/") + 2, line.length);
      }
      if (currentStructureDeclaration != null) {
        if (line == "};") {
          currentStructureDeclaration = null;
          return;
        }
        if (line == "{") {
          return;
        }
        if (line.contains(dartField)) {
          if (line.contains(dartSubstitute)) {
            final type = dartSubstituteRegexp.allMatches(line).first.group(1)!;
            final name = line.replaceAll(dartField, "").replaceAll(dartSubstituteRegexp, "").clear().split(" ")[1];
            currentStructureDeclaration!.fields[name] = type;
            return;
          }
          if (line.contains(dartType)) {
            line = line.replaceAll(dartType, "");
            if (line.isEmpty) return;
            if (!(line.contains(structWord))) return;
            line = line.replaceAll(dartField, "").clear();
            final name = line.split(" ")[1];
            final type = line.split(" ")[0];
            currentStructureDeclaration!.fields[name] = type;
            fileDeclarations.types.add(type.replaceAll("*", ""));
            return;
          }
          line = line.replaceAll(dartField, "").clear();
          currentStructureDeclaration!.fields[line.split(" ")[1]] = line.split(" ")[0];
          return;
        }
      }
      if (currentFunctionDeclaration != null) {
        final end = line.endsWith(")") || line.endsWith(");");
        line = line.endsWith(")")
            ? line.substring(0, line.lastIndexOf(")"))
            : line.endsWith(");")
                ? line.replaceAll(");", "")
                : line;
        currentFunctionDeclaration!.arguments.addAll(Map.fromEntries(line.split(",").toArguments(fileDeclarations)));
        if (end) currentFunctionDeclaration = null;
        return;
      }
      if (line.contains(dartStructure)) {
        line = line.replaceAll(dartStructure, "");
        if (line.isEmpty) return;
        if (!(line.contains(structWord))) return;
        currentStructureDeclaration = StructureDeclaration();
        fileDeclarations.structures.add(currentStructureDeclaration!);
        currentStructureDeclaration!.name = line.replaceAll(structWord, "").replaceAll("{", "").trim();
        currentStructureDeclaration!.fields = {};
        return;
      }
      if (line.contains(dartType) && line.trimLeft().startsWith(dartType)) {
        line = line.replaceAll(dartType, "");
        if (line.isEmpty) return;
        if (!(line.contains(structWord))) return;
        fileDeclarations.types.add(line.clear());
        return;
      }
      if (line.contains(dartInlineFunction) || line.contains(dartFunction) || line.contains(dartLeafFunction) || line.contains(dartLeafInlineFunction)) {
        final leaf = line.contains(dartLeafFunction) || line.contains(dartLeafInlineFunction);
        line = line.replaceAll(dartInlineFunction, "").replaceAll(dartFunction, "").replaceAll(dartLeafFunction, "").replaceAll(dartLeafInlineFunction, "");
        if (line.isEmpty) return;
        if (line.contains("(") || line.contains(")")) {
          currentFunctionDeclaration = FunctionDeclaration();
          fileDeclarations.functions.add(currentFunctionDeclaration!);
        }
        if (line.contains("(") && line.contains(")")) {
          final openBraceIndex = line.indexOf('(');
          final closeBraceIndex = line.lastIndexOf(')');
          final functionName = line.substring(0, openBraceIndex).split(" ").last;
          final returnType = line.substring(0, line.indexOf(functionName)).trim();
          final arguments = Map.fromEntries(line.substring(openBraceIndex + 1, closeBraceIndex).split(",").toArguments(fileDeclarations));
          currentFunctionDeclaration!.functionName = functionName;
          currentFunctionDeclaration!.returnType = returnType;
          currentFunctionDeclaration!.arguments = arguments;
          currentFunctionDeclaration!.leaf = leaf;
          currentFunctionDeclaration = null;
          return;
        }
        if (line.contains("(")) {
          final openBraceIndex = line.indexOf('(');
          final functionName = line.substring(0, openBraceIndex).split(" ").last;
          final returnType = line.substring(0, line.indexOf(functionName)).trim();
          final arguments = Map.fromEntries(line.substring(openBraceIndex + 1).split(",").toArguments(fileDeclarations));
          currentFunctionDeclaration!.functionName = functionName;
          currentFunctionDeclaration!.returnType = returnType;
          currentFunctionDeclaration!.arguments = arguments;
          currentFunctionDeclaration!.leaf = leaf;
          return;
        }
      }
    });
  });
  nativeFiles.removeWhere((key, value) => value.structures.isEmpty && value.functions.isEmpty && value.types.isEmpty);
  return nativeFiles;
}

void generateDart(Map<String, FileDeclarations> declarations, String nativeDirectory, String dartDirectory) {
  final moduleName = Directory.current.path.substring(Directory.current.path.lastIndexOf('/') + 1);
  if (!Directory(dartDirectory + '/').existsSync()) Directory(dartDirectory + '/').createSync(recursive: true);
  declarations.forEach((key, value) {
    if (key.contains("/")) {
      if (!Directory(dartDirectory + '/' + key.substring(0, key.lastIndexOf('/'))).existsSync()) Directory(dartDirectory + '/' + key.substring(0, key.lastIndexOf('/'))).createSync(recursive: true);
    }
    if (!File(dartDirectory + '/$key.dart').existsSync()) File(dartDirectory + '/$key.dart').createSync();
    final dartContent = File(dartDirectory + '/$key.dart').readAsLinesSync();
    var resultContent = generatedFilePrefix;
    final imports = dartContent.where((element) => element.startsWith("import")).toList();
    if (imports.isEmpty) resultContent += "$generatedFileImports\nimport '../../$moduleName/bindings.dart';\n";
    if (imports.isNotEmpty) imports.forEach((element) => resultContent += "${element}\n");
    resultContent += "\n";
    resultContent += value.types.map((type) => "final class $type extends Opaque {}").join("\n");
    resultContent = generateStructures(value, resultContent);
    resultContent = generateFunctions(value, resultContent);
    File(dartDirectory + '/$key.dart').writeAsStringSync(resultContent);
    unawaited(Process.run("dart", ["format", "-l ${dartFormatLine}", dartDirectory + '/$key.dart']));
    generateBindings(declarations, moduleName);
  });
}

void generateBindings(Map<String, FileDeclarations> declarations, String moduleName) {
  if (File(Directory.current.path + "/dart/lib/$moduleName/bindings.dart").existsSync()) {
    final exports = File(Directory.current.path + "/dart/lib/$moduleName/bindings.dart").readAsLinesSync().where((element) => element.startsWith("export")).toSet();
    exports.addAll(declarations.keys.map((fileName) => "export '../bindings/$fileName.dart';"));
    File(Directory.current.path + "/dart/lib/$moduleName/bindings.dart").writeAsStringSync(generatedFilePrefix + exports.join("\n"));
    return;
  }
  File(Directory.current.path + "/dart/lib/$moduleName/bindings.dart").writeAsStringSync("${declarations.keys.map((e) => "export '../bindings/$e.dart';").join("\n")}");
}

String generateFunctions(FileDeclarations value, String resultContent) {
  for (var function in value.functions) {
    resultContent += """
@Native<${generateFunctionPart(function.returnType).$1} Function(${function.arguments.entries.map((argument) => "${generateFunctionPart(argument.value).$1} ${argument.key.trim()}").join(", ")})>(isLeaf: ${function.leaf})
external ${generateFunctionPart(function.returnType).$2} ${function.functionName}(${function.arguments.entries.map((argument) => "${generateFunctionPart(argument.value).$2} ${argument.key.trim()}").join(", ")});
  
""";
  }
  return resultContent;
}

String generateStructures(FileDeclarations value, String resultContent) {
  for (var structure in value.structures) {
    switch (structure.fields.isEmpty) {
      case true:
        resultContent += """
final class ${structure.name} extends Opaque {}
  
""";
      case false:
        resultContent += """
final class ${structure.name} extends ${structure.fields.isEmpty ? "Opaque" : "Struct"} {
  ${structure.fields.entries.map((entry) => generateStructureField(entry.key, entry.value)).join("")}}
  
""";
    }
  }
  return resultContent;
}

String generateStructureField(String name, String type) {
  type = type.clear();
  var pointers = 0;
  final arrays = <int>[];
  while (type.endsWith("*")) {
    pointers++;
    type = type.substring(0, type.length - 1);
  }
  while (name.contains("[")) {
    arrays.add(int.parse(name.substring(name.indexOf("[") + 1, name.indexOf("]"))));
    name = name.replaceRange(name.indexOf("["), name.indexOf("]") + 1, "");
  }
  if (arrays.isEmpty) {
    if (pointers == 1 && type == "char") return "external Pointer<Utf8> ${name};\n";
    if (pointers == 0 && ffiTypeMapping.containsKey(type)) return "@${ffiTypeMapping[type] ?? type}()\nexternal ${dartTypeMapping[type] ?? type} ${name};\n";
    if (pointers == 0 && !ffiTypeMapping.containsKey(type)) return "external $type ${name};\n";
    if (pointers == 1) return "external Pointer<${ffiTypeMapping[type] ?? type}> ${name};\n" "";
    var pointerType = "";
    var pointersCount = pointers;
    while (pointers-- > 0) pointerType = "Pointer<$pointerType";
    pointerType = "$pointerType${ffiTypeMapping[type] ?? type}";
    while (pointersCount-- > 0) pointerType = "$pointerType>";
    return "external ${pointerType} ${name};\n";
  }

  String wrapArray(String type) {
    var arrayType = "";
    var arraysLength = arrays.length;
    var arraysCount = arrays.length;
    while (arraysLength-- > 0) arrayType = "Array<$arrayType";
    arrayType = "$arrayType${type}";
    while (arraysCount-- > 0) arrayType = "$arrayType>";
    return arrayType;
  }

  if (pointers == 1 && type == "char") return "@Array(${arrays.join(",")})\nexternal ${wrapArray("Pointer<Utf8>")} ${name};\n";
  if (pointers == 0 && ffiTypeMapping.containsKey(type)) return "@Array(${arrays.join(",")})\nexternal ${wrapArray(ffiTypeMapping[type] ?? type)} ${name};\n";
  if (pointers == 0 && !ffiTypeMapping.containsKey(type)) return "@Array(${arrays.join(",")})\nexternal ${wrapArray(type)} ${name};\n";
  if (pointers == 1) return "@Array(${arrays.join(",")})\nexternal ${wrapArray("Pointer<${ffiTypeMapping[type] ?? type}>")} ${name};\n" "";
  var pointerType = "";
  var pointersCount = pointers;
  while (pointers-- > 0) pointerType = "Pointer<$pointerType";
  pointerType = "$pointerType${ffiTypeMapping[type] ?? type}";
  while (pointersCount-- > 0) pointerType = "$pointerType>";
  return "@Array(${arrays.join(",")})\nexternal ${wrapArray(pointerType)} ${name};\n";
}

(String, String) generateFunctionPart(String type) {
  type = type.clear();
  var pointers = 0;
  while (type.endsWith("*")) {
    pointers++;
    type = type.substring(0, type.length - 1);
  }
  if (pointers == 1 && type == "char") return ("Pointer<Utf8>", "Pointer<Utf8>");
  if (pointers == 0) return (ffiTypeMapping[type] ?? type, dartTypeMapping[type] ?? type);
  if (pointers == 1) return ("Pointer<${ffiTypeMapping[type] ?? type}>", "Pointer<${ffiTypeMapping[type] ?? type}>");
  var pointerType = "Pointer<";
  var pointersCount = pointers;
  while (pointers-- > 0) pointerType = "Pointer<$pointerType";
  pointerType = "pointerType${ffiTypeMapping[type] ?? type}}";
  while (pointersCount-- > 0) pointerType = "$pointerType>";
  return (pointerType, pointerType);
}
