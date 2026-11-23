// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable_example/widgets/example_page.dart';
import 'package:flutter/material.dart';

/// Item data model for the two-pane example.
class DocumentItem {
  /// Creates a document item.
  const DocumentItem({
    required this.id,
    required this.title,
    required this.date,
    required this.content,
  });

  /// Unique identifier.
  final String id;

  /// Document title.
  final String title;

  /// Last modified date string.
  final String date;

  /// Body content.
  final String content;
}

const sampleDocuments = [
  DocumentItem(
    id: 'doc-1',
    title: 'Technical Design Overview',
    date: '2026-11-17',
    content:
        'The adaptive_foldable package provides a design-agnostic navigation scaffold '
        'with a complete fold kit supporting two-pane splits, crease-avoiding grids, '
        'and anchored dialogs.',
  ),
  DocumentItem(
    id: 'doc-2',
    title: 'Hinge and Fold Postures',
    date: '2026-11-16',
    content:
        'Foldable devices report postures such as closed, partiallyOpen (book, tabletop), '
        'and fullyOpen. Navigation bars dynamically reposition to stay clear of hinges.',
  ),
  DocumentItem(
    id: 'doc-3',
    title: 'Action Assignment Strategy',
    date: '2026-11-15',
    content:
        'In two-pane layouts, the pane physically adjacent to the side navigation column '
        'feeds column actions, while other panes render horizontal header bars.',
  ),
  DocumentItem(
    id: 'doc-4',
    title: 'State Preservation Rules',
    date: '2026-11-14',
    content:
        'When transitioning between compact and expanded widths, offscreen panes retain '
        'their scroll offsets and input states using a stable non-reparenting Stack.',
  ),
];

/// A screen demonstrating [FoldAwareTwoPane] with per-pane actions.
class TwoPaneScreen extends StatefulWidget {
  /// Creates an instance of [TwoPaneScreen].
  const TwoPaneScreen({super.key});

  @override
  State<TwoPaneScreen> createState() => _TwoPaneScreenState();
}

class _TwoPaneScreenState extends State<TwoPaneScreen> {
  int _selectedIndex = 0;

  // Starts list-only; selecting an item switches to both panes when they fit.
  TwoPanePriority _priority = TwoPanePriority.start;
  bool _selected = false;
  bool _fits = true;

  @override
  Widget build(BuildContext context) {
    final selectedDoc = sampleDocuments[_selectedIndex];

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Mirrors FoldAwareTwoPane's default minimums (280 + 320).
          _fits = constraints.maxWidth >= 600;
          // Before a selection show the list only; afterwards show both panes,
          // or the detail alone when they do not fit.
          final priority = !_selected
              ? TwoPanePriority.start
              : _fits
              ? TwoPanePriority.both
              : _priority;
          return FoldAwareTwoPane(
            priority: priority,
            start: _buildListPane(context),
            end: _buildDetailPane(context, selectedDoc),
          );
        },
      ),
    );
  }

  Widget _buildListPane(BuildContext context) {
    return AdaptiveNavActions(
      groups: [
        NavActionGroup([
          NavAction(
            icon: Icons.filter_list,
            sfSymbol: 'line.3.horizontal.decrease',
            label: 'Filter',
            onPressed: () {},
          ),
        ]),
      ],
      child: Column(
        children: [
          NavPaneHeaderBar(
            title: const Text('Documents'),
            leading: const Icon(Icons.folder_outlined),
          ),
          Expanded(
            child: ListView(
              key: const PageStorageKey('two_pane_list'),
              children: [
                ExampleSection(
                  children: [
                    for (var i = 0; i < sampleDocuments.length; i++)
                      ListTile(
                        selected: i == _selectedIndex,
                        title: Text(sampleDocuments[i].title),
                        subtitle: Text(sampleDocuments[i].date),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => setState(() {
                          _selectedIndex = i;
                          _selected = true;
                          _priority = TwoPanePriority.end;
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPane(BuildContext context, DocumentItem doc) {
    return AdaptiveNavActions(
      prominentAction: NavAction(
        icon: Icons.edit_outlined,
        sfSymbol: 'pencil',
        label: 'Edit',
        onPressed: () {},
      ),
      groups: [
        NavActionGroup([
          NavAction(
            icon: Icons.share,
            sfSymbol: 'square.and.arrow.up',
            label: 'Share',
            onPressed: () {},
          ),
          NavAction(
            icon: Icons.archive_outlined,
            sfSymbol: 'archivebox',
            label: 'Archive',
            onPressed: () {},
          ),
        ]),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavPaneHeaderBar(
            title: Text(doc.title),
            leading: IconButton(
              tooltip: 'Back to documents',
              onPressed: () => setState(() {
                _priority = TwoPanePriority.start;
                _selected = false;
              }),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updated ${doc.date}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  Text(
                    doc.content,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
