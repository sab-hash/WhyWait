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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverTheme.background,
      appBar: buildDriverAppBar('Earnings'),
      body: const SafeArea(
        child: Center(child: Text('Earnings')),
      ),
    );
  }
}