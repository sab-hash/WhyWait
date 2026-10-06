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

  String currentLocation = 'Megenagna Hub';
  String selectedStation = 'Megenagna Terminal';
  String stationDistance = '';
  String? _destination;
  String? _avatarUrl;
  String queueStatus = 'Moderate';
  int queueWaitMins = 15;
  bool _isPeakHour = false;

  List<Map<String, dynamic>> _terminals = [];
  int _taxiCount = 0;
  int _nearbyCount = 0;
  int _avgWait = 0;
  List<Map<String, dynamic>> _popularRoutes = [];
  bool _isLoading = true;
  bool _userChoseStation = false;

  @override
  void initState() {
    super.initState();
    _updatePeakHour();
    _loadData();
  }

  void _updatePeakHour() {
    final h = DateTime.now().hour;
    _isPeakHour = (h >= 7 && h <= 9) || (h >= 17 && h <= 19);
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
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

  void _loadData() async {
    setState(() => _isLoading = true);

    try {
      final terminalsFuture = GrpcClient().getTerminals();
      final statusFuture = GrpcClient().getTaxiStatus();
      final routesFuture = GrpcClient().getPopularRoutes();

      final terminals = await terminalsFuture;
      final status = await statusFuture;
      final routes = await routesFuture;

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
          selectedStation = nearest['name'] ?? 'Unknown';
          stationDistance =
              '${(nearest['distance'] as num).toStringAsFixed(1)} km away';
        }

        _taxiCount = status.available;
        _nearbyCount = status.nearbyStations;
        _avgWait = status.averageWait;
        queueWaitMins = status.averageWait;

        _popularRoutes = routes.routes
            .map((r) => {
                  'from': r.from,
                  'to': r.to,
                  'waitTime': r.waitTime,
                  'fare': 15,
                })
            .toList();

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
              _buildLocationSearchSection(),
              const SizedBox(height: 22),
              _buildStationRadar(),
              const SizedBox(height: 18),
              _buildRecommendedCorridor(),
              const SizedBox(height: 18),
              _buildBoardOnTheLine(),
              const SizedBox(height: 18),
              _buildCrowdAlerts(),
              const SizedBox(height: 14),
              _buildQuickFarePay(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TOP BAR =================
  Widget _buildTopBar() {
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
        if (_isPeakHour)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accentYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentYellow.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up_rounded, size: 14, color: accentYellow),
                const SizedBox(width: 4),
                Text(
                  'Peak Hour',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentYellow,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 10),
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

  // ================= LOCATION + SEARCH + SHORTCUTS =================
  Widget _buildLocationSearchSection() {
    return Container(
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
                        fontSize: 15,
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RoutePlannerScreen()),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
                      _destination ?? 'Where to? Enter destination',
                      style: TextStyle(
                        fontSize: 14,
                        color: _destination == null
                            ? Colors.grey.shade600
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

  // ================= STATION RADAR =================
  Widget _buildStationRadar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STATION RADAR',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
            letterSpacing: 1.2,
          ),
        ),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedStation,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                stationDistance.isEmpty
                                    ? 'Nearest to you'
                                    : stationDistance,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _changeStation,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
                      'Queue:',
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showSnack('Virtual token issued. Show at the terminal.'),
                  icon: const Icon(Icons.confirmation_number_rounded, size: 18),
                  label: const Text(
                    'Get Virtual Token',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= RECOMMENDED CORRIDOR =================
  Widget _buildRecommendedCorridor() {
    final route = _popularRoutes.isNotEmpty
        ? _popularRoutes.first
        : {'from': 'Megenagna', 'to': 'Mexico', 'waitTime': 4};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECOMMENDED CORRIDOR',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
            letterSpacing: 1.2,
          ),
        ),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${route['from']} ➔ ${route['to']} via Bole Road',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showRouteSuggestions,
                    child: const Icon(Icons.alt_route_rounded,
                        color: primaryBlue, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _statBlock(
                      icon: Icons.access_time_rounded,
                      label: 'Next',
                      value: '${route['waitTime'] ?? 4} min',
                    ),
                  ),
                  _vDivider(),
                  Expanded(
                    child: _statBlock(
                      icon: Icons.local_taxi_rounded,
                      label: 'Taxis',
                      value: '$_taxiCount',
                    ),
                  ),
                  _vDivider(),
                  Expanded(
                    child: _statBlock(
                      icon: Icons.payments_outlined,
                      label: 'Fare',
                      value: '${route['fare'] ?? 15} ETB',
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

  Widget _statBlock({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: primaryBlue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _vDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.shade200);
  }

  // ================= BOARD ON-THE-LINE =================
  Widget _buildBoardOnTheLine() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BOARD ON-THE-LINE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
            letterSpacing: 1.2,
          ),
        ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mid-Route Hop-On',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Standing along the route?',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showSnack(
                      'Pickup node requested. Awaiting conductor.'),
                  icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                  label: const Text(
                    'Request Pickup Node',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: BorderSide(color: primaryBlue.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= CROWD ALERTS =================
  Widget _buildCrowdAlerts() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: Color(0xFFB45309), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF78350F),
                  height: 1.35,
                ),
                children: [
                  TextSpan(
                    text: 'Tip: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'Stadium Hub queue is 10 mins faster right now',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= QUICK FARE PAY =================
  Widget _buildQuickFarePay() {
    return GestureDetector(
      onTap: () => _showSnack('Opening QR scanner...'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.qr_code_scanner_rounded,
                  color: primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Quick Fare Pay',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
            ),
            const Text(
              'Scan QR',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: primaryBlue, size: 20),
          ],
        ),
      ),
    );
  }

  // ================= ROUTE SUGGESTIONS =================
  void _showRouteSuggestions() {
    final suggestions = [
      {
        'title': 'Direct from $selectedStation',
        'sub': 'Fixed line · no transfers',
        'note': 'Traffic heavy on Bole Road',
        'eta': '25 min',
        'fare': '15 ETB',
        'tag': 'Slowest',
        'tagColor': Colors.orange,
      },
      {
        'title': 'Via Meskel Square Station',
        'sub': 'Walk 300m → line taxi → final stop',
        'note': 'Avoids the main road',
        'eta': '15 min',
        'fare': '12 ETB',
        'tag': 'Recommended',
        'tagColor': Colors.green,
      },
      {
        'title': 'Via Piassa Station (backroad)',
        'sub': 'Line taxi → short walk',
        'note': 'Less crowded at this hour',
        'eta': '18 min',
        'fare': '14 ETB',
        'tag': 'Alternative',
        'tagColor': primaryBlue,
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
              const SizedBox(height: 20),
              const Text(
                'Suggested Corridors',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Best options to your destination right now',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ...suggestions.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _suggestionCard(s),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _suggestionCard(Map<String, dynamic> s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  s['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (s['tagColor'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s['tag'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: s['tagColor'] as Color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s['sub'],
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            s['note'],
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 15, color: primaryBlue),
              const SizedBox(width: 4),
              Text(
                s['eta'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.payments_outlined,
                  size: 15, color: primaryBlue),
              const SizedBox(width: 4),
              Text(
                s['fare'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _destination = s['title'];
                    });
                    _showSnack('Selected: ${s['title']}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Take this',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
                'Select Station',
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