import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_pagination/router/scaffold_with_nested_navigation.dart';

enum AppRoute {
  movies,
  movie,
  favorites,
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final _favoriteNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'favorites');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/movies',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/movies',
                name: AppRoute.movies.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  // TODO: Change to actual movies page
                  child: Container(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
