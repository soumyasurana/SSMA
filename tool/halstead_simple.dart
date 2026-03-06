#!/usr/bin/env dart


import 'dart:io';
import 'dart:math';
import 'dart:convert'; // Used for CSV output

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

// Use natural log base for Halstead calculations
const double ln2 = 0.69314718056;

/// -------------------- Data Classes --------------------

class MethodMetrics {
  int fanIn = 0;
  int fanOut = 0;
  int liveVariables = 0;
  int cyclomatic = 1; // default 1 for each method
}

class ClassMetrics {
  final String name;
  Set<String> declaredFields = {};
  Set<String> methods = {};
  Map<String, Set<String>> methodFieldAccess = {};
  Map<String, int> methodCyclomatic = {};
  Set<String> referencedClasses = {};
  String? extendsName;

  ClassMetrics(this.name);
}

/// -------------------- Halstead + Method + Class Visitor --------------------

// Global maps (cleared per file in analyzeFile)
Map<String, MethodMetrics> _methodMetrics = {};
Map<String, ClassMetrics> _classMetrics = {};

class MetricCollector extends RecursiveAstVisitor<void> {
  // Halstead primitives
  final Set<String> distinctOperators = {};
  final Set<String> distinctOperands = {};
  int totalOperators = 0;
  int totalOperands = 0;

  // current tracking
  String? _currentMethodName;
  String? _currentClassName;
  // Set<String> _localVariablesDeclared = {}; // Not strictly needed for final metrics
  Set<String> _variablesReadOrWritten = {}; // Used for Live Variables count

  MetricCollector();

  // helper: count operator token
  void _countOperator(Token operator) {
    final lexeme = operator.lexeme;
    distinctOperators.add(lexeme);
    totalOperators++;
  }

  void _countOperand(SimpleIdentifier identifier) {
    final name = identifier.name;
    // Exclude reserved words and identifiers used as keys/types
    if (name != 'super' && name != 'this') {
      distinctOperands.add(name);
      totalOperands++;
    }
  }

  // ---- class/method lifecycle handling ----

  void _enterMethod(String name) {
    _currentMethodName = name;
    _methodMetrics.putIfAbsent(name, () => MethodMetrics());
    _variablesReadOrWritten.clear();
  }

  void _exitMethod() {
    if (_currentMethodName != null) {
      _methodMetrics[_currentMethodName]!.liveVariables = _variablesReadOrWritten.length;
    }
    _currentMethodName = null;
  }


  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final clsName = node.name.lexeme;
    final cm = ClassMetrics(clsName);

    final extendsClause = node.extendsClause;
    if (extendsClause != null) {
      cm.extendsName = extendsClause.superclass.name.name;
    }

    _classMetrics[clsName] = cm;

    final prevClass = _currentClassName;
    _currentClassName = clsName;
    super.visitClassDeclaration(node);
    _currentClassName = prevClass;
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (_currentClassName != null) {
      final cm = _classMetrics[_currentClassName]!;
      // Record field names
      for (var v in node.fields.variables) {
        cm.declaredFields.add(v.name.lexeme);
      }
    }
    super.visitFieldDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final name = node.name.lexeme;
    _enterMethod(name);

    if (node.returnType != null) {
      _countOperator(node.returnType!.beginToken);
    } else {
      distinctOperators.add('void/implicit');
      totalOperators++;
    }

    super.visitFunctionDeclaration(node);

    _exitMethod();
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final name = node.name.lexeme;
    if (_currentClassName != null) {
      final cm = _classMetrics[_currentClassName]!;
      cm.methods.add(name);
      cm.methodFieldAccess.putIfAbsent(name, () => <String>{});
      cm.methodCyclomatic.putIfAbsent(name, () => 1);
    }

    _enterMethod(name);

    if (node.returnType != null) {
      _countOperator(node.returnType!.beginToken);
    } else {
      distinctOperators.add('void/implicit');
      totalOperators++;
    }

    super.visitMethodDeclaration(node);

    if (_currentClassName != null) {
      final cm = _classMetrics[_currentClassName]!;
      cm.methodCyclomatic[name] = _methodMetrics[name]?.cyclomatic ?? 1;
    }

