import 'package:flutter/material.dart';

import '../../core/storage/local_storage.dart';
import '../../models/driver_models.dart';
import '../auth/login_screen.dart';
import 'driver_documents_screen.dart';
import 'driver_earnings_screen.dart';
import 'driver_notifications_screen.dart';
import 'driver_safety_screen.dart';
import 'driver_state.dart';
import 'driver_theme.dart';
import 'driver_vehicle_screen.dart';
import 'driver_widgets.dart';

/// Profile tab: name, phone, photo, driver ID, verification status and
/// rating, plus the doors to Vehicle, Documents, Earnings, Notifications
/// and Safety. Sign out is at the bottom.
class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DriverState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: DriverTheme.background,
          body: const SafeArea(
            child: Center(child: Text('Profile')),
          ),
        );
      },
    );
  }
}