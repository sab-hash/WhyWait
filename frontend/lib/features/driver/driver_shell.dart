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

  /// Tabs are built the first time they are opened and then kept alive,
  /// so the map does not load until the driver opens it.
  final Set<int> _visited = {0};

  Widget _page(int index) {
    switch (index) {
      case 0:
        return const DriverHomeScreen();
      case 1:
        return const DriverMapScreen();
      case 2:
        return const DriverHistoryScreen();
      default:
        return const DriverProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: List.generate(4, (index) {
          return _visited.contains(index)
              ? _page(index)
              : const SizedBox.shrink();
        }),
      ),
      bottomNavigationBar: DriverBottomNav(
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index = index;
            _visited.add(index);
          });
        },
      ),
    );
  }
}