// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
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
      home: const ExampleShell(),
    );
  }
}

/// Example shell: an [AdaptiveNavScaffold] around the signals page.
class ExampleShell extends StatefulWidget {
  /// Creates an instance of [ExampleShell].
  const ExampleShell({super.key});

  @override
  State<ExampleShell> createState() => _ExampleShellState();
}

class _ExampleShellState extends State<ExampleShell> {
  int _index = 0;
  String _lastEvent = 'none';

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavScaffold(
      destinations: const [
        NavDestination(icon: Icons.home_outlined, label: 'Home'),
        NavDestination(
          icon: Icons.inbox_outlined,
          label: 'Inbox',
          badgeCount: 7,
        ),
        NavDestination(icon: Icons.person_outline, label: 'Me'),
      ],
      selectedIndex: _index,
      onSelected: (i) => setState(() => _index = i),
      debugOverlay: true,
      onLayoutChanged: (previous, next) => setState(
        () => _lastEvent =
            '${previous.placement.edge.name} -> ${next.placement.edge.name}',
      ),
      body: ExampleHomePage(lastLayoutEvent: _lastEvent),
    );
  }
}

/// Example home page displaying resolved platform signals.
class ExampleHomePage extends StatefulWidget {
  /// Creates an instance of [ExampleHomePage].
  const ExampleHomePage({super.key, this.lastLayoutEvent = 'none'});

  /// Last placement change reported by `onLayoutChanged`.
  final String lastLayoutEvent;

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
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
            Text('Layout change: ${widget.lastLayoutEvent}'),
          ],
        ),
      ),
    );
  }
}
