import 'dart:ui' show Size;

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const c = MaterialSizeClass.compact;
  const m = MaterialSizeClass.medium;
  const e = MaterialSizeClass.expanded;

  test('width boundaries', () {
    expect(MaterialWindowSize.classifyWidth(0), c);
    expect(MaterialWindowSize.classifyWidth(599.9), c);
    expect(MaterialWindowSize.classifyWidth(600), m);
    expect(MaterialWindowSize.classifyWidth(839.9), m);
    expect(MaterialWindowSize.classifyWidth(840), e);
  });

  test('height boundaries', () {
    expect(MaterialWindowSize.classifyHeight(0), c);
    expect(MaterialWindowSize.classifyHeight(479.9), c);
    expect(MaterialWindowSize.classifyHeight(480), m);
    expect(MaterialWindowSize.classifyHeight(899.9), m);
    expect(MaterialWindowSize.classifyHeight(900), e);
  });

  test('fromSize combines both axes for foldable and split-screen windows', () {
    expect(
      MaterialWindowSize.fromSize(const Size(360, 800)),
      const MaterialWindowSize(c, m),
    );
    expect(
      MaterialWindowSize.fromSize(const Size(884, 1104)),
      const MaterialWindowSize(e, e),
    );
    expect(
      MaterialWindowSize.fromSize(const Size(442, 1104)),
      const MaterialWindowSize(c, e),
    );
    expect(
      MaterialWindowSize.fromSize(Size.zero),
      const MaterialWindowSize(c, c),
    );
  });

  test('value equality', () {
    expect(const MaterialWindowSize(c, m), const MaterialWindowSize(c, m));
    expect(
      const MaterialWindowSize(c, m) == const MaterialWindowSize(m, m),
      isFalse,
    );
  });
}
