// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:flutter/material.dart';

/// Page with a Material large title that collapses on scroll, .
///
/// The bar column or bottom bar owns Back, so the title bar never adds its own.
class ExampleScrollPage extends StatelessWidget {
  /// Creates a page titled [title] showing [slivers] below the title.
  const ExampleScrollPage({
    super.key,
    required this.title,
    required this.slivers,
    this.storageKey,
  });

  /// Large title text.
  final String title;

  /// Content below the title.
  final List<Widget> slivers;

  /// Key that keeps the scroll offset across tab switches.
  final PageStorageKey<String>? storageKey;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: CustomScrollView(
        key: storageKey,
        slivers: [
          SliverAppBar.large(
            title: Text(title),
            automaticallyImplyLeading: false,
          ),
          ...slivers,
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

/// Page with a fixed large title above [child], for content that scrolls on its own.
class ExampleFixedPage extends StatelessWidget {
  /// Creates a page titled [title] around [child].
  const ExampleFixedPage({super.key, required this.title, required this.child});

  /// Large title text.
  final String title;

  /// Content below the title; it brings its own scrolling.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 12, 20, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Titled group of rows, a Material stand-in for an inset grouped list.
class ExampleSection extends StatelessWidget {
  /// Creates a section of [children] with an optional [header] and [footer].
  const ExampleSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
  });

  /// Label above the rows.
  final Widget? header;

  /// Note below the rows.
  final Widget? footer;

  /// Rows, usually [ListTile]s.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: DefaultTextStyle(
                style: theme.textTheme.titleSmall!.copyWith(
                  color: theme.colorScheme.primary,
                ),
                child: header!,
              ),
            ),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: DefaultTextStyle(
                style: theme.textTheme.bodySmall!,
                child: footer!,
              ),
            ),
        ],
      ),
    );
  }
}
