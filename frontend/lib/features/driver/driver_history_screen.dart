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

  Widget _buildTripCard(DriverTrip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: DriverTheme.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  color: DriverTheme.primaryBlue,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DriverTheme.formatDate(trip.date),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DriverTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DriverTheme.formatTime(trip.date),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${trip.farePerSeat} ETB',
                    style: const TextStyle(
                      color: DriverTheme.primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'per seat',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildRouteRow(
            icon: Icons.circle,
            iconSize: 9,
            title: 'From',
            location: trip.from,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(
              width: 1,
              height: 20,
              color: Colors.grey.shade300,
            ),
          ),
          _buildRouteRow(
            icon: Icons.location_on_rounded,
            iconSize: 18,
            title: 'To',
            location: trip.to,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow({
    required IconData icon,
    required double iconSize,
    required String title,
    required String location,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Icon(icon, color: DriverTheme.primaryBlue, size: iconSize),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              location,
              style: const TextStyle(
                color: DriverTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}