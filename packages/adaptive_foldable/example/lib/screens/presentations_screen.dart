// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable_example/widgets/example_page.dart';
import 'package:flutter/material.dart';

/// A screen demonstrating [showFoldAwareDialog] and [showFoldAwareModalBottomSheet].
///
/// Wide enough, it shows two panes; each modal is limited to one pane and the
/// other pane stays interactive. Narrow, one pane shows and modals cover the screen.
class PresentationsScreen extends StatelessWidget {
  /// Creates an instance of [PresentationsScreen].
  const PresentationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Mirrors FoldAwareTwoPane's default minimums (280 + 320).
          final fits = constraints.maxWidth >= 600;
          return FoldAwareTwoPane(
            priority: fits ? TwoPanePriority.both : TwoPanePriority.start,
            start: const _PanePage(title: 'Start pane'),
            end: const _PanePage(title: 'End pane'),
          );
        },
      ),
    );
  }
}

class _PanePage extends StatefulWidget {
  const _PanePage({required this.title});

  final String title;

  @override
  State<_PanePage> createState() => _PanePageState();
}

class _PanePageState extends State<_PanePage> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    return ExampleScrollPage(
      title: widget.title,
      slivers: [
        SliverToBoxAdapter(
          child: ExampleSection(
            header: const Text('Fold-aware dialogs'),
            footer: const Text(
              'Auto opens in this pane; the other pane stays usable.',
            ),
            children: [
              for (final target in FoldPaneTarget.values)
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text('Dialog: ${_label(target)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openDialog(context, target),
                ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: ExampleSection(
            header: const Text('Fold-aware bottom sheets'),
            children: [
              for (final target in FoldPaneTarget.values)
                ListTile(
                  leading: const Icon(Icons.view_agenda_outlined),
                  title: Text('Sheet: ${_label(target)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openSheet(context, target),
                ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: ExampleSection(
            header: const Text('Interaction check'),
            children: [
              ListTile(
                leading: const Icon(Icons.touch_app_outlined),
                title: const Text('Tap me while a modal is open'),
                subtitle: Text('Taps in ${widget.title}: $_taps'),
                onTap: () => setState(() => _taps++),
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
      builder: (dialogCtx) => AlertDialog(
        title: Text('Anchored dialog (${target.name})'),
        content: Text(
          'Anchored to the ${target.name} pane, clear of any active vertical fold.',
        ),
        actions: [
          TextButton(
            onPressed: () => closeFoldAwareModal(dialogCtx),
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
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Anchored to the ${target.name} pane, avoiding the hinge crease.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => closeFoldAwareModal(sheetCtx),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
