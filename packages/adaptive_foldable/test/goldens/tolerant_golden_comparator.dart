import 'dart:typed_data';

import 'package:flutter/widgets.dart' show FlutterError;
import 'package:flutter_test/flutter_test.dart';

/// Largest share of differing pixels accepted by [useTolerantGoldens].
///
/// Anti-aliasing differs by a few pixels between macOS machines and CI runners;
/// a layout or colour regression changes orders of magnitude more.
const double kGoldenTolerance = 0.005;

/// Compares goldens with a [kGoldenTolerance] pixel-diff allowance for the current test file.
void useTolerantGoldens() {
  final base = goldenFileComparator;
  if (base is! LocalFileComparator) return;
  goldenFileComparator = _TolerantComparator(base.basedir.resolve('x.dart'));
}

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= kGoldenTolerance * 100) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
