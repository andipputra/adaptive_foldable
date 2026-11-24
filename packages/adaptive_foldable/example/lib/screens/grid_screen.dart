// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable_example/widgets/example_page.dart';
import 'package:flutter/material.dart';

const _tints = [
  Colors.blue,
  Colors.indigo,
  Colors.teal,
  Colors.orange,
  Colors.pink,
  Colors.green,
];

/// A screen demonstrating [FoldAlignedGrid] with crease avoidance.
class GridScreen extends StatelessWidget {
  /// Creates an instance of [GridScreen].
  const GridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleFixedPage(
      title: 'Fold-Aligned Grid',
      child: FoldAlignedGrid(
        itemCount: 20,
        crossAxisCountPerPane: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemBuilder: (context, index) {
          final tint = _tints[index % _tints.length];
          return DecoratedBox(
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.grid_view, color: tint),
                  const SizedBox(height: 8),
                  Text(
                    'Item ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
