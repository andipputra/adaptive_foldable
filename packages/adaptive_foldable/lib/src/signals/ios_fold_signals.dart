import 'dart:async';

import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:adaptive_foldable/src/signals/signal_types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS implementation of [FoldSignals] communicating over platform channels.
class IosFoldSignals extends ChangeNotifier implements FoldSignals {
  IosFoldSignals._({MethodChannel? methodChannel, EventChannel? eventChannel})
    : _methodChannel =
          methodChannel ?? const MethodChannel('dev.adaptivefoldable/signals'),
      _eventChannel =
          eventChannel ??
          const EventChannel('dev.adaptivefoldable/signals/events') {
    _init();
  }

  static IosFoldSignals? _instance;

  /// Returns the singleton instance of [IosFoldSignals].
  static IosFoldSignals get instance => _instance ??= IosFoldSignals._();

  /// Visible for testing: sets custom channels or resets instance.
  @visibleForTesting
  static void setInstanceForTesting(IosFoldSignals? testInstance) {
    _instance = testInstance;
  }

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  StreamSubscription<dynamic>? _subscription;

  FoldSignalsSnapshot _snapshot = const FoldSignalsSnapshot.empty();

  /// The current decoded signals snapshot.
  FoldSignalsSnapshot get snapshot => _snapshot;

  @override
  NavEdge? get verticalBarEdge => _snapshot.verticalBarEdge;

  @override
  SizeClass get horizontalSizeClass => _snapshot.horizontalSizeClass;

  @override
  SizeClass get verticalSizeClass => _snapshot.verticalSizeClass;

  @override
  Size get viewSize => _snapshot.viewSize;

  @override
  List<Rect> get activeFolds => _snapshot.activeFolds;

  @override
  List<Rect> get occlusions => _snapshot.occlusions;

  @override
  Posture get posture => _snapshot.posture;

  @override
  bool get isAvailable => _snapshot.isAvailable;

  @override
  bool get sdk271 => _snapshot.sdk271;

  void _init() {
    _fetchInitial();
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          _updateWithPayload(event);
        }
      },
      onError: (Object error) {
        debugPrint('adaptive_foldable: signal stream error: $error');
      },
    );
  }

  Future<void> _fetchInitial() async {
    try {
      final initial = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getSignals',
      );
      if (initial != null) {
        _updateWithPayload(initial);
      }
    } on MissingPluginException {
      // No native bridge registered (for example in unit tests): stay unavailable.
    } on PlatformException catch (error) {
      debugPrint('adaptive_foldable: getSignals failed: $error');
    }
  }

  void _updateWithPayload(Map<dynamic, dynamic> payload) {
    final newSnapshot = decodePayload(payload);
    if (newSnapshot != _snapshot) {
      _snapshot = newSnapshot;
      notifyListeners();
    }
  }

  static double _asDouble(Object? value) => value is num ? value.toDouble() : 0;

  /// Decodes a raw payload map from the iOS bridge into a [FoldSignalsSnapshot].
  static FoldSignalsSnapshot decodePayload(Map<dynamic, dynamic>? payload) {
    if (payload == null) {
      return const FoldSignalsSnapshot.empty();
    }

    final rawViewSize = payload['viewSize'];
    Size viewSize = Size.zero;
    if (rawViewSize is Map) {
      viewSize = Size(
        _asDouble(rawViewSize['width']),
        _asDouble(rawViewSize['height']),
      );
    }

    final hSize = switch (payload['horizontalSizeClass']) {
      'compact' => SizeClass.compact,
      'regular' => SizeClass.regular,
      _ => SizeClass.unknown,
    };

    final vSize = switch (payload['verticalSizeClass']) {
      'compact' => SizeClass.compact,
      'regular' => SizeClass.regular,
      _ => SizeClass.unknown,
    };

    final barEdge = switch (payload['verticalBarEdge']) {
      'left' => NavEdge.left,
      'right' => NavEdge.right,
      _ => null,
    };

    final posture = switch (payload['posture']) {
      'closed' => Posture.closed,
      'partiallyOpen' => Posture.partiallyOpen,
      'fullyOpen' => Posture.fullyOpen,
      _ => Posture.unknown,
    };

    List<Rect> parseRects(dynamic list) {
      if (list is! List) return const [];
      final result = <Rect>[];
      for (final item in list) {
        if (item is Map) {
          final x = _asDouble(item['x']);
          final y = _asDouble(item['y']);
          final w = _asDouble(item['width']);
          final h = _asDouble(item['height']);
          if (w > 0 && h > 0) {
            result.add(Rect.fromLTWH(x, y, w, h));
          }
        }
      }
      return result;
    }

    final activeFolds = parseRects(payload['activeFolds']);
    final occlusions = parseRects(payload['occlusions']);
    final rawAvailable = payload['isAvailable'];
    final isAvailable = rawAvailable is bool && rawAvailable;
    final rawSdk271 = payload['sdk271'];
    final sdk271 = rawSdk271 is bool && rawSdk271;

    return FoldSignalsSnapshot(
      verticalBarEdge: barEdge,
      horizontalSizeClass: hSize,
      verticalSizeClass: vSize,
      viewSize: viewSize,
      activeFolds: activeFolds,
      occlusions: occlusions,
      posture: posture,
      isAvailable: isAvailable,
      sdk271: sdk271,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
