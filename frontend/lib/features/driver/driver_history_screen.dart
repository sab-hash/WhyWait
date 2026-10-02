import 'package:flutter/material.dart';

import '../../models/driver_trip.dart';
import 'driver_state.dart';
import 'driver_theme.dart';
import 'driver_widgets.dart';

/// History tab: the driver's past trips.
/// Date and time, route, seats carried, fare per seat and the trip status.
/// No passenger names are shown.
class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  final DriverState _state = DriverState.instance;

  int selectedTab = 0;

  List<DriverTrip> get filteredTrips {
    final trips = _state.trips;

    if (selectedTab == 0) {
      final start = _state.startOfToday;
      return trips.where((trip) => !trip.date.isBefore(start)).toList();
    }

    if (selectedTab == 1) {
      final start = _state.startOfWeek;
      return trips.where((trip) => !trip.date.isBefore(start)).toList();
    }

    return trips;
  }

  String get selectedTitle {
    if (selectedTab == 0) return 'Today';
    if (selectedTab == 1) return 'This Week';
    return 'All Trips';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        final trips = filteredTrips;

        return Scaffold(
          backgroundColor: DriverTheme.background,
          appBar: buildDriverAppBar('Trip History', showBack: false),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: DriverSegmentedTabs(
                    labels: const ['Today', 'This Week', 'All'],
                    selectedIndex: selectedTab,
                    onChanged: (index) => setState(() => selectedTab = index),
                  ),
                ),
                _buildSummary(trips),
                Expanded(
                  child: Center(
                    child: Text('${trips.length} trips'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummary(List<DriverTrip> trips) {
    final seats = trips
        .where((trip) => trip.status != TripResult.cancelled)
        .fold<int>(0, (sum, trip) => sum + trip.seats);
    final earnings =
        trips.fold<int>(0, (sum, trip) => sum + trip.estimatedEarnings);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.route_rounded,
              title: selectedTitle,
              value: '${trips.length}',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.event_seat_rounded,
              title: 'Seats carried',
              value: '$seats',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.payments_rounded,
              title: 'Earnings (est.)',
              value: '$earnings',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: DriverTheme.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}