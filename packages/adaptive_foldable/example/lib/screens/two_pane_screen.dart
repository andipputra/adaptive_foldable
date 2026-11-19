// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
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
  TwoPanePriority _priority = TwoPanePriority.both;

  @override
  Widget build(BuildContext context) {
    final selectedDoc = sampleDocuments[_selectedIndex];

    return Scaffold(
      body: FoldAwareTwoPane(
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
          NavAction(icon: Icons.filter_list, label: 'Filter', onPressed: () {}),
        ]),
      ],
      child: Column(
        children: [
          NavPaneHeaderBar(
            title: const Text('Documents'),
            leading: const Icon(Icons.folder_outlined),
          ),
          Expanded(
            child: ListView.separated(
              key: const PageStorageKey('two_pane_list'),
              itemCount: sampleDocuments.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final doc = sampleDocuments[index];
                final isSelected = index == _selectedIndex;
                return ListTile(
                  selected: isSelected,
                  title: Text(
                    doc.title,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(doc.date),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                      _priority = TwoPanePriority.end;
                    });
                  },
                );
              },
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
        label: 'Edit',
        onPressed: () {},
      ),
      groups: [
        NavActionGroup([
          NavAction(
            icon: Icons.share_outlined,
            label: 'Share',
            onPressed: () {},
          ),
          NavAction(
            icon: Icons.archive_outlined,
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
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back to documents',
              onPressed: () {
                setState(() {
                  _priority = TwoPanePriority.start;
                });
              },
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
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updated ${doc.date}',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    doc.content,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(height: 1.5),
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
