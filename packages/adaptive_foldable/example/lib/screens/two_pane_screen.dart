// ignore_for_file: deprecated_member_use -- cupertino.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/cupertino.dart';

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
  TwoPanePriority _priority = TwoPanePriority.both;

  @override
  Widget build(BuildContext context) {
    final selectedDoc = sampleDocuments[_selectedIndex];

    return ColoredBox(
      color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      child: FoldAwareTwoPane(
        priority: _priority,
        start: _buildListPane(context),
        end: _buildDetailPane(context, selectedDoc),
      ),
    );
  }

  Widget _buildListPane(BuildContext context) {
    return AdaptiveNavActions(
      groups: [
        NavActionGroup([
          NavAction(
            icon: CupertinoIcons.line_horizontal_3_decrease,
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
            leading: const Icon(CupertinoIcons.folder),
          ),
          Expanded(
            child: ListView(
              key: const PageStorageKey('two_pane_list'),
              children: [
                CupertinoListSection.insetGrouped(
                  children: [
                    for (var i = 0; i < sampleDocuments.length; i++)
                      CupertinoListTile.notched(
                        backgroundColor: i == _selectedIndex
                            ? CupertinoColors.systemBlue
                                  .resolveFrom(context)
                                  .withValues(alpha: 0.12)
                            : null,
                        title: Text(sampleDocuments[i].title),
                        subtitle: Text(sampleDocuments[i].date),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () => setState(() {
                          _selectedIndex = i;
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
        icon: CupertinoIcons.pencil,
        sfSymbol: 'pencil',
        label: 'Edit',
        onPressed: () {},
      ),
      groups: [
        NavActionGroup([
          NavAction(
            icon: CupertinoIcons.share,
            sfSymbol: 'square.and.arrow.up',
            label: 'Share',
            onPressed: () {},
          ),
          NavAction(
            icon: CupertinoIcons.archivebox,
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
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size.square(44),
              onPressed: () =>
                  setState(() => _priority = TwoPanePriority.start),
              child: const Icon(
                CupertinoIcons.back,
                semanticLabel: 'Back to documents',
              ),
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
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .navLargeTitleTextStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updated ${doc.date}',
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .tabLabelTextStyle,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  Text(
                    doc.content,
                    style: CupertinoTheme.of(context).textTheme.textStyle
                        .copyWith(height: 1.4),
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
