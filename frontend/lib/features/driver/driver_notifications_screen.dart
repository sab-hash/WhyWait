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
        final notifications = state.notifications;

        return Scaffold(
          backgroundColor: DriverTheme.background,
          appBar: buildDriverAppBar(
            'Notifications',
            actions: [
              if (state.unreadNotifications > 0)
                TextButton(
                  onPressed: state.markAllNotificationsRead,
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: notifications.isEmpty
                ? const Center(child: Text('No notifications'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        );
      },
    );
  }
}