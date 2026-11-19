import 'package:adaptive_foldable/src/layout/actions_fade.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opacity is a pure function of the animation value', () {
    expect(actionsFade(0), const ActionsFade(showIncoming: false, opacity: 1));
    expect(
      actionsFade(0.25),
      const ActionsFade(showIncoming: false, opacity: 0.5),
    );
    expect(actionsFade(0.5), const ActionsFade(showIncoming: true, opacity: 0));
    expect(
      actionsFade(0.75),
      const ActionsFade(showIncoming: true, opacity: 0.5),
    );
    expect(actionsFade(1), const ActionsFade(showIncoming: true, opacity: 1));
  });

  test('values outside 0..1 and NaN are clamped', () {
    expect(actionsFade(-3).showIncoming, isFalse);
    expect(actionsFade(7), const ActionsFade(showIncoming: true, opacity: 1));
    expect(actionsFade(double.nan).opacity, 1);
  });

  test('is symmetric: a cancelled swipe retraces the same values', () {
    for (final t in [0.1, 0.3, 0.45, 0.6, 0.9]) {
      expect(actionsFade(t), actionsFade(t));
    }
  });

  test('reduce motion swaps instantly at halfway with full opacity', () {
    expect(
      actionsFade(0.2, reduceMotion: true),
      const ActionsFade(showIncoming: false, opacity: 1),
    );
    expect(
      actionsFade(0.7, reduceMotion: true),
      const ActionsFade(showIncoming: true, opacity: 1),
    );
  });
}
