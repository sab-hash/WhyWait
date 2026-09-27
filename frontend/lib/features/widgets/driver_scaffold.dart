import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DriverScaffold extends StatefulWidget {
  final Widget child;

  const DriverScaffold({super.key, required this.child});

  @override
  State<DriverScaffold> createState() => _DriverScaffoldState();
}

class _DriverScaffoldState extends State<DriverScaffold> {
  int _selectedIndex = 0;

  int _getIndexFromPath(String path) {
    if (path.startsWith('/driver/map')) return 1;
    if (path.startsWith('/driver/history')) return 2;
    if (path.startsWith('/driver/profile')) return 3;
    return 0; // home
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    _selectedIndex = _getIndexFromPath(currentPath);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/driver');
              break;
            case 1:
              context.go('/driver/map');
              break;
            case 2:
              context.go('/driver/history');
              break;
            case 3:
              context.go('/driver/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}