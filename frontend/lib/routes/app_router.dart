import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_events_ai/providers/auth_provider.dart';
import 'package:campus_events_ai/features/auth/login_screen.dart';
import 'package:campus_events_ai/features/admin/admin_dashboard.dart';
import 'package:campus_events_ai/features/admin/create_event_screen.dart';
import 'package:campus_events_ai/features/admin/edit_event_screen.dart';
import 'package:campus_events_ai/features/student/home_screen.dart';
import 'package:campus_events_ai/features/student/event_detail_screen.dart';
import 'package:campus_events_ai/features/student/favorites_screen.dart';
import 'package:campus_events_ai/features/student/registrations_screen.dart';
import 'package:campus_events_ai/features/ai_assistant/assistant_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) {
        return authState.isAdmin ? '/admin' : '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreateEventScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) => EditEventScreen(
              eventId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'events/:id',
            builder: (context, state) => EventDetailScreen(
              eventId: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: 'favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: 'registrations',
            builder: (context, state) => const RegistrationsScreen(),
          ),
          GoRoute(
            path: 'assistant',
            builder: (context, state) => const AssistantScreen(),
          ),
        ],
      ),
    ],
  );
});
