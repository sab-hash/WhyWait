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
    return Scaffold(
      backgroundColor: DriverTheme.background,
      appBar: buildDriverAppBar('Trip History', showBack: false),
      body: const SafeArea(
        child: Center(child: Text('Trip History')),
      ),
    );
  }
}