    _exitMethod();
  }

  // method invocation: fan in/out + halstead operator tokens
  @override
  void visitMethodInvocation(MethodInvocation node) {
    final targetName = node.methodName.name;
    if (_currentMethodName != null) {
      _methodMetrics[_currentMethodName]!.fanOut++;
    }
    if (_methodMetrics.containsKey(targetName)) {
      _methodMetrics[targetName]!.fanIn++;
    }

    // parentheses as operators
    _countOperator(node.argumentList.leftParenthesis);
    _countOperator(node.argumentList.rightParenthesis);

    // If the method target is a simple identifier, check if it's an external class reference
    if (node.target is SimpleIdentifier) {
      final typeName = (node.target as SimpleIdentifier).name;
       if (_currentClassName != null && _classMetrics.containsKey(_currentClassName)) {
        // Add to class references (best-effort)
        _classMetrics[_currentClassName]!.referencedClasses.add(typeName);
      }
    }


    super.visitMethodInvocation(node);
  }


  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final ctorType = node.constructorName.type;
    if (ctorType != null) {
      final typeName = ctorType.name.name;
      if (_currentClassName != null && _classMetrics.containsKey(_currentClassName)) {
        _classMetrics[_currentClassName]!.referencedClasses.add(typeName);
      }
      // Treat constructor creation as Halstead operator (e.g., 'new Class()')
      distinctOperators.add('new::${typeName}');
      totalOperators++;
    }
    super.visitInstanceCreationExpression(node);
  }


  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final parent = node.parent;

    // CBO: If this identifier is a type reference (NamedType), record class reference
    // This captures coupling via parameters, return types, and field types.
    if (parent is NamedType) {
      final typeName = node.name;
      if (_currentClassName != null && typeName != _currentClassName) {
        _classMetrics[_currentClassName]!.referencedClasses.add(typeName);
      }
      super.visitSimpleIdentifier(node);
      return;
    }

    // Skip method name when it's the method invocation target itself
    if (parent is MethodInvocation && parent.methodName == node) {
      super.visitSimpleIdentifier(node);
      return;
    }

    // Halstead Operands: count as operand if not keyword/operator
    if (!(node.token.type.isKeyword || node.token.type.isOperator)) {
      _countOperand(node);
    }

    // LCOM: If this identifier matches a declared field in the current class, mark access
    if (_currentClassName != null) {
      final cm = _classMetrics[_currentClassName]!;
      final fieldName = node.name;
      if (cm.declaredFields.contains(fieldName) && _currentMethodName != null) {
        cm.methodFieldAccess.putIfAbsent(_currentMethodName!, () => <String>{});
        cm.methodFieldAccess[_currentMethodName!]!.add(fieldName);
      }
    }

    // Live Vars: For method-level tracking
    if (_currentMethodName != null) {
      _variablesReadOrWritten.add(node.name);
    }

    super.visitSimpleIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    // Check if the property is a declared field in the current class (e.g., this.field)
    final propertyName = node.propertyName.name;

    if (_currentClassName != null) {
      final cm = _classMetrics[_currentClassName]!;
      if (cm.declaredFields.contains(propertyName) && _currentMethodName != null) {
        cm.methodFieldAccess.putIfAbsent(_currentMethodName!, () => <String>{});
        cm.methodFieldAccess[_currentMethodName!]!.add(propertyName);
      }
    }

    super.visitPropertyAccess(node);
  }

  // ---- Cyclomatic complexity increments ----
  void _incCyclomaticForCurrentMethod([int by = 1]) {
    if (_currentMethodName == null) return;
    final mm = _methodMetrics.putIfAbsent(_currentMethodName!, () => MethodMetrics());
    mm.cyclomatic += by;
  }

  @override
  void visitIfStatement(IfStatement node) {
    _countOperator(node.ifKeyword);
    if (node.elseKeyword != null) _countOperator(node.elseKeyword!);
    _incCyclomaticForCurrentMethod();
    super.visitIfStatement(node);
  }

  @override
  void visitForStatement(ForStatement node) {
    _countOperator(node.forKeyword);
    _countOperator(node.leftParenthesis);
    _countOperator(node.rightParenthesis);

    // Handles both classic for-loops and for-in loops
    _incCyclomaticForCurrentMethod();

    super.visitForStatement(node);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _incCyclomaticForCurrentMethod();
    super.visitWhileStatement(node);
  }

  @override
  void visitDoStatement(DoStatement node) {
    _incCyclomaticForCurrentMethod();
    super.visitDoStatement(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    // Ternary operator (?)
    _incCyclomaticForCurrentMethod();
    super.visitConditionalExpression(node);
  }
  
  @override
  void visitTryStatement(TryStatement node) {
    // The initial try block is a point of decision
    _incCyclomaticForCurrentMethod();
    super.visitTryStatement(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    // logical &&, || increase complexity
    final op = node.operator.lexeme;
    if (op == '&&' || op == '||') {
      _incCyclomaticForCurrentMethod();
    }
    _countOperator(node.operator);
    super.visitBinaryExpression(node);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    // Correctly counts only the case clauses (decision points)
    for (var member in node.members) {
      if (member is SwitchCase) {
          _incCyclomaticForCurrentMethod();
      }
    }
    super.visitSwitchStatement(node);
  }

  @override
  void visitCatchClause(CatchClause node) {
    // Each catch clause is an alternative path
    _incCyclomaticForCurrentMethod();
    super.visitCatchClause(node);
  }

  // --- Halstead Operators continued ---
  
  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _countOperator(node.operator);
    super.visitAssignmentExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    _countOperator(node.operator);
    super.visitPrefixExpression(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _countOperator(node.operator);
    super.visitPostfixExpression(node);
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    _countOperator(node.returnKeyword);
    if (node.semicolon != null) _countOperator(node.semicolon!);
    super.visitReturnStatement(node);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    distinctOperands.add(node.value?.toString() ?? node.toSource());
    totalOperands++;
    super.visitIntegerLiteral(node);
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    distinctOperands.add(node.value?.toString() ?? node.toSource());
    totalOperands++;
    super.visitDoubleLiteral(node);
  }
}

/// -------------------- Metric Calculation Functions --------------------

// Calculates Halstead metrics from the four basic primitives
Map<String, double> calculateHalstead(int n1, int n2, int N1, int N2) {
  final n = n1 + n2;
  final N = N1 + N2;

  if (n <= 1 || N == 0 || n2 == 0) {
    return {
      'vocabulary': n.toDouble(),
      'length': N.toDouble(),
      'volume': 0.0,
      'difficulty': 0.0,
      'effort': 0.0,
      'time_seconds': 0.0,
      'predicted_bugs': 0.0,
    };
  }

  final V = N * (log(n) / ln2);
  final D = (n1 / 2.0) * (N2 / n2);
  final E = V * D;
  final T = E / 18.0;
  final B = V / 3000.0;

  // Round results to two decimal places
  return {
    'vocabulary': n.toDouble(),
    'length': N.toDouble(),
    'volume': V,
    'difficulty': D,
    'effort': E,
    'time_seconds': T,
    'predicted_bugs': B,
  }.map((key, value) => MapEntry(key, (value * 100).round() / 100));
}

// Calculates aggregated method-level metrics (Fan/LiveVars)
Map<String, double> calculateCustomMetrics() {
  final int numMethods = _methodMetrics.length;
  if (numMethods == 0) {
    return {
      'Avg Fan In': 0.0,
      'Avg Fan Out': 0.0,
      'Total Fan In': 0.0,
      'Total Fan Out': 0.0,
      'Avg Info Flow': 0.0,
      'Total Live Vars': 0.0,
      'Avg Live Vars': 0.0,
    };
  }

  final totals = _methodMetrics.values.fold<Map<String, num>>(
    {'fanIn': 0, 'fanOut': 0, 'liveVars': 0, 'infoFlow': 0},
    (acc, m) {
      final int fanIn = (m.fanIn);
      final int fanOut = (m.fanOut);
      final int live = (m.liveVariables);
      acc['fanIn'] = acc['fanIn']! + fanIn;
      acc['fanOut'] = acc['fanOut']! + fanOut;
      acc['liveVars'] = acc['liveVars']! + live;
      acc['infoFlow'] = acc['infoFlow']! + (fanIn * fanOut);
      return acc;
    },
  );

  final double totalFanIn = (totals['fanIn'] as num).toDouble();
  final double totalFanOut = (totals['fanOut'] as num).toDouble();
  final double totalLiveVars = (totals['liveVars'] as num).toDouble();
  final double totalInfoFlow = (totals['infoFlow'] as num).toDouble();

  final double avgFanIn = totalFanIn / numMethods;
  final double avgFanOut = totalFanOut / numMethods;
  final double avgInfoFlow = totalInfoFlow / numMethods;
  final double avgLiveVars = totalLiveVars / numMethods;

  return {
    'Avg Fan In': (avgFanIn * 100).round() / 100,
    'Avg Fan Out': (avgFanOut * 100).round() / 100,
    'Total Fan In': totalFanIn,
    'Total Fan Out': totalFanOut,
    'Avg Info Flow': (avgInfoFlow * 100).round() / 100,
    'Total Live Vars': totalLiveVars,
    'Avg Live Vars': (avgLiveVars * 100).round() / 100,
  };
}

// Computes CBO, DIT, LCOM, WMC for all classes found in the file
Map<String, dynamic> computeClassOopMetrics(Map<String, ClassMetrics> classes) {
  final Map<String, dynamic> out = {};

  final Map<String, String?> parentOf = {};
  for (var e in classes.entries) {
    parentOf[e.key] = e.value.extendsName;
  }

  double totalCBO = 0.0;
  double totalDIT = 0.0;
  double totalLCOM = 0.0;
  double totalWMC = 0.0;
  int classCount = classes.length;

  for (var cm in classes.values) {
    // CBO (Coupling Between Objects): number of other classes referenced
    final cbo = cm.referencedClasses.where((c) => c != cm.name).length;

    // DIT (Depth of Inheritance Tree): only walk 'extends' chain for true depth
    int dit = 0;
    var p = cm.extendsName;
    while (p != null && classes.containsKey(p)) {
      dit++;
      p = parentOf[p];
      if (dit > classes.length) break;
    }

    // WMC (Weighted Methods per Class): sum of method cyclomatic complexities
    final wmc = cm.methodCyclomatic.values.fold<int>(0, (a, b) => a + b);

    // LCOM (Lack of Cohesion in Methods): classical LCOM1 based on shared field usage
    final methodList = cm.methodFieldAccess.keys.toList();
    int M = methodList.length;
    int pairsNoShare = 0;
    int pairsShare = 0;
    for (int i = 0; i < M; i++) {
      for (int j = i + 1; j < M; j++) {
        final s1 = cm.methodFieldAccess[methodList[i]] ?? <String>{};
        final s2 = cm.methodFieldAccess[methodList[j]] ?? <String>{};
        if (s1.intersection(s2).isEmpty) {
          pairsNoShare++;
        } else {
          pairsShare++;
        }
      }
    }
    int lcom = pairsNoShare - pairsShare;
    if (lcom < 0) lcom = 0;

    out[cm.name] = {
      'CBO': cbo.toDouble(),
      'DIT': dit.toDouble(),
      'WMC': wmc.toDouble(),
      'LCOM': lcom.toDouble(),
      'methods_count': M.toDouble(),
      'fields_count': cm.declaredFields.length.toDouble(),
    };

    totalCBO += cbo;
    totalDIT += dit;
    totalLCOM += lcom;
    totalWMC += wmc;
  }

  // Provide aggregate averages for the file
  out['_AVERAGE'] = {
    'avg_CBO': classCount == 0 ? 0.0 : (totalCBO / classCount * 100).round() / 100,
    'avg_DIT': classCount == 0 ? 0.0 : (totalDIT / classCount * 100).round() / 100,
    'avg_LCOM': classCount == 0 ? 0.0 : (totalLCOM / classCount * 100).round() / 100,
    'avg_WMC': classCount == 0 ? 0.0 : (totalWMC / classCount * 100).round() / 100,
    'class_count': classCount.toDouble(),
  };

  return out;
}

/// -------------------- File analysis and CSV output --------------------

Map<String, dynamic>? analyzeFile(File file) {
  try {
    // Clear global state before processing a new file
    _methodMetrics = {};
    _classMetrics = {};

    final code = file.readAsStringSync();
    final parseResult = parseString(content: code, path: file.path);

    if (parseResult.errors.isNotEmpty) {
      stderr.writeln('Warning: syntax errors in ${file.path}, skipping.');
      return null;
    }

    final collector = MetricCollector();
    parseResult.unit.accept(collector);

    final n1 = collector.distinctOperators.length;
    final n2 = collector.distinctOperands.length;
    final N1 = collector.totalOperators;
    final N2 = collector.totalOperands;

    final halsteadMetrics = calculateHalstead(n1, n2, N1, N2);
    final customMetrics = calculateCustomMetrics();

    // compute class OOP metrics
    final classOopMetrics = computeClassOopMetrics(_classMetrics);

    final fileMetrics = <String, dynamic>{
      'file': file.path,
      'n1': n1.toDouble(),
      'n2': n2.toDouble(),
      'N1': N1.toDouble(),
      'N2': N2.toDouble(),
      ...halsteadMetrics,
      // method-level aggregates
      'avg_fan_in': customMetrics['Avg Fan In'],
      'avg_fan_out': customMetrics['Avg Fan Out'],
      'total_fan_in': customMetrics['Total Fan In'],
      'total_fan_out': customMetrics['Total Fan Out'],
      'avg_info_flow': customMetrics['Avg Info Flow'],
      'total_live_vars': customMetrics['Total Live Vars'],
      'avg_live_vars': customMetrics['Avg Live Vars'],
      // per-class metrics
      'classes': classOopMetrics,
      // counts
      'classes_count': _classMetrics.length.toDouble(),
      'methods_count': _methodMetrics.length.toDouble(),
    };

    return fileMetrics;
  } catch (e, st) {
    stderr.writeln('Failed to analyze ${file.path}: $e\n$st');
    return null;
  }
}

/// -------------------- CSV writer --------------------

void writeCsv(File outFile, List<Map<String, dynamic>> rows) {
  if (rows.isEmpty) {
    print('No rows to write.');
    return;
  }

  // Define the ordered header keys for the CSV
  final baseHeader = [
    'file',
    'n1', 'n2', 'N1', 'N2',
    'vocabulary', 'length', 'volume', 'difficulty', 'effort', 'time_seconds', 'predicted_bugs',
    'classes_count', 'methods_count',
    'avg_fan_in', 'avg_fan_out', 'total_fan_in', 'total_fan_out', 'avg_info_flow', 'total_live_vars', 'avg_live_vars',
    'avg_class_CBO', 'avg_class_DIT', 'avg_class_LCOM', 'avg_class_WMC',
    'classes_json' // Detailed class metrics encoded as JSON
  ];

  final sink = outFile.openWrite();
  sink.writeln(baseHeader.join(','));

  for (var r in rows) {
    // Extract class aggregate averages for the top-level row
    final classesMap = r['classes'] as Map<String, dynamic>?;
    double avgCBO = 0.0, avgDIT = 0.0, avgLCOM = 0.0, avgWMC = 0.0;

    if (classesMap != null && classesMap.containsKey('_AVERAGE')) {
      final avg = classesMap['_AVERAGE'] as Map<String, dynamic>;
      avgCBO = (avg['avg_CBO'] as num).toDouble();
      avgDIT = (avg['avg_DIT'] as num).toDouble();
      avgLCOM = (avg['avg_LCOM'] as num).toDouble();
      avgWMC = (avg['avg_WMC'] as num).toDouble();
    }

    final classJson = jsonEncode(r['classes'] ?? {});

    // Prepare values in the header order
    final values = [
      r['file'],
      r['n1'], r['n2'], r['N1'], r['N2'],
      r['vocabulary'], r['length'], r['volume'], r['difficulty'], r['effort'], r['time_seconds'], r['predicted_bugs'],
      r['classes_count'], r['methods_count'],
      r['avg_fan_in'], r['avg_fan_out'], r['total_fan_in'], r['total_fan_out'], r['avg_info_flow'], r['total_live_vars'], r['avg_live_vars'],
      avgCBO.toStringAsFixed(2),
      avgDIT.toStringAsFixed(2),
      avgLCOM.toStringAsFixed(2),
      avgWMC.toStringAsFixed(2),
      '"${classJson.replaceAll('"', '""')}"', // Quote and escape JSON for CSV compatibility
    ].map((v) => v.toString()).toList();

    sink.writeln(values.join(','));
  }

  sink.close();
  print('Wrote ${rows.length} rows to ${outFile.path}');
}

/// -------------------- Main --------------------

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tool/complexity_with_oop.dart <path> --csv out.csv');
    exit(2);
  }

  final target = args[0];
  final csvIndex = args.indexOf('--csv');
  final csvOut = (csvIndex >= 0 && csvIndex + 1 < args.length) ? args[csvIndex + 1] : 'complexity_report.csv';
  final dir = Directory(target);
  if (!await dir.exists()) {
    stderr.writeln('Path not found: $target');
    exit(2);
  }

  final files = <File>[];
  await for (var e in dir.list(recursive: true, followLinks: false)) {
    if (e is File && e.path.endsWith('.dart')) {
      // Exclude generated files and test files
      if (e.path.endsWith('.g.dart') || e.path.endsWith('.freezed.dart') || e.path.endsWith('_test.dart')) continue;
      files.add(e);
    }
  }

  print('Found ${files.length} dart files under $target');

  final results = <Map<String, dynamic>>[];
  for (var f in files) {
    final metrics = analyzeFile(f);
    if (metrics != null) results.add(metrics);
  }

  writeCsv(File(csvOut), results);

  print('Analysis complete.');
}