import 'package:flutter/material.dart';

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  int _selectedTab = 2;

  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Trip History',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Main content
      body: const SafeArea(
        child: Center(
          child: Text(
            'Trip history will appear here',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedTab,

      onTap: (index) {
        setState(() {
          _selectedTab = index;
        });
      },

      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,

      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,

      selectedFontSize: 12,
      unselectedFontSize: 12,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Map',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history),
          label: 'History',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}