import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/passenger/passenger_shell.dart';
import '../../features/passenger/request_ride_screen.dart';
import '../../features/driver/driver_home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
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
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PassengerShell(
          fullName: extra['fullName'] ?? 'Abebe',
          email: extra['email'] ?? 'abebe@whywait.et',
        );
      },
    ),
    GoRoute(
      path: '/passenger/request-ride',
      builder: (context, state) => const RequestRideScreen(),
    ),
    GoRoute(
      path: '/driver',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return DriverHomeScreen(
          driverName: extra['driverName'] ?? 'Driver',
          email: extra['email'] ?? 'driver@whywait.et',
        );
      },
    ),
  ],
);