import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/passenger/home_screen.dart';
import '../../features/driver/driver_home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/passenger',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;

        return HomeScreen(
          fullName: extra['fullName'] ?? 'User',
          email: extra['email'] ?? '',
        );
      },
    ),

    GoRoute(
      path: '/driver',
      builder: (context, state) {
        return const DriverHomeScreen();
      },
    ),
  ],
);
