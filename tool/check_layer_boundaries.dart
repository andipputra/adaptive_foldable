import 'dart:io';

/// Represents a layer boundary violation where a pure layer file
/// imports or exports a forbidden package or module.
class Violation {
  /// File path where the violation was found.
  final String path;

  /// 1-based line number in [path].
  final int line;

  /// The URI string of the forbidden import/export directive.
  final String importUri;

  /// Explanation of why the directive violates the layer boundary.
  final String reason;

  /// Creates an instance of [Violation].
  const Violation({
    required this.path,
    required this.line,
    required this.importUri,
    required this.reason,
  });

  @override
  String toString() => '$path:$line: forbidden import "$importUri" ($reason)';
}

/// Returns true if [path] belongs to one of the pure layers (`src/policy` or `src/layout`).
bool isPureLayerFile(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.contains('src/policy/') ||
      normalized.contains('src/layout/');
}

/// Returns true if [uri] is an allowed import/export in pure layers.
bool isAllowedImport(String uri) {
  if (uri.startsWith('dart:')) {
    return true;
  }
  if (uri == 'package:flutter/foundation.dart') {
    return true;
  }
  if (uri.startsWith('package:adaptive_foldable/src/model/')) {
    return true;
  }
  if (uri == 'package:adaptive_foldable/src/signals/fold_signals.dart') {
    return true;
  }
  if (uri == 'package:adaptive_foldable/src/signals/signal_types.dart') {
    return true;
  }
  if (uri.startsWith('package:adaptive_foldable/src/policy/')) {
    return true;
  }
  if (uri.startsWith('package:adaptive_foldable/src/layout/')) {
    return true;
  }
  // Allowed relative imports (within pure layer, to model, or to fold_signals / signal_types)
  if (uri.startsWith('../model/') ||
      uri == '../signals/fold_signals.dart' ||
      uri == '../signals/signal_types.dart' ||
      uri.startsWith('../policy/') ||
      uri.startsWith('../layout/') ||
      uri.startsWith('./') ||
      (!uri.contains('/') && uri.endsWith('.dart'))) {
    return true;
  }
  return false;
}

/// Scans [sources] mapping file paths to file contents and returns all [Violation]s.
List<Violation> findViolations(Map<String, String> sources) {
  final violations = <Violation>[];
  final directiveRegex = RegExp(r'''^\s*(import|export)\s+['"]([^'"]+)['"]''');

  for (final entry in sources.entries) {
    final path = entry.key;
    if (!isPureLayerFile(path)) continue;

    final lines = entry.value.split('\n');
    bool inBlockComment = false;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      if (inBlockComment) {
        if (line.contains('*/')) {
          line = line.substring(line.indexOf('*/') + 2).trim();
          inBlockComment = false;
        } else {
          continue;
        }
      }

      if (line.startsWith('/*')) {
        if (line.contains('*/')) {
          line = line.substring(line.indexOf('*/') + 2).trim();
        } else {
          inBlockComment = true;
          continue;
        }
      }

      if (line.startsWith('//')) continue;

      final match = directiveRegex.firstMatch(line);
      if (match != null) {
        final uri = match.group(2)!;
        if (!isAllowedImport(uri)) {
          violations.add(
            Violation(
              path: path,
              line: i + 1,
              importUri: uri,
              reason:
                  'Pure layers (policy, layout) may only import dart:*, '
                  'package:flutter/foundation.dart, src/model/, '
                  'src/signals/fold_signals.dart, src/signals/signal_types.dart, '
                  'or each other.',
            ),
          );
        }
      }
    }
  }

  return violations;
}

/// CLI entry point scanning packages/adaptive_foldable/lib/src for violations.
void main(List<String> args) {
  final rootDir = Directory.current;
  final sources = <String, String>{};

  final searchDirs = [
    Directory('${rootDir.path}/packages/adaptive_foldable/lib/src/policy'),
    Directory('${rootDir.path}/packages/adaptive_foldable/lib/src/layout'),
  ];

  for (final dir in searchDirs) {
    if (dir.existsSync()) {
      for (final file in dir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.dart')) {
          sources[file.path] = file.readAsStringSync();
        }
      }
    }
  }

  final violations = findViolations(sources);

  if (violations.isNotEmpty) {
    for (final v in violations) {
      stderr.writeln('${v.path}:${v.line}: forbidden import "${v.importUri}"');
    }
    exitCode = 1;
  } else {
    stdout.writeln(
      'Layer boundaries clean: no forbidden imports in policy/layout.',
    );
    exitCode = 0;
  }
}
