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
  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Row(
      children: [
        const Text('🚖', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'DRIVER MODE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: primaryBlue,
            ),
          ),
        ),
        _shiftBadge(),
        const SizedBox(width: 8),
        _profileButton(),
      ],
    );
  }

  Widget _shiftBadge() {
    final color = _isShiftActive ? successGreen : Colors.grey.shade500;
    return GestureDetector(
      onTap: _toggleShift,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              _isShiftActive ? 'ACTIVE SHIFT' : 'OFF DUTY',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileButton() {
    return GestureDetector(
      onTap: _openProfile,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: primaryBlue, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.person_outline_rounded,
          color: primaryBlue,
          size: 22,
        ),
      ),
    );
  }

  // ==================== ACTIONS ====================
  void _toggleShift() {
    setState(() => _isShiftActive = !_isShiftActive);
    _showSnack(
      _isShiftActive ? 'Shift started' : 'Shift ended',
      color: _isShiftActive ? successGreen : Colors.grey.shade700,
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          fullName: widget.driverName,
          phoneNumber: widget.email,
        ),
      ),
    );
  }

  void _showSnack(String message, {Color color = primaryBlue}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }
    // ==================== DRIVER INFO ROW ====================
  Widget _buildDriverInfoRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _infoColumn(
              label: 'PLATE',
              child: Text(
                widget.plateNumber,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
            ),
          ),
          Container(width: 1, height: 34, color: Colors.grey.shade200),
          Expanded(
            child: _infoColumn(
              label: 'ROUTE',
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.routeFrom,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkText,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.arrow_forward_rounded,
                        size: 14, color: primaryBlue),
                  ),
                  Flexible(
                    child: Text(
                      widget.routeTo,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoColumn({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
    // ==================== SECTION LABEL ====================
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        letterSpacing: 1,
        fontWeight: FontWeight.w800,
        color: primaryBlue,
      ),
    );
  }
    // ==================== DISPATCH CARD ====================
  Widget _buildDispatchCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hubRow(),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR DISPATCH QUEUE POSITION',
                  style: TextStyle(
                    fontSize: 9.5,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '#$_queuePosition',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        'IN LINE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time_rounded,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '~$_estimatedDispatchMins min',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hubRow() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.location_on_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ASSIGNED HUB',
                style: TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$_assignedHub ($_gateNumber)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  