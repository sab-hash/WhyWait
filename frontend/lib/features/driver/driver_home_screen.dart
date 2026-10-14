import 'package:flutter/material.dart';

import '../../models/driver_models.dart';
import '../../models/driver_trip.dart';
import 'driver_state.dart';
import 'driver_theme.dart';
import 'driver_widgets.dart';

/// Earnings: today, this week, this month.
///
/// Passengers mostly pay cash, so fare x seats is only an *estimate* until
/// the driver confirms the cash was collected. Opened from Home or Profile.
class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  final DriverState _state = DriverState.instance;

  int _selectedTab = 0;

  static const List<String> _tabs = ['Today', 'This Week', 'This Month'];

  DateTime get _start {
    switch (_selectedTab) {
      case 0:
        return _state.startOfToday;
      case 1:
        return _state.startOfWeek;
      default:
        return _state.startOfMonth;
    }
  }

  /// Completed trips in the selected period that are not confirmed yet.
  List<DriverTrip> _unconfirmedTrips() {
    final start = _start;
    return _state.trips.where((trip) {
      return trip.status == TripResult.completed &&
          !trip.cashConfirmed &&
          !trip.date.isBefore(start);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        final summary = _state.earningsSince(_start);
        final unconfirmedTrips = _unconfirmedTrips();

        return Scaffold(
          backgroundColor: DriverTheme.background,
          appBar: buildDriverAppBar('Earnings'),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                DriverSegmentedTabs(
                  labels: _tabs,
                  selectedIndex: _selectedTab,
                  onChanged: (index) => setState(() => _selectedTab = index),
                ),
                const SizedBox(height: 16),
                _buildHero(summary),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        icon: Icons.directions_bus_rounded,
                        title: 'Trips completed',
                        value: '${summary.tripsCompleted}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniStat(
                        icon: Icons.event_seat_rounded,
                        title: 'Seats carried',
                        value: '${summary.seatsCarried}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const DriverGroupLabel('BREAKDOWN'),
                const SizedBox(height: 10),
                _buildBreakdown(summary),
                Center(child: Text('${unconfirmedTrips.length} unconfirmed')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHero(EarningsSummary summary) {
    final allConfirmed = summary.estimated > 0 && summary.unconfirmed == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: DriverTheme.deepBlue,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: DriverTheme.deepBlue.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            allConfirmed ? 'Confirmed earnings' : 'Estimated earnings',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${summary.estimated} ETB',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Fare × seats. Most passengers pay cash.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          if (summary.estimated == 0)
            Text(
              'No completed trips in this period yet.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
              ),
            )
          else if (allConfirmed)
            _heroChip(
              icon: Icons.check_circle_rounded,
              text: 'All cash confirmed',
              color: const Color(0xFF7CE0A0),
            )
          else
            _heroChip(
              icon: Icons.hourglass_bottom_rounded,
              text: '${summary.unconfirmed} ETB not confirmed yet',
              color: const Color(0xFFFFD27A),
            ),
        ],
      ),
    );
  }

  Widget _heroChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
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

  Widget _buildBreakdown(EarningsSummary summary) {
    final commission = _state.commissionOn(summary.estimated);
    final percent = DriverConfig.commissionPercent;

    final rows = <Widget>[
      _BreakdownRow(
        label: 'Fixed fare per seat',
        value: '${DriverState.farePerSeat} ETB',
      ),
      _BreakdownRow(
        label: 'Seats carried',
        value: '${summary.seatsCarried}',
      ),
      _BreakdownRow(
        label: 'Estimated total',
        value: '${summary.estimated} ETB',
        isBold: true,
      ),
      _BreakdownRow(
        label: 'Cash confirmed',
        value: '${summary.confirmed} ETB',
        valueColor: DriverTheme.success,
      ),
      _BreakdownRow(
        label: 'Not confirmed yet',
        value: '${summary.unconfirmed} ETB',
        valueColor:
            summary.unconfirmed > 0 ? DriverTheme.warning : DriverTheme.textGrey,
      ),
    ];

    // Only shown if the team decides the app takes a cut.
    if (commission != null && percent != null) {
      rows.addAll([
        _BreakdownRow(
          label: 'App commission ($percent%)',
          value: '- ${commission.toStringAsFixed(0)} ETB',
          valueColor: DriverTheme.danger,
        ),
        _BreakdownRow(
          label: 'Estimated after commission',
          value: '${(summary.estimated - commission).toStringAsFixed(0)} ETB',
          isBold: true,
        ),
      ]);
    }

    return DriverCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              const Divider(height: 1, color: DriverTheme.divider),
          ],
        ],
      ),
    );
  }

  Widget _buildUnconfirmedTile(DriverTrip trip) {
    return DriverCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip.from} → ${trip.to}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: DriverTheme.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${DriverTheme.formatShortDate(trip.date)}, '
                  '${DriverTheme.formatTime(trip.date)} • '
                  '${trip.seats} × ${trip.farePerSeat} = '
                  '${trip.estimatedEarnings} ETB',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              _state.confirmTripCash(trip);
              showDriverSnack(context, 'Cash confirmed.');
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: DriverTheme.primaryBlue, size: 22),
          const SizedBox(height: 7),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: DriverTheme.textDark,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _BreakdownRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isBold ? DriverTheme.textDark : DriverTheme.textGrey,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? DriverTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}