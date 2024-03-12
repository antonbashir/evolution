import 'dart:io';

final ffiTypeMapping = {
  "bool": "Bool",
  "double": "Double",
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
  "void": "Void",
};

final dartTypeMapping = {
  "bool": "bool",
  "void": "void",
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
};

const dartField = "DART_FIELD";
const dartStructure = "DART_STRUCTURE";
const dartFunction = "DART_FUNCTION";
const dartInlineFunction = "DART_INLINE_FUNCTION";
const structWord = "struct";
const constWord = "const";

class StructureDeclaration {
  String name = "";
  Map<String, String> fields = {};
}

class FunctionDeclaration {
  String returnType = "";
  String functionName = "";
  Map<String, String> arguments = {};
}

class FileDeclarations {
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

Map<String, FileDeclarations> collectNative(String nativeDirectory) {
  final nativeFiles = <String, FileDeclarations>{};
  Directory(nativeDirectory).listSync(recursive: true).forEach((child) {
    if (!child.path.endsWith(".h")) return;
    if (child.statSync().type != FileSystemEntityType.file) return;
    final fileName = child.path.replaceRange(0, child.path.lastIndexOf('native/') + 7, "").substring(0, child.path.replaceRange(0, child.path.lastIndexOf('native/') + 7, "").indexOf('.'));
    if (nativeFiles.containsKey(fileName)) return;
    final fileDeclarations = FileDeclarations();
    nativeFiles[fileName] = fileDeclarations;
    StructureDeclaration? currentStructureDeclaration = null;
    File(child.absolute.path).readAsLinesSync().forEach((line) {
      if (currentStructureDeclaration != null) {
        if (line == "};") {
          currentStructureDeclaration = null;
          return;
        }
        if (line == "{") {
          return;
        }
        if (line.contains(dartField)) {
          line = line.replaceAll(dartField, "").replaceAll("struct", "").replaceAll(";", "").trim();
          currentStructureDeclaration!.fields[line.split(" ")[0]] = line.split(" ")[1];
          return;
        }
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
      if (line.contains(dartInlineFunction) || line.contains(dartFunction)) {
        line = line.replaceAll(dartInlineFunction, "").replaceAll(dartFunction, "");
        if (line.isEmpty) return;
        if (!(line.contains("(") && line.contains(")"))) return;
        final functionDeclaration = FunctionDeclaration();
        fileDeclarations.functions.add(functionDeclaration);
        final openBraceIndex = line.indexOf('(');
        final closeBraceIndex = line.indexOf(')');
        final functionName = line.substring(0, openBraceIndex).split(" ").last;
        final returnType = line.substring(0, line.indexOf(functionName)).trim();
        final arguments = Map.fromEntries(
          line
              .substring(openBraceIndex + 1, closeBraceIndex)
              .split(",")
              .map((e) => e.trim())
              .where((element) => element.isNotEmpty && element.contains(" "))
              .map((e) => MapEntry(e.substring(0, e.lastIndexOf(' ')), e.substring(e.lastIndexOf(' ')))),
        );
        functionDeclaration.functionName = functionName;
        functionDeclaration.returnType = returnType;
        functionDeclaration.arguments = arguments;
      }
    });
  });
  nativeFiles.removeWhere((key, value) => value.structures.isEmpty && value.functions.isEmpty);
  return nativeFiles;
}

void generateDart(Map<String, FileDeclarations> declarations, String nativeDirectory, String dartDirectory) {
  if (!Directory(dartDirectory).existsSync()) Directory(dartDirectory).createSync(recursive: true);
  final moduleName = Directory.current.path.substring(Directory.current.path.lastIndexOf('/') + 1);
  declarations.forEach((key, value) {
    if (!File(dartDirectory + '/$key.dart').existsSync()) File(dartDirectory + '/$key.dart').createSync();
    final dartContent = File(dartDirectory + '/$key.dart').readAsLinesSync();
    var resultContent = "// ignore_for_file: unused_import\n\n";
    final imports = dartContent.where((element) => element.startsWith("import")).toList();
    if (imports.isEmpty) resultContent += "import 'dart:ffi';\nimport '../../$moduleName/bindings.dart';\n";
    if (imports.isNotEmpty) imports.forEach((element) => resultContent += "${element}\n");
    resultContent += "\n";
    resultContent = generateStructures(value, resultContent);
    resultContent = generateFunctions(value, resultContent);
    File(dartDirectory + '/$key.dart').writeAsStringSync(resultContent);
    Process.runSync("dart", ["format", "-l 500", dartDirectory + '/$key.dart']);
    if (File(Directory.current.path + "/dart/lib/$moduleName/bindings.dart").existsSync()) {
      final exports = File(Directory.current.path + "/dart/lib/$moduleName/bindings.dart").readAsLinesSync().toSet();
      exports.addAll(declarations.keys.map((e) => "export '../bindings/$e.dart';"));
      File(Directory.current.path + "/dart/lib/$moduleName/bindings.dart").writeAsStringSync(exports.join("\n"));
      return;
    }
    File(Directory.current.path + "/dart/lib/$moduleName/bindings.dart").writeAsStringSync("${declarations.keys.map((e) => "export '../bindings/$e.dart';").join("\n")}");
  });
}

String generateFunctions(FileDeclarations value, String resultContent) {
  for (var function in value.functions) {
    resultContent += """
@Native<${generateFunctionPart(function.returnType).$1} Function(${function.arguments.entries.map((argument) => "${generateFunctionPart(argument.key).$1} ${argument.value.trim()}").join(", ")})>(isLeaf: true)
external ${generateFunctionPart(function.returnType).$2} ${function.functionName}(${function.arguments.entries.map((argument) => "${generateFunctionPart(argument.key).$2} ${argument.value.trim()}").join(", ")});
  
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

String generateStructureField(String type, String name) { 
  type = type.replaceAll(constWord, "").replaceAll(structWord, "").trim();
  var pointers = 0;
  while (type.endsWith("*")) {
    pointers++;
    type = type.substring(0, type.length - 1);
  }
  if (pointers == 1 && type == "char") return "external Pointer<Utf8> ${name};\n";
  if (pointers == 0) return "@${ffiTypeMapping[type] ?? type}()\nexternal ${dartTypeMapping[type] ?? type} ${name};\n";
  if (pointers == 1) return "external Pointer<${ffiTypeMapping[type] ?? type}> ${name};\n" "";
  var pointerType = "";
  var pointersCount = pointers;
  while (pointers-- > 0) pointerType = "Pointer<$pointerType";
  pointerType = "$pointerType${ffiTypeMapping[type] ?? type}";
  while (pointersCount-- > 0) pointerType = "$pointerType>";
  return "external ${pointerType} ${name};\n";
}

(String, String) generateFunctionPart(String type) {
  type = type.replaceAll(constWord, "").replaceAll("struct", "").trim();
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
