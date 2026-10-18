import 'package:flutter/material.dart';

import 'driver_history_screen.dart';
import 'driver_home_screen.dart';
import 'driver_profile_screen.dart';
import 'driver_tracking_screen.dart';
import 'driver_widgets.dart';

/// Entry point of the driver side.
///
/// Holds the 4 bottom tabs: Home, Map, History, Profile. Everything else
/// (Earnings, Demand map, Vehicle, Documents, Notifications, Safety) opens
/// from Home or Profile.
///
/// To open the driver side, use `home: const DriverShell()`.
class DriverShell extends StatefulWidget {
  const DriverShell({super.key});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: Center(child: Text('Driver')),
      ),
    );
  }
}