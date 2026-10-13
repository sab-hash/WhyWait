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
                      return _buildTile(state, notifications[index]);
                    },
                  ),
          ),
        );
      },
    );
  }

  (IconData, Color) _typeStyle(NotificationType type) {
    switch (type) {
      case NotificationType.queue:
        return (Icons.format_list_numbered_rounded, DriverTheme.primaryBlue);
      case NotificationType.route:
        return (Icons.alt_route_rounded, DriverTheme.deepBlue);
      case NotificationType.document:
        return (Icons.description_rounded, DriverTheme.warning);
      case NotificationType.admin:
        return (Icons.campaign_rounded, DriverTheme.success);
    }
  }

  Widget _buildTile(DriverState state, DriverNotification notification) {
    final style = _typeStyle(notification.type);
    final unread = !notification.read;

    return DriverCard(
      padding: const EdgeInsets.all(14),
      onTap: () => state.markNotificationRead(notification.id),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundIcon(icon: style.$1, color: style.$2),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              unread ? FontWeight.w800 : FontWeight.w600,
                          color: DriverTheme.textDark,
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: DriverTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: DriverTheme.textGrey,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DriverTheme.timeAgo(notification.time),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}