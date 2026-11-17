// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:flutter_test/flutter_test.dart';

import '../check_layer_boundaries.dart';

void main() {
  group('check_layer_boundaries', () {
    test('isPureLayerFile identifies policy and layout files', () {
      expect(
        isPureLayerFile(
          'packages/adaptive_foldable/lib/src/policy/apple_policy.dart',
        ),
        isTrue,
      );
      expect(
        isPureLayerFile(
          'packages/adaptive_foldable/lib/src/layout/nav_layout.dart',
        ),
        isTrue,
      );
      expect(
        isPureLayerFile(
          'packages/adaptive_foldable/lib/src/signals/fold_signals.dart',
        ),
        isFalse,
      );
      expect(
        isPureLayerFile(
          'packages/adaptive_foldable/lib/src/scaffold/scaffold.dart',
        ),
        isFalse,
      );
    });

    test('isAllowedImport permits allowed imports', () {
      expect(isAllowedImport('dart:math'), isTrue);
      expect(isAllowedImport('dart:ui'), isTrue);
      expect(isAllowedImport('package:flutter/foundation.dart'), isTrue);
      expect(
        isAllowedImport(
          'package:adaptive_foldable/src/model/nav_geometry.dart',
        ),
        isTrue,
      );
      expect(
        isAllowedImport(
          'package:adaptive_foldable/src/signals/fold_signals.dart',
        ),
        isTrue,
      );
      expect(
        isAllowedImport(
          'package:adaptive_foldable/src/signals/signal_types.dart',
        ),
        isTrue,
      );
      expect(
        isAllowedImport(
          'package:adaptive_foldable/src/policy/apple_policy.dart',
        ),
        isTrue,
      );
      expect(
        isAllowedImport('package:adaptive_foldable/src/layout/nav_layout.dart'),
        isTrue,
      );
      expect(isAllowedImport('../model/nav_geometry.dart'), isTrue);
      expect(isAllowedImport('../signals/fold_signals.dart'), isTrue);
      expect(isAllowedImport('../signals/signal_types.dart'), isTrue);
    });

    test('isAllowedImport rejects forbidden imports', () {
      expect(isAllowedImport('package:flutter/widgets.dart'), isFalse);
      expect(isAllowedImport('package:flutter/material.dart'), isFalse);
      expect(isAllowedImport('package:flutter/cupertino.dart'), isFalse);
      expect(isAllowedImport('package:flutter/services.dart'), isFalse);
      expect(
        isAllowedImport(
          'package:adaptive_foldable/src/signals/ios_fold_signals.dart',
        ),
        isFalse,
      );
      expect(
        isAllowedImport(
          'package:adaptive_foldable/src/signals/android_fold_signals.dart',
        ),
        isFalse,
      );
      expect(
        isAllowedImport('package:adaptive_foldable/src/scaffold/scaffold.dart'),
        isFalse,
      );
      expect(
        isAllowedImport('package:adaptive_foldable/src/bars/default_bar.dart'),
        isFalse,
      );
      expect(
        isAllowedImport('package:adaptive_foldable/src/fold_kit/two_pane.dart'),
        isFalse,
      );
    });

    test('findViolations reports forbidden imports in pure layer files', () {
      final sources = {
        'lib/src/policy/my_policy.dart': '''
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
''',
        'lib/src/layout/my_layout.dart': '''
import 'package:flutter/material.dart';
import 'package:adaptive_foldable/src/signals/ios_fold_signals.dart';
''',
      };

      final violations = findViolations(sources);
      expect(violations.length, 3);
      expect(violations[0].path, 'lib/src/policy/my_policy.dart');
      expect(violations[0].line, 3);
      expect(violations[0].importUri, 'package:flutter/widgets.dart');

      expect(violations[1].path, 'lib/src/layout/my_layout.dart');
      expect(violations[1].line, 1);
      expect(violations[1].importUri, 'package:flutter/material.dart');

      expect(violations[2].path, 'lib/src/layout/my_layout.dart');
      expect(violations[2].line, 2);
      expect(
        violations[2].importUri,
        'package:adaptive_foldable/src/signals/ios_fold_signals.dart',
      );
    });

    test('findViolations ignores non-pure layer files', () {
      final sources = {
        'lib/src/signals/ios_fold_signals.dart': '''
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
''',
        'lib/src/scaffold/scaffold.dart': '''
import 'package:flutter/material.dart';
''',
      };

      final violations = findViolations(sources);
      expect(violations, isEmpty);
    });

    test('findViolations ignores commented imports', () {
      final sources = {
        'lib/src/policy/my_policy.dart': '''
// import 'package:flutter/widgets.dart';
/// import 'package:flutter/material.dart';
/*
import 'package:flutter/cupertino.dart';
*/
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
''',
      };

      final violations = findViolations(sources);
      expect(violations, isEmpty);
    });

    test('findViolations detects forbidden export directives', () {
      final sources = {
        'lib/src/policy/my_policy.dart': '''
export 'package:flutter/widgets.dart';
''',
      };

      final violations = findViolations(sources);
      expect(violations.length, 1);
      expect(violations.first.importUri, 'package:flutter/widgets.dart');
    });

    test('model files may import only IconData from widgets.dart', () {
      const model = 'packages/adaptive_foldable/lib/src/model/nav_action.dart';
      expect(
        findViolations({
          model: "import 'package:flutter/widgets.dart' show IconData;",
        }),
        isEmpty,
      );
      expect(
        findViolations({model: "import 'package:flutter/widgets.dart';"}),
        hasLength(1),
      );
      expect(
        findViolations({
          model: "import 'package:flutter/widgets.dart' show Widget;",
        }),
        hasLength(1),
      );
      expect(
        findViolations({
          'packages/adaptive_foldable/lib/src/policy/p.dart':
              "import 'package:flutter/widgets.dart' show IconData;",
        }),
        hasLength(1),
      );
    });

    test('IconData allowance survives line wrapping and ignores comments', () {
      const model = 'packages/adaptive_foldable/lib/src/model/nav_action.dart';
      expect(
        findViolations({
          model: "import 'package:flutter/widgets.dart'\n    show IconData;",
        }),
        isEmpty,
      );
      expect(
        findViolations({
          model: "import 'package:flutter/widgets.dart'; // show IconData;",
        }),
        hasLength(1),
      );
    });
  });
}
