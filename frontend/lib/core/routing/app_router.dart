
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/passenger/home_screen.dart';
import '../../features/passenger/passenger_shell.dart';
import '../../features/passenger/request_ride_screen.dart';
import '../../features/passenger/history_screen.dart';
import '../../features/driver/driver_home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/passenger',
      builder: (context, state) {
        final extra = state.extra is Map ? state.extra as Map : null;

        return HomeScreen(
          fullName: (extra?['fullName'] ?? 'User').toString(),
          email: (extra?['email'] ?? '').toString(),
        );
      },
    ),
    GoRoute(
      path: '/passenger/shell',
      builder: (context, state) {
        final extra = state.extra is Map ? state.extra as Map : null;

        return PassengerShell(
          fullName: (extra?['fullName'] ?? 'User').toString(),
          email: (extra?['email'] ?? '').toString(),
        );
      },
    ),
    GoRoute(
      path: '/passenger/request-ride',
      builder: (context, state) => const RequestRideScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/driver',
      builder: (context, state) {
        final extra = state.extra is Map ? state.extra as Map : null;
        return DriverHomeScreen(
          driverName: (extra?['driverName'] ?? extra?['fullName'] ?? 'Driver').toString(),
          email: (extra?['email'] ?? '').toString(),
        );
      },
    ),
  ],
);
