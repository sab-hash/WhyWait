import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PassengerScaffold extends StatefulWidget {
  final Widget child;

  const PassengerScaffold({super.key, required this.child});

  @override
  State<PassengerScaffold> createState() => _PassengerScaffoldState();
}

class _PassengerScaffoldState extends State<PassengerScaffold> {
  int _selectedIndex = 0;

  int _getIndexFromPath(String path) {
    if (path.startsWith('/passenger/track')) return 1;
    if (path.startsWith('/passenger/trips')) return 2;
    if (path.startsWith('/passenger/profile')) return 3;
    return 0;
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
              context.go('/passenger');
              break;
            case 1:
              context.go('/passenger/track');
              break;
            case 2:
              context.go('/passenger/trips');
              break;
            case 3:
              context.go('/passenger/profile');
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
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on_rounded),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Trips',
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