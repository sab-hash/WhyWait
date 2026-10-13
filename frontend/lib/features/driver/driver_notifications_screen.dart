import 'package:flutter/material.dart';

import '../../models/driver_models.dart';
import 'driver_state.dart';
import 'driver_theme.dart';
import 'driver_widgets.dart';

/// Notifications: "you're next in queue", route assignment or change,
/// document expiry, admin messages and announcements.
/// There is no "new ride request": drivers work a fixed route.
/// Opened from the bell on Home or from Profile.
class DriverNotificationsScreen extends StatelessWidget {
  const DriverNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DriverState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: DriverTheme.background,
          appBar: buildDriverAppBar('Notifications'),
          body: const SafeArea(
            child: Center(child: Text('Notifications')),
          ),
        );
      },
    );
  }
}