import 'package:adaptive_foldable/src/debug/debug_strings.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:adaptive_foldable/src/signals/signal_types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A debug overlay widget that visualizes active foldable hardware signals.
///
/// Outlines hardware folds in cyan, camera and display occlusions in amber,
/// and draws a semi-transparent HUD displaying current device posture, size classes,
/// bar edge placement, and resolved policy rule.
///
/// By default, this overlay is only active in debug builds (`kDebugMode`).
/// In profile and release builds, or when [enabled] is false, [child] is returned directly.
class FoldDebugOverlay extends StatelessWidget {
  /// Creates a [FoldDebugOverlay].
  const FoldDebugOverlay({
    super.key,
    required this.child,
    this.enabled = true,
    this.ruleLabel,
    this.isDebugMode = kDebugMode,
  });

  /// The child widget displayed underneath the overlay.
  final Widget child;

  /// Whether the overlay is enabled.
  final bool enabled;

  /// Optional label indicating which placement policy rule was executed.
  final String? ruleLabel;

  /// Whether running in debug mode. Defaults to [kDebugMode].
  ///
  /// In release builds, this is false and the overlay is completely bypassed.
  final bool isDebugMode;

  @override
  Widget build(BuildContext context) {
    if (!isDebugMode || !enabled) {
      return child;
    }

    final signals = FoldSignals.maybeOf(context);
    if (signals == null) {
      return child;
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _FoldDebugOverlayPainter(
                signals: signals,
                ruleLabel: ruleLabel ?? DebugStrings.rulePlaceholder,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FoldDebugOverlayPainter extends CustomPainter {
  const _FoldDebugOverlayPainter({
    required this.signals,
    required this.ruleLabel,
  });

  final FoldSignals signals;
  final String ruleLabel;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Paint active folds
    final foldFill = Paint()
      ..color = const Color(0x3300BCD4)
      ..style = PaintingStyle.fill;
    final foldBorder = Paint()
      ..color = const Color(0xFF00BCD4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final rect in signals.activeFolds) {
      canvas.drawRect(rect, foldFill);
      canvas.drawRect(rect, foldBorder);
    }

    // 2. Paint occlusions
    final occlusionFill = Paint()
      ..color = const Color(0x33FF9800)
      ..style = PaintingStyle.fill;
    final occlusionBorder = Paint()
      ..color = const Color(0xFFFF9800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final rect in signals.occlusions) {
      canvas.drawRect(rect, occlusionFill);
      canvas.drawRect(rect, occlusionBorder);
    }

    // 3. Paint vertical bar edge indicator strip
    final edge = signals.verticalBarEdge;
    if (edge != null && edge != NavEdge.bottom) {
      final edgePaint = Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.fill;

      if (edge == NavEdge.left || edge == NavEdge.leading) {
        canvas.drawRect(Rect.fromLTWH(0, 0, 4, size.height), edgePaint);
      } else if (edge == NavEdge.right || edge == NavEdge.trailing) {
        canvas.drawRect(
          Rect.fromLTWH(size.width - 4, 0, 4, size.height),
          edgePaint,
        );
      }
    }

    // 4. Paint HUD info card in top corner
    _paintHud(canvas, size);
  }

  void _paintHud(Canvas canvas, Size size) {
    const cardPadding = 8.0;
    const cardWidth = 220.0;
    const cardHeight = 150.0;
    const rightMargin = 12.0;
    const topMargin = 40.0;

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width - cardWidth - rightMargin,
        topMargin,
        cardWidth,
        cardHeight,
      ),
      const Radius.circular(8.0),
    );

    final bgPaint = Paint()
      ..color = const Color(0xDD121212)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFF424242)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(cardRect, bgPaint);
    canvas.drawRRect(cardRect, borderPaint);

    final lines = [
      DebugStrings.title,
      '${DebugStrings.barEdge} ${signals.verticalBarEdge?.name ?? DebugStrings.none}',
      '${DebugStrings.horizontalSizeClass} ${signals.horizontalSizeClass.name} | ${DebugStrings.verticalSizeClass} ${signals.verticalSizeClass.name}',
      '${DebugStrings.posture} ${signals.posture.name}',
      '${DebugStrings.activeFolds} ${signals.activeFolds.length} | ${DebugStrings.occlusions} ${signals.occlusions.length}',
      '${DebugStrings.sdk271} ${signals.sdk271} | ${DebugStrings.bridgeAvailable} ${signals.isAvailable}',
      '${DebugStrings.ruleFired} $ruleLabel',
    ];

    double currentY = topMargin + cardPadding;
    for (int i = 0; i < lines.length; i++) {
      final isTitle = i == 0;
      final textSpan = TextSpan(
        text: lines[i],
        style: TextStyle(
          color: isTitle ? const Color(0xFF00E5FF) : const Color(0xFFEEEEEE),
          fontSize: isTitle ? 10.0 : 9.5,
          fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: cardWidth - (cardPadding * 2));

      textPainter.paint(
        canvas,
        Offset(size.width - cardWidth - rightMargin + cardPadding, currentY),
      );
      currentY += textPainter.height + 3.0;
      textPainter.dispose();
    }
  }

  @override
  bool shouldRepaint(_FoldDebugOverlayPainter oldDelegate) {
    return oldDelegate.signals != signals || oldDelegate.ruleLabel != ruleLabel;
  }
}
