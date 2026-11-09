import 'package:adaptive_foldable/src/debug/debug_strings.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';

/// Formats a plain-text signals report suitable for copying into bug reports.
String formatSignalsReport(FoldSignals signals, {String? ruleLabel}) {
  final buffer = StringBuffer()
    ..writeln('adaptive_foldable signals:')
    ..writeln(
      '- viewSize: ${signals.viewSize.width.toStringAsFixed(1)} x ${signals.viewSize.height.toStringAsFixed(1)}',
    )
    ..writeln('- horizontalSizeClass: ${signals.horizontalSizeClass.name}')
    ..writeln('- verticalSizeClass: ${signals.verticalSizeClass.name}')
    ..writeln(
      '- verticalBarEdge: ${signals.verticalBarEdge?.name ?? DebugStrings.none}',
    )
    ..writeln('- posture: ${signals.posture.name}')
    ..writeln('- activeFolds: ${signals.activeFolds}')
    ..writeln('- occlusions: ${signals.occlusions}')
    ..writeln('- sdk271: ${signals.sdk271}')
    ..writeln('- isAvailable: ${signals.isAvailable}')
    ..writeln('- rule: ${ruleLabel ?? DebugStrings.rulePlaceholder}');
  return buffer.toString().trimRight();
}
