import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'l10n/app_localizations.dart';
import 'screens/home/home_screen.dart';
import 'screens/constitution/constitution_screen.dart';
import 'screens/leaders/leaders_screen.dart';
import 'screens/leaders/leader_detail_screen.dart';
import 'screens/map/district_map_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/tools/citizenship_merger_screen.dart';
import 'screens/tools/image_compressor_screen.dart';
import 'screens/tools/date_converter_screen.dart';
import 'screens/tools/nepali_calendar_screen.dart';
import 'screens/tools/forex_screen.dart';
import 'screens/tools/bullion_screen.dart';
import 'screens/tools/ipo_shares_screen.dart';
import 'screens/government/how_nepal_works_screen.dart';

part 'app.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(RouterRef ref) {
  // Enable URL updates for push/pop operations on web
  GoRouter.optionURLReflectsImperativeAPIs = true;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      final path = state.uri.path;
      final uri = state.uri;
      // Handle deep links from widgets
      if (uri.scheme == 'nepalcivic' && uri.host.isNotEmpty) {
        return '/${uri.host}${uri.path}';
      }
      // Redirect root to /home
      if (path == '/' || path.isEmpty) {
        return '/home';
      }
      return null;
    },
    routes: [
      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(
            currentPath: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeTab(),
            ),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NepaliCalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/ipo',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: IpoSharesScreen(),
            ),
          ),
          GoRoute(
            path: '/rights',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ConstitutionScreen(),
            ),
          ),
        ],
      ),
      // Routes outside of bottom nav (full screen)
      GoRoute(
        path: '/constitution',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ConstitutionScreen(),
      ),
      GoRoute(
        path: '/constitutional-rights',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ConstitutionScreen(),
      ),
      GoRoute(
        path: '/leaders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LeadersScreen(),
        routes: [
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final leaderId = state.pathParameters['id'] ?? '';
              return LeaderDetailScreen(leaderId: leaderId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/map',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DistrictMapScreen(),
      ),
      GoRoute(
        path: '/how-nepal-works',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HowNepalWorksScreen(),
      ),
      GoRoute(
        path: '/government',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HowNepalWorksScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/photo-merger',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CitizenshipMergerScreen(),
      ),
      GoRoute(
        path: '/tools/citizenship-merger',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CitizenshipMergerScreen(),
      ),
      GoRoute(
        path: '/photo-compress',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ImageCompressorScreen(),
      ),
      GoRoute(
        path: '/tools/image-compressor',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ImageCompressorScreen(),
      ),
      GoRoute(
        path: '/date-converter',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DateConverterScreen(),
      ),
      GoRoute(
        path: '/tools/date-converter',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DateConverterScreen(),
      ),
      GoRoute(
        path: '/gov',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HowNepalWorksScreen(),
      ),
      // Legacy routes redirect to unified government screen
      GoRoute(
        path: '/gov-services',
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (context, state) => '/government',
      ),
      GoRoute(
        path: '/how-to-get',
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (context, state) => '/government',
      ),
      GoRoute(
        path: '/tools/nepali-calendar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NepaliCalendarScreen(),
      ),
      // Alias for deep links that might arrive without /tools/ prefix
      GoRoute(
        path: '/nepali-calendar',
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (context, state) => '/calendar',
      ),
      GoRoute(
        path: '/forex',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ForexScreen(),
      ),
      GoRoute(
        path: '/tools/forex',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ForexScreen(),
      ),
      GoRoute(
        path: '/gold-price',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BullionScreen(),
      ),
      GoRoute(
        path: '/tools/bullion',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BullionScreen(),
      ),
      GoRoute(
        path: '/tools/ipo',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const IpoSharesScreen(),
      ),
    ],
  );
}

/// Scaffold with bottom navigation bar
class ScaffoldWithNavBar extends StatefulWidget {
  const ScaffoldWithNavBar({
    required this.currentPath,
    required this.child,
    super.key,
  });

  final String currentPath;
  final Widget child;

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  // Track tab history for back navigation
  final List<int> _tabHistory = [1]; // Start with home (index 1)
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = _getIndexFromPath(widget.currentPath);
    if (_currentIndex != 1 && !_tabHistory.contains(_currentIndex)) {
      _tabHistory.add(_currentIndex);
    }
  }

  @override
  void didUpdateWidget(ScaffoldWithNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = _getIndexFromPath(widget.currentPath);
    if (newIndex != _currentIndex) {
      _currentIndex = newIndex;
      // Add to history if not already the last item
      if (_tabHistory.isEmpty || _tabHistory.last != newIndex) {
        _tabHistory.add(newIndex);
      }
    }
  }

  int _getIndexFromPath(String path) {
    if (path.startsWith('/calendar')) return 0;
    if (path.startsWith('/home')) return 1;
    if (path.startsWith('/ipo')) return 2;
    if (path.startsWith('/rights')) return 3;
    return 1; // default to home
  }

  bool get _isHome => _currentIndex == 1;

  void _onBackPressed() {
    if (_tabHistory.length > 1) {
      // Pop current tab from history
      _tabHistory.removeLast();
      // Navigate to previous tab
      final previousIndex = _tabHistory.last;
      final paths = ['/calendar', '/home', '/ipo', '/rights'];
      GoRouter.of(context).go(paths[previousIndex]);
    } else {
      // On home with no history, exit app
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: _isHome && _tabHistory.length <= 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onBackPressed();
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            final paths = ['/calendar', '/home', '/ipo', '/rights'];
            GoRouter.of(context).go(paths[index]);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: l10n.navCalendar,
            ),
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.show_chart_outlined),
              selectedIcon: const Icon(Icons.show_chart),
              label: l10n.navIpo,
            ),
            NavigationDestination(
              icon: const Icon(Icons.gavel_outlined),
              selectedIcon: const Icon(Icons.gavel),
              label: l10n.navRights,
            ),
          ],
        ),
      ),
    );
  }
}
