import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final authProvider = context.read<AuthProvider>();
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoading = authProvider.isLoading;

        // Don't redirect while loading
        if (isLoading) return null;

        // Public routes that don't require authentication
        final publicRoutes = ['/login', '/register'];
        final isPublicRoute = publicRoutes.contains(state.matchedLocation);

        // If not authenticated and trying to access protected route
        if (!isAuthenticated && !isPublicRoute) {
          return '/login';
        }

        // If authenticated and trying to access login/register
        if (isAuthenticated && isPublicRoute) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
  }
}