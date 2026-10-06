import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'nearby_stations_screen.dart';

class PassengerShell extends StatefulWidget {
  final String fullName;
  final String email;

  const PassengerShell({
    super.key,
    required this.fullName,
    required this.email,
  });

  @override
  State<PassengerShell> createState() => _PassengerShellState();
}

class _PassengerShellState extends State<PassengerShell> {
  static const Color primaryBlue = Color(0xFF1565C0);
  int _index = 0;

  late final List<Widget> _pages = [
    HomeScreen(fullName: widget.fullName, email: widget.email),
    const HistoryScreen(),
    const NearbyStationsScreen(),
    ProfileScreen(
      fullName: widget.fullName,
      phoneNumber: '',
      email: widget.email,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE3F2FD),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.home_rounded, color: primaryBlue),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.history_rounded, color: primaryBlue),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.map_rounded, color: primaryBlue),
              label: 'Maps',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: Colors.grey),
              selectedIcon: Icon(Icons.person_rounded, color: primaryBlue),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}