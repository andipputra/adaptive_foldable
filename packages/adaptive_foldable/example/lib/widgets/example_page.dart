// ignore_for_file: deprecated_member_use -- cupertino.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:flutter/cupertino.dart';

/// Page with an iOS large title that collapses on scroll, on a grouped background.
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
      color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      child: CustomScrollView(
        key: storageKey,
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(title),
            automaticallyImplyLeading: false,
            transitionBetweenRoutes: false,
            border: null,
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
      color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 12, 20, 8),
            child: Text(
              title,
              style: CupertinoTheme.of(context)
                  .textTheme
                  .navLargeTitleTextStyle,
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
