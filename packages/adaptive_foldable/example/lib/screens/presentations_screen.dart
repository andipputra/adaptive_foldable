import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';

/// A screen demonstrating [showFoldAwareDialog] and [showFoldAwareModalBottomSheet].
class PresentationsScreen extends StatelessWidget {
  /// Creates an instance of [PresentationsScreen].
  const PresentationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modals & Anchoring')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Fold-Aware Dialogs',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => _openDialog(context, FoldPaneTarget.auto),
                child: const Text('Open Dialog (Auto Anchor)'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => _openDialog(context, FoldPaneTarget.start),
                child: const Text('Open Dialog (Start Pane)'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => _openDialog(context, FoldPaneTarget.end),
                child: const Text('Open Dialog (End Pane)'),
              ),
              const SizedBox(height: 32),
              Text(
                'Fold-Aware Bottom Sheets',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _openSheet(context, FoldPaneTarget.auto),
                child: const Text('Open Bottom Sheet (Auto Anchor)'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _openSheet(context, FoldPaneTarget.start),
                child: const Text('Open Bottom Sheet (Start Pane)'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _openSheet(context, FoldPaneTarget.end),
                child: const Text('Open Bottom Sheet (End Pane)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDialog(BuildContext context, FoldPaneTarget target) {
    showFoldAwareDialog(
      context: context,
      target: target,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text('Anchored Dialog (${target.name})'),
          content: Text(
            'This dialog is anchored to the ${target.name} pane, keeping clear '
            'of any active vertical fold.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );
  }

  void _openSheet(BuildContext context, FoldPaneTarget target) {
    showFoldAwareModalBottomSheet(
      context: context,
      target: target,
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Anchored Bottom Sheet (${target.name})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'The surface of this bottom sheet is anchored strictly to '
                  'the ${target.name} pane, avoiding the center hinge crease.',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
