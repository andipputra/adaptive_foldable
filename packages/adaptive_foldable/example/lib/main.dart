import 'dart:async';

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

/// Example application entry widget.
class MyApp extends StatefulWidget {
  /// Creates an instance of [MyApp].
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _eventChannel = EventChannel(
    'dev.adaptivefoldable/signals/events',
  );
  static const _methodChannel = MethodChannel('dev.adaptivefoldable/signals');

  String _status = 'Listening for signals...';
  Map<dynamic, dynamic>? _lastPayload;
  StreamSubscription<dynamic>? _subscription;

  @override
  void initState() {
    super.initState();
    _initSignals();
  }

  Future<void> _initSignals() async {
    try {
      final initial = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getSignals',
      );
      if (mounted) {
        setState(() {
          _lastPayload = initial;
          _status = 'Initial payload received';
        });
      }
    } catch (e) {
      debugPrint('Error reading initial signals: $e');
    }

    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (mounted && event is Map) {
          setState(() {
            _lastPayload = event;
            _status = 'Signal event received';
          });
          debugPrint('AdaptiveFoldable signal event: $event');
        }
      },
      onError: (dynamic error) {
        debugPrint('AdaptiveFoldable signal stream error: $error');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Adaptive Foldable Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adaptive Foldable: $adaptiveFoldableVersion'),
              const SizedBox(height: 8),
              Text('Status: $_status'),
              const SizedBox(height: 16),
              if (_lastPayload != null) ...[
                Text(
                  'Horizontal Size: ${_lastPayload!['horizontalSizeClass']}',
                ),
                Text('Vertical Size: ${_lastPayload!['verticalSizeClass']}'),
                Text('Bar Edge: ${_lastPayload!['verticalBarEdge']}'),
                Text('SDK 27.1: ${_lastPayload!['sdk271']}'),
                Text('Available: ${_lastPayload!['isAvailable']}'),
              ] else
                const Text('Waiting for platform signals...'),
            ],
          ),
        ),
      ),
    );
  }
}
