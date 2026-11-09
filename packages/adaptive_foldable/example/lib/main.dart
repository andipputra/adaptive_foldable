import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Example application entry widget.
class MyApp extends StatelessWidget {
  /// Creates an instance of [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => FoldSignalsScope(child: child!),
      home: const ExampleHomePage(),
    );
  }
}

/// Example home page displaying resolved platform signals.
class ExampleHomePage extends StatelessWidget {
  /// Creates an instance of [ExampleHomePage].
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final signals = FoldSignals.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Adaptive Foldable Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adaptive Foldable: $adaptiveFoldableVersion'),
            const SizedBox(height: 16),
            Text('Horizontal Size: ${signals.horizontalSizeClass.name}'),
            Text('Vertical Size: ${signals.verticalSizeClass.name}'),
            Text('Bar Edge: ${signals.verticalBarEdge?.name ?? "none"}'),
            Text('Posture: ${signals.posture.name}'),
            Text('Active Folds: ${signals.activeFolds.length}'),
            Text('Occlusions: ${signals.occlusions.length}'),
            Text('SDK 27.1: ${signals.sdk271}'),
            Text('Available: ${signals.isAvailable}'),
          ],
        ),
      ),
    );
  }
}
