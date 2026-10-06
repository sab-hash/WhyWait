import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../services/grpc_client.dart';
import '../../services/passenger_state.dart';
import 'report_screen.dart';
import 'route_planner_screen.dart';

class HomeScreen extends StatefulWidget {
  final String fullName;
  final String email;

  const HomeScreen({super.key, required this.fullName, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkText = Color(0xFF333333);
  static const Color accentYellow = Color(0xFFF59E0B);

  String currentLocation = 'Megenagna Terminal';
  String selectedStation = 'Megenagna Terminal';
  String stationDistance = '';
  String? _destination;
  String? _avatarUrl;

  String queueStatus = 'Moderate';
  int queueWaitMins = 15;
  String virtualToken = '#M114';
  int taxisEnRoute = 3;
  bool _tokenIssued = false;

  List<Map<String, dynamic>> _terminals = [];
  int _taxiCount = 0;
  int _nearbyCount = 0;
  int _avgWait = 0;
  bool _isLoading = true;
  bool _userChoseStation = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============ TIME-BASED GREETING ============
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  // ============ PEAK BADGE ============
  ({String label, IconData icon, Color color})? get _peakBadge {
    final h = DateTime.now().hour;
    if (h >= 7 && h < 10) {
      return (
        label: 'Morning Peak',
        icon: Icons.wb_sunny_rounded,
        color: accentYellow,
      );
    }
    if (h >= 17 && h < 20) {
      return (
        label: 'Evening Peak',
        icon: Icons.nights_stay_rounded,
        color: const Color(0xFF6366F1),
      );
    }
    return null;
  }

  String get _initials {
    final parts = widget.fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Color _queueColor() {
    if (queueWaitMins <= 5) return Colors.green;
    if (queueWaitMins <= 20) return accentYellow;
    return Colors.red;
  }

  // ============ LOAD DATA ============
  void _loadData() async {
    setState(() => _isLoading = true);

    try {
      final terminalsFuture = GrpcClient().getTerminals();
      final statusFuture = GrpcClient().getTaxiStatus();

      final terminals = await terminalsFuture;
      final status = await statusFuture;

      setState(() {
        _terminals = terminals.terminals
            .map((t) => {
                  'id': t.id,
                  'name': t.name,
                  'latitude': t.latitude,
                  'longitude': t.longitude,
                  'address': t.address,
                  'city': t.city,
                  'distance': 1.2,
                })
            .toList();

        if (!_userChoseStation && _terminals.isNotEmpty) {
          final nearest = _terminals.reduce((a, b) =>
              (a['distance'] as num) <= (b['distance'] as num) ? a : b);
          selectedStation = nearest['name'] ?? 'Megenagna Terminal';
          currentLocation = selectedStation;
          stationDistance =
              '${(nearest['distance'] as num).toStringAsFixed(1)} km away';
        }

        _taxiCount = status.available;
        _nearbyCount = status.nearbyStations;
        _avgWait = status.averageWait;
        queueWaitMins = status.averageWait;
        taxisEnRoute = status.available > 3 ? 3 : status.available;

        _isLoading = false;
      });

      PassengerState().terminals = _terminals;
      PassengerState().selectedStation = selectedStation;
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 22),
              _buildDestinationSection(),
              const SizedBox(height: 20),
              _buildCorridorMapPreview(),
              const SizedBox(height: 20),
              _buildQueueAndToken(),
              const SizedBox(height: 18),
              _buildMidRoutePickup(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportScreen()),
          );
        },
        backgroundColor: primaryBlue,
        child: const Icon(Icons.report_problem_outlined, color: Colors.white),
      ),
    );
  }

  // ================= TOP BAR =================
  Widget _buildTopBar() {
    final peak = _peakBadge;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
        ),
        if (peak != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: peak.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: peak.color.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(peak.icon, size: 14, color: peak.color),
                const SizedBox(width: 4),
                Text(
                  peak.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: peak.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryBlue, width: 2),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                  ? Image.network(
                      _avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(),
                    )
                  : _avatarFallback(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: primaryBlue,
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= DESTINATION & QUICK SEARCH =================
  Widget _buildDestinationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('DESTINATION & QUICK SEARCH'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current location
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.my_location_rounded,
                        size: 18, color: primaryBlue),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentLocation,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Search
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RoutePlannerScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: primaryBlue, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _destination ??
                              'Where are you heading? e.g., Mexico, Bole',
                          style: TextStyle(
                            fontSize: 13,
                            color: _destination == null
                                ? Colors.grey.shade500
                                : darkText,
                            fontWeight: _destination == null
                                ? FontWeight.w500
                                : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Quick chips
              Row(
                children: [
                  Expanded(
                    child: _quickChip(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      onTap: () => setState(() => _destination = 'Home'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _quickChip(
                      icon: Icons.work_rounded,
                      label: 'Work',
                      onTap: () => setState(() => _destination = 'Work'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _quickChip(
                      icon: Icons.school_rounded,
                      label: 'Campus',
                      onTap: () => setState(() => _destination = 'Campus'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: lightBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: primaryBlue),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CORRIDOR MAP PREVIEW =================
  Widget _buildCorridorMapPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('INTEGRATED LIVE CORRIDOR MAP'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Map preview area
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18)),
                ),
                child: Stack(
                  children: [
                    // Faux corridor line
                    Positioned(
                      left: 30,
                      right: 30,
                      top: 80,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Megenagna hub (left)
                    Positioned(
                      left: 20,
                      top: 62,
                      child: _hubMarker(
                        color: accentYellow,
                        label: 'Megenagna',
                        sub: 'Hub',
                      ),
                    ),
                    // Middle taxis
                    Positioned(
                      left: 110,
                      top: 66,
                      child: _taxiDot(),
                    ),
                    Positioned(
                      left: 160,
                      top: 66,
                      child: _taxiDot(),
                    ),
                    // Mexico hub (right)
                    Positioned(
                      right: 20,
                      top: 62,
                      child: _hubMarker(
                        color: Colors.green,
                        label: 'Mexico',
                        sub: 'Hub',
                      ),
                    ),
                    // Map icon top-right
                    const Positioned(
                      right: 12,
                      top: 12,
                      child: Icon(Icons.map_rounded,
                          color: primaryBlue, size: 20),
                    ),
                  ],
                ),
              ),
              // Expand / Recenter row
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: _mapAction(
                        icon: Icons.zoom_out_map_rounded,
                        label: 'Expand Full Map',
                        onTap: () => _showSnack('Opening full map...'),
                        filled: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _mapAction(
                        icon: Icons.my_location_rounded,
                        label: 'Recenter GPS',
                        onTap: () => _showSnack('Recentered to your location'),
                        filled: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hubMarker({
    required Color color,
    required String label,
    required String sub,
  }) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        Text(
          sub,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _taxiDot() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 3,
          ),
        ],
      ),
      child: const Icon(Icons.local_taxi_rounded,
          size: 14, color: primaryBlue),
    );
  }

  Widget _mapAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: filled ? primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: filled ? Colors.white : primaryBlue,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= QUEUE & VIRTUAL TOKEN =================
  Widget _buildQueueAndToken() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('SELECTED HUB QUEUE & VIRTUAL TOKEN'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hub row
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.location_on_rounded,
                              color: primaryBlue, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedStation,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _changeStation,
                    icon: const Icon(Icons.refresh_rounded,
                        size: 14, color: Colors.white),
                    label: const Text(
                      'Change Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Queue density
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _queueColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Queue Density:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$queueStatus (~$queueWaitMins min wait)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Token + track buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_tokenIssued) {
                          _showSnack('You already have token $virtualToken');
                          return;
                        }
                        setState(() => _tokenIssued = true);
                        _showSnack('Virtual token $virtualToken issued');
                      },
                      icon: const Icon(Icons.confirmation_number_rounded,
                          size: 16),
                      label: Text(
                        _tokenIssued
                            ? 'TOKEN $virtualToken'
                            : 'GET VIRTUAL TOKEN',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryBlue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showSnack('Tracking boarding time...'),
                      icon: const Icon(Icons.timer_outlined,
                          size: 16, color: Colors.white),
                      label: const Text(
                        'Track Boarding',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= MID-ROUTE PICKUP =================
  Widget _buildMidRoutePickup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('MID-ROUTE PICKUP · BOARD ON-THE-LINE'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: primaryBlue.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_walk_rounded,
                        color: primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Standing between terminals along the corridor?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showSnack(
                          'Pickup node signalled. Driver notified.'),
                      icon: const Icon(Icons.add_location_alt_rounded,
                          size: 16),
                      label: const Text(
                        'Signal Pickup Node',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryBlue,
                        side: BorderSide(
                            color: primaryBlue.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_taxi_rounded,
                            size: 14, color: primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          '$taxisEnRoute en route',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= HELPERS =================
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: primaryBlue,
        letterSpacing: 1.2,
      ),
    );
  }

  // ================= CHANGE STATION =================
  void _changeStation() {
    if (_terminals.isEmpty) {
      _showSnack('No terminals available');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Select Hub',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 15),
              ..._terminals.map((terminal) {
                final stationName = terminal['name'] ?? 'Unknown';
                final isSelected = stationName == selectedStation;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on_rounded,
                        color: primaryBlue, size: 21),
                  ),
                  title: Text(
                    stationName,
                    style: const TextStyle(
                      color: darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: primaryBlue)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedStation = stationName;
                      currentLocation = stationName;
                      stationDistance =
                          '${(terminal['distance'] ?? 1.2).toStringAsFixed(1)} km away';
                      _userChoseStation = true;
                      PassengerState().selectedStation = selectedStation;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}