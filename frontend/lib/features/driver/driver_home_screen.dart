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
                Center(child: Text('${unconfirmedTrips.length} unconfirmed')),
              ],
            ),
          ),
        );
      },
    );
  }
}