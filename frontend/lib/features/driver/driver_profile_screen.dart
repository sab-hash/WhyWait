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
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 120),
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(height: 90),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: DriverGroupLabel('VEHICLE'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(height: 70),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: DriverGroupLabel('ACCOUNT'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _row(
                          DriverRowTile(
                            icon: Icons.folder_copy_outlined,
                            title: 'Documents',
                            subtitle: _documentsSubtitle(state),
                            onTap: () => _open(
                              context,
                              const DriverDocumentsScreen(),
                            ),
                          ),
                        ),
                        _row(
                          DriverRowTile(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Earnings',
                            subtitle: 'Today, this week, this month',
                            onTap: () => _open(
                              context,
                              const DriverEarningsScreen(),
                            ),
                          ),
                        ),
                        _row(
                          DriverRowTile(
                            icon: Icons.notifications_none_rounded,
                            title: 'Notifications',
                            subtitle: 'Queue, route and document alerts',
                            trailing: state.unreadNotifications > 0
                                ? StatusChip(
                                    label: '${state.unreadNotifications} new',
                                    color: DriverTheme.danger,
                                  )
                                : null,
                            onTap: () => _open(
                              context,
                              const DriverNotificationsScreen(),
                            ),
                          ),
                        ),
                        _row(
                          DriverRowTile(
                            icon: Icons.health_and_safety_outlined,
                            title: 'Safety',
                            subtitle: 'SOS, contacts, share location',
                            onTap: () => _open(
                              context,
                              const DriverSafetyScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: SizedBox(height: 54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _row(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: child,
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  String _documentsSubtitle(DriverState state) {
    final attention = state.documentsNeedingAttention;
    final pending = state.documents
        .where((document) => document.status == DocStatus.pending)
        .length;

    final parts = <String>[];
    if (attention > 0) parts.add('$attention need attention');
    if (pending > 0) parts.add('$pending pending');

    return parts.isEmpty ? 'All documents up to date' : parts.join(' • ');
  }
}