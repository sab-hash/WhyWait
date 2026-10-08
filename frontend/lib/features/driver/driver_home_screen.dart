import 'package:flutter/material.dart';
import '../profile_screen.dart';

/// Driver-mode home screen.
///
/// Focused on dispatch queue management, seat counting, daily performance,
/// traffic alerts, and safety actions.
class DriverHomeScreen extends StatefulWidget {
  final String driverName;
  final String email;
  final String plateNumber;
  final String routeFrom;
  final String routeTo;

  const DriverHomeScreen({
    super.key,
    required this.driverName,
    required this.email,
    this.plateNumber = 'AA-3-B89102',
    this.routeFrom = 'Megenagna',
    this.routeTo = 'Mexico',
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  // ==================== THEME ====================
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkText = Color(0xFF333333);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color warningOrange = Color(0xFFEF6C00);
  static const Color dangerRed = Color(0xFFC62828);

  // ==================== STATE ====================
  bool _isShiftActive = true;

  // Dispatch / hub queue
  final String _assignedHub = 'Megenagna Terminal';
  final String _gateNumber = 'Gate #2';
  int _queuePosition = 2;
  int _estimatedDispatchMins = 3;

  // Seat counter
  static const int _totalSeats = 14;
  int _seatsOpen = 3;

  // Performance
  int _tripsCompleted = 8;
  static const int _dailyTarget = 12;
  double _grossRevenue = 1680.0;

  double get _quotaProgress => _tripsCompleted / _dailyTarget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
          child: const Center(
            child: Text('Driver dashboard — coming online…'),
          ),
        ),
      ),
    );
  }
}