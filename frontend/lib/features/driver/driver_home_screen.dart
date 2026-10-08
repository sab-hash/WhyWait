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
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: primaryBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildDriverInfoRow(),
                const SizedBox(height: 22),
                _buildSectionLabel('DISPATCH & HUB QUEUE'),
                const SizedBox(height: 8),
                _buildDispatchCard(),
                const SizedBox(height: 22),
                _buildSectionLabel('SEAT AVAILABILITY'),
                const SizedBox(height: 8),
                _buildSeatCounterCard(),
                const SizedBox(height: 22),
                _buildSectionLabel('DAILY PERFORMANCE'),
                const SizedBox(height: 8),
                _buildPerformanceCard(),
                const SizedBox(height: 22),
                _buildSectionLabel('CORRIDOR & TRAFFIC'),
                const SizedBox(height: 8),
                _buildTrafficAlertsCard(),
                const SizedBox(height: 22),
                _buildSectionLabel('SAFETY & ASSISTANCE'),
                const SizedBox(height: 8),
                _buildSafetyActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    // TODO: wire to ApiService.getDriverStatus() when endpoint exists.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _queuePosition = 2;
      _estimatedDispatchMins = 3;
    });
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
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(22),
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
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: primaryBlue,
                    ),
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
            blurRadius: 16,
            offset: const Offset(0, 7),
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
                    const Icon(
                      Icons.access_time_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _proceedToBoardingGate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text(
                    'PROCEED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _requestBreak,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  icon: const Icon(Icons.pause_rounded, size: 20),
                  label: const Text(
                    'BREAK',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
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
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 22,
          ),
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

  // ==================== SEAT COUNTER ====================
  Widget _buildSeatCounterCard() {
    final bool isFull = _seatsOpen == 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.event_seat_rounded,
                  color: primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEATS OPEN',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$_seatsOpen',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: isFull ? dangerRed : primaryBlue,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ $_totalSeats',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              if (isFull)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: dangerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: dangerRed.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'FULL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: dangerRed,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _counterButton(
                  icon: Icons.remove_rounded,
                  label: '1 Seat',
                  onTap: _seatsOpen > 0 ? _decrementSeats : null,
                  filled: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _counterButton(
                  icon: Icons.add_rounded,
                  label: '1 Seat',
                  onTap: _seatsOpen < _totalSeats ? _incrementSeats : null,
                  filled: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.report_gmailerrorred_rounded,
                  label: 'MARK BUS FULL',
                  onTap: _markBusFull,
                  color: dangerRed,
                  filled: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  icon: Icons.refresh_rounded,
                  label: 'RESET RETURN',
                  onTap: _resetForReturnTrip,
                  color: primaryBlue,
                  filled: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool filled,
  }) {
    final bool disabled = onTap == null;
    final Color bg = filled
        ? (disabled ? Colors.grey.shade300 : lightBlue)
        : (disabled ? Colors.grey.shade100 : Colors.white);
    final Color fg = disabled ? Colors.grey.shade400 : primaryBlue;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filled ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required bool filled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: filled ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filled ? color.withOpacity(0.35) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PERFORMANCE ====================
  Widget _buildPerformanceCard() {
    final int quotaPct = (_quotaProgress * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statTile(
                  icon: Icons.directions_bus_rounded,
                  label: "TODAY'S TRIPS",
                  value: '$_tripsCompleted',
                  suffix: ' / $_dailyTarget',
                ),
              ),
              Container(width: 1, height: 56, color: Colors.grey.shade200),
              Expanded(
                child: _statTile(
                  icon: Icons.payments_rounded,
                  label: 'GROSS REVENUE',
                  value: 'Br. ${_grossRevenue.toStringAsFixed(0)}',
                  suffix: ' ETB',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Daily Quota Progress',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              Text(
                '$quotaPct%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _quotaProgress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: lightBlue,
              valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required String suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: primaryBlue),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                    height: 1,
                  ),
                ),
              ),
              Text(
                suffix,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== TRAFFIC ALERTS ====================
  Widget _buildTrafficAlertsCard() {
    return Column(
      children: [
        _alertTile(
          icon: Icons.warning_amber_rounded,
          iconColor: warningOrange,
          title: 'Heavy bottleneck',
          message: 'Reported at Gotera Interchange (~12 min delay).',
          accent: warningOrange,
        ),
        const SizedBox(height: 8),
        _alertTile(
          icon: Icons.lightbulb_outline_rounded,
          iconColor: successGreen,
          title: 'Suggested alternative',
          message: 'Detour via Ring Road Exit 3.',
          accent: successGreen,
        ),
      ],
    );
  }

  Widget _alertTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SAFETY ACTIONS ====================
  Widget _buildSafetyActions() {
    return Row(
      children: [
        Expanded(
          child: _safetyButton(
            icon: Icons.report_problem_rounded,
            label: 'REPORT INCIDENT',
            color: dangerRed,
            onTap: _reportIncident,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _safetyButton(
            icon: Icons.phone_in_talk_rounded,
            label: 'DISPATCH HOTLINE',
            color: successGreen,
            onTap: _callDispatch,
          ),
        ),
      ],
    );
  }

  Widget _safetyButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: color,
              ),
            ),
          ],
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

  void _proceedToBoardingGate() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Proceed to boarding gate?'),
        content: Text(
          'Head to $_gateNumber at $_assignedHub. '
          'Your queue position will be released once passengers board.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _queuePosition = 1);
              _showSnack(
                'Marked as proceeding to boarding gate',
                color: primaryBlue,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  void _requestBreak() {
    _showSnack('Break request sent to dispatch', color: warningOrange);
  }

  void _incrementSeats() {
    if (_seatsOpen >= _totalSeats) return;
    setState(() => _seatsOpen = (_seatsOpen + 1).clamp(0, _totalSeats));
  }

  void _decrementSeats() {
    if (_seatsOpen <= 0) return;
    setState(() => _seatsOpen = (_seatsOpen - 1).clamp(0, _totalSeats));
    if (_seatsOpen == 0) _showSnack('Bus is now FULL', color: dangerRed);
  }

  void _markBusFull() {
    if (_seatsOpen == 0) {
      _showSnack('Bus is already marked full', color: dangerRed);
      return;
    }
    setState(() => _seatsOpen = 0);
    _showSnack('Bus marked FULL — ready for departure', color: dangerRed);
  }

  void _resetForReturnTrip() {
    setState(() => _seatsOpen = _totalSeats);
    _showSnack(
      'Reset for return trip — $_totalSeats seats open',
      color: primaryBlue,
    );
  }

  void _reportIncident() {
    _showSnack(
      'Incident reported — dispatch has been notified',
      color: dangerRed,
    );
  }

  void _callDispatch() {
    _showSnack('Calling dispatch hotline…', color: successGreen);
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
}