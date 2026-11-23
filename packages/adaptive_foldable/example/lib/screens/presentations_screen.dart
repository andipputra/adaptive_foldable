// ignore_for_file: deprecated_member_use -- cupertino.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable_example/widgets/example_page.dart';
import 'package:flutter/cupertino.dart';

/// A screen demonstrating [showFoldAwareDialog] and [showFoldAwareModalBottomSheet].
class PresentationsScreen extends StatelessWidget {
  /// Creates an instance of [PresentationsScreen].
  const PresentationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScrollPage(
      title: 'Modals & Anchoring',
      slivers: [
        SliverToBoxAdapter(
          child: CupertinoListSection.insetGrouped(
            header: const Text('Fold-aware dialogs'),
            footer: const Text('Anchored to one side of an active fold.'),
            children: [
              for (final target in FoldPaneTarget.values)
                CupertinoListTile.notched(
                  leading: const Icon(CupertinoIcons.chat_bubble_text),
                  title: Text('Dialog: ${_label(target)}'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _openDialog(context, target),
                ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: CupertinoListSection.insetGrouped(
            header: const Text('Fold-aware bottom sheets'),
            children: [
              for (final target in FoldPaneTarget.values)
                CupertinoListTile.notched(
                  leading: const Icon(CupertinoIcons.rectangle_split_3x1),
                  title: Text('Sheet: ${_label(target)}'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _openSheet(context, target),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _label(FoldPaneTarget target) => switch (target) {
    FoldPaneTarget.auto => 'Auto anchor',
    FoldPaneTarget.start => 'Start pane',
    FoldPaneTarget.end => 'End pane',
  };

  void _openDialog(BuildContext context, FoldPaneTarget target) {
    showFoldAwareDialog(
      context: context,
      target: target,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: Text('Anchored dialog (${target.name})'),
        content: Text(
          'Anchored to the ${target.name} pane, clear of any active vertical fold.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _openSheet(BuildContext context, FoldPaneTarget target) {
    showFoldAwareModalBottomSheet(
      context: context,
      target: target,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Anchored bottom sheet (${target.name})',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Anchored to the ${target.name} pane, avoiding the hinge crease.',
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: () => Navigator.pop(sheetCtx),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
