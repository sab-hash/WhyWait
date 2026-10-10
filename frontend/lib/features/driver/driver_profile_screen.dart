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