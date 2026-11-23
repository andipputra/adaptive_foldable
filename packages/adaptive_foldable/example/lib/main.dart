// ignore_for_file: deprecated_member_use -- cupertino.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable_example/screens/grid_screen.dart';
import 'package:adaptive_foldable_example/screens/presentations_screen.dart';
import 'package:adaptive_foldable_example/screens/two_pane_screen.dart';
import 'package:adaptive_foldable_example/widgets/example_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

/// Example application: a `StatefulShellRoute` with two tabs whose pages publish actions.
class MyApp extends StatefulWidget {
  /// Creates an instance of [MyApp].
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Chosen on the start page; read by the shell when it builds the bar.
  bool _native = false;

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => StartPage(
          onSelected: (native) {
            _native = native;
            _router.go('/inbox');
          },
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AdaptiveNavScaffold(
          destinations: const [
            NavDestination(
              icon: CupertinoIcons.tray,
              selectedIcon: CupertinoIcons.tray_fill,
              label: 'Inbox',
              badgeCount: 7,
              sfSymbol: 'tray',
            ),
            NavDestination(
              icon: CupertinoIcons.sidebar_right,
              label: 'Two-Pane',
              sfSymbol: 'sidebar.right',
            ),
            NavDestination(
              icon: CupertinoIcons.square_grid_2x2,
              label: 'Grid',
              sfSymbol: 'square.grid.2x2',
            ),
            NavDestination(
              icon: CupertinoIcons.layers,
              label: 'Modals',
              sfSymbol: 'square.3.layers.3d',
            ),
            NavDestination(
              icon: CupertinoIcons.person,
              label: 'Profile',
              sfSymbol: 'person',
            ),
          ],
          barBuilder: _native ? nativeIosBarBuilder : null,
          selectedIndex: shell.currentIndex,
          onSelected: shell.goBranch,
          debugOverlay: false,
          backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
          extendBodyBehindBar: false,
          body: shell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (_, _) => const InboxPage(),
                routes: [
                  GoRoute(
                    path: 'message/:id',
                    builder: (_, state) =>
                        MessagePage(id: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/two-pane',
                builder: (_, _) => const TwoPaneScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/grid', builder: (_, _) => const GridScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/modals',
                builder: (_, _) => const PresentationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      title: 'Adaptive Foldable Example',
      theme: const CupertinoThemeData(primaryColor: CupertinoColors.systemBlue),
      routerConfig: _router,
      builder: (context, child) => FoldSignalsScope(child: child!),
    );
  }
}

/// First page: choose the native iOS bar or the package's default bar.
class StartPage extends StatelessWidget {
  /// Creates an instance of [StartPage]; [onSelected] receives true for the native bar.
  const StartPage({super.key, required this.onSelected});

  /// Called with true for the native bar, false for the default bar.
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Choose navigation'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Native uses UIKit on iOS and falls back to the Cupertino-style bar elsewhere. Default uses the package bar for the platform.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: () => onSelected(true),
                child: const Text('Native'),
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                onPressed: () => onSelected(false),
                child: const Text('Default'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// List of messages; publishes one action.
class InboxPage extends StatelessWidget {
  /// Creates an instance of [InboxPage].
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavActions(
      groups: [
        NavActionGroup([
          NavAction(
            icon: CupertinoIcons.refresh,
            sfSymbol: 'arrow.clockwise',
            label: 'Refresh',
            onPressed: () {},
          ),
        ]),
      ],
      child: ExampleScrollPage(
        title: 'Inbox',
        storageKey: const PageStorageKey('inbox'),
        slivers: [
          SliverToBoxAdapter(
            child: CupertinoListSection.insetGrouped(
              children: [
                for (var i = 0; i < 40; i++)
                  CupertinoListTile.notched(
                    leading: const Icon(CupertinoIcons.mail),
                    title: Text('Message $i'),
                    subtitle: const Text('Tap to read'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => context.go('/inbox/message/$i'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Message detail with enough actions to show the overflow menu.
class MessagePage extends StatelessWidget {
  /// Creates an instance of [MessagePage] for message [id].
  const MessagePage({super.key, required this.id});

  /// Message identifier.
  final String id;

  @override
  Widget build(BuildContext context) {
    NavAction action(String label, IconData icon, String symbol) =>
        NavAction(icon: icon, sfSymbol: symbol, label: label, onPressed: () {});
    return AdaptiveNavActions(
      prominentAction: action(
        'Reply',
        CupertinoIcons.reply,
        'arrowshape.turn.up.left',
      ),
      groups: [
        NavActionGroup([
          action('Share', CupertinoIcons.share, 'square.and.arrow.up'),
          action('Archive', CupertinoIcons.archivebox, 'archivebox'),
          action('Label', CupertinoIcons.tag, 'tag'),
        ]),
        NavActionGroup([
          NavAction(
            icon: CupertinoIcons.delete,
            sfSymbol: 'trash',
            label: 'Delete',
            isDestructive: true,
            onPressed: () {},
          ),
          action('Mute', CupertinoIcons.bell_slash, 'bell.slash'),
          action('Snooze', CupertinoIcons.moon_zzz, 'moon.zzz'),
        ]),
      ],
      overflowItems: [action('Report', CupertinoIcons.flag, 'flag')],
      child: ExampleScrollPage(
        title: 'Message $id',
        slivers: [
          SliverToBoxAdapter(
            child: CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile.notched(
                  leading: const Icon(CupertinoIcons.person_crop_circle),
                  title: const Text('From: Ada Lovelace'),
                  subtitle: const Text('To: you'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Message body $id',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Last tab without actions: only the tabs show, plus live signals.
class ProfilePage extends StatelessWidget {
  /// Creates an instance of [ProfilePage].
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final signals = FoldSignals.of(context);
    Widget row(IconData icon, String text) =>
        CupertinoListTile.notched(leading: Icon(icon), title: Text(text));
    return ExampleScrollPage(
      title: 'Profile',
      slivers: [
        SliverToBoxAdapter(
          child: CupertinoListSection.insetGrouped(
            header: const Text('Package'),
            children: [
              row(
                CupertinoIcons.cube_box,
                'adaptive_foldable $adaptiveFoldableVersion',
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: CupertinoListSection.insetGrouped(
            header: const Text('Live signals'),
            children: [
              row(
                CupertinoIcons.device_phone_landscape,
                'Posture: ${signals.posture.name}',
              ),
              row(
                CupertinoIcons.sidebar_right,
                'Bar edge: ${signals.verticalBarEdge?.name ?? "none"}',
              ),
              row(
                CupertinoIcons.arrow_up_left_arrow_down_right,
                'Size: ${signals.viewSize.width.round()} x ${signals.viewSize.height.round()}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
