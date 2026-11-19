import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';

/// A screen demonstrating [FoldAlignedGrid] with crease avoidance.
class GridScreen extends StatelessWidget {
  /// Creates an instance of [GridScreen].
  const GridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fold-Aligned Grid')),
      body: FoldAlignedGrid(
        itemCount: 20,
        crossAxisCountPerPane: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final color = Colors.primaries[index % Colors.primaries.length];
          return Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.shade200, color.shade400],
                ),
              ),
              child: Center(
                child: Text(
                  'Item ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
