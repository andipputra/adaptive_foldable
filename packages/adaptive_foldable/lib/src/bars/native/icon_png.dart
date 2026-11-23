import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Renders [icon] as a square black PNG of [size] logical pixels at [scale], for use as an iOS template image.
Future<List<int>> renderIconPng(
  IconData icon, {
  double size = 25,
  double scale = 3,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(scale);
  final painter = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: const Color(0xFF000000),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(
    canvas,
    Offset((size - painter.width) / 2, (size - painter.height) / 2),
  );
  final image = await recorder.endRecording().toImage(
    (size * scale).ceil(),
    (size * scale).ceil(),
  );
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}
