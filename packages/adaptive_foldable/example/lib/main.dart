// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable_example/screens/grid_screen.dart';
import 'package:adaptive_foldable_example/screens/presentations_screen.dart';
import 'package:adaptive_foldable_example/screens/two_pane_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Run with `--dart-define=NATIVE_BAR=true` to use the native iOS tab bar.
const bool _nativeBar = bool.fromEnvironment('NATIVE_BAR');

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
  late final GoRouter _router = GoRouter(
    initialLocation: '/inbox',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AdaptiveNavScaffold(
          destinations: const [
            NavDestination(
              icon: Icons.inbox_outlined,
              label: 'Inbox',
              badgeCount: 7,
              sfSymbol: 'tray',
            ),
            NavDestination(
              icon: Icons.view_sidebar_outlined,
              label: 'Two-Pane',
              sfSymbol: 'sidebar.right',
            ),
            NavDestination(
              icon: Icons.grid_view_outlined,
              label: 'Grid',
              sfSymbol: 'square.grid.2x2',
            ),
            NavDestination(
              icon: Icons.layers_outlined,
              label: 'Modals',
              sfSymbol: 'square.3.layers.3d',
            ),
            NavDestination(
              icon: Icons.person_outline,
              label: 'Profile',
              sfSymbol: 'person',
            ),
          ],
          barBuilder: _nativeBar ? nativeIosBarBuilder : null,
          selectedIndex: shell.currentIndex,
          onSelected: shell.goBranch,
          debugOverlay: true,
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
    return MaterialApp.router(
      title: 'Adaptive Foldable Example',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      routerConfig: _router,
      builder: (context, child) => FoldSignalsScope(child: child!),
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
          NavAction(icon: Icons.refresh, label: 'Refresh', onPressed: () {}),
        ]),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Inbox')),
        body: ListView(
          key: const PageStorageKey('inbox'),
          children: [
            for (var i = 0; i < 40; i++)
              ListTile(
                title: Text('Message $i'),
                onTap: () => context.go('/inbox/message/$i'),
              ),
          ],
        ),
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
    NavAction action(String label, IconData icon) =>
        NavAction(icon: icon, label: label, onPressed: () {});
    return AdaptiveNavActions(
      prominentAction: action('Reply', Icons.reply),
      groups: [
        NavActionGroup([
          action('Share', Icons.share),
          action('Archive', Icons.archive_outlined),
          action('Label', Icons.label_outline),
        ]),
        NavActionGroup([
          NavAction(
            icon: Icons.delete_outline,
            label: 'Delete',
            isDestructive: true,
            onPressed: () {},
          ),
          action('Mute', Icons.volume_off_outlined),
          action('Snooze', Icons.snooze),
        ]),
      ],
      overflowItems: [action('Report', Icons.flag_outlined)],
      child: Scaffold(
        appBar: AppBar(title: Text('Message $id')),
        body: Center(child: Text('Message body $id')),
      ),
    );
  }
}

/// Second tab without actions: only the tabs show.
class ProfilePage extends StatelessWidget {
  /// Creates an instance of [ProfilePage].
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final signals = FoldSignals.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('adaptive_foldable $adaptiveFoldableVersion'),
            Text('Posture: ${signals.posture.name}'),
            Text('Bar edge: ${signals.verticalBarEdge?.name ?? "none"}'),
            Text(
              'Size: ${signals.viewSize.width.round()} x ${signals.viewSize.height.round()}',
            ),
          ],
        ),
      ),
    );
  }
}
