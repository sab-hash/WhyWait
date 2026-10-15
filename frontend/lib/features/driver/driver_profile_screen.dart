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
                  _buildHeader(state),
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildStatsCard(state),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: DriverGroupLabel('VEHICLE'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildVehicleCard(context, state),
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

  Widget _buildHeader(DriverState state) {
    final profile = state.profile;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
      decoration: const BoxDecoration(
        color: DriverTheme.deepBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipOval(
              child: profile.photoUrl != null
                  ? Image.network(
                      profile.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _avatarFallback(),
                    )
                  : _avatarFallback(),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.phone,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _headerChip(
                icon: Icons.badge_outlined,
                text: 'ID ${profile.driverId}',
                color: DriverTheme.deepBlue,
              ),
              _verificationChip(state.verification),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: Colors.white.withValues(alpha: 0.2),
      child: const Icon(Icons.person, size: 44, color: Colors.white),
    );
  }

  Widget _verificationChip(Verification verification) {
    switch (verification) {
      case Verification.verified:
        return _headerChip(
          icon: Icons.verified_rounded,
          text: 'Verified',
          color: DriverTheme.success,
        );
      case Verification.pending:
        return _headerChip(
          icon: Icons.hourglass_bottom_rounded,
          text: 'Pending review',
          color: const Color(0xFFB7791F),
        );
      case Verification.actionNeeded:
        return _headerChip(
          icon: Icons.error_outline_rounded,
          text: 'Action needed',
          color: DriverTheme.danger,
        );
    }
  }

  Widget _headerChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(DriverState state) {
    final today = state.earningsSince(state.startOfToday);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (DriverConfig.ratingsEnabled) ...[
            Expanded(
              child: _statColumn(
                '${state.profile.rating.toStringAsFixed(1)} ★',
                'Rating',
              ),
            ),
            _statDivider(),
          ],
          Expanded(
            child: _statColumn('${state.completedTripsTotal}', 'Trips'),
          ),
          _statDivider(),
          Expanded(
            child: _statColumn('${today.estimated} ETB', 'Today (est.)'),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 34, color: Colors.grey[200]);
  }

  Widget _buildVehicleCard(BuildContext context, DriverState state) {
    final vehicle = state.vehicle;

    return DriverRowTile(
      icon: Icons.directions_car_filled_rounded,
      title: '${vehicle.color} ${vehicle.model}',
      subtitle: vehicle.plate,
      onTap: () => _open(context, const DriverVehicleScreen()),
    );
  }
}