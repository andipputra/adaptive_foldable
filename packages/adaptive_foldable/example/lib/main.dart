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
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Adaptive Foldable Example: $adaptiveFoldableVersion'),
        ),
      ),
    );
  }
}
