import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'report_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'live_tracking_screen.dart';

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

  int selectedIndex = 0;

  String selectedStation = 'Bole Taxi Station';
  String stationDistance = '1.2 km away';

  List<dynamic> _terminals = [];
  int _taxiCount = 0;
  int _nearbyCount = 0;
  int _avgWait = 0;
  List<dynamic> _popularRoutes = [];
    bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

   Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final terminals = await ApiService.getTerminals();
      final status = await ApiService.getTaxiStatus();
      final routes = await ApiService.getPopularRoutes();

      if (!mounted) return;

      setState(() {
        _terminals = terminals;
        _taxiCount = status['available'] ?? 0;
        _nearbyCount = status['nearby_stations'] ?? 0;
        _avgWait = status['average_wait'] ?? 0;
        _popularRoutes = routes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
            body: SafeArea(
        child: _error != null
            ? _buildErrorState()
            : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildSearchBar(),
                        const SizedBox(height: 18),
                        _buildStationCard(),
                        const SizedBox(height: 20),
                        _buildSummaryCards(),
                        const SizedBox(height: 28),
                        _buildPopularRoutes(),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportScreen()),
          );
        },
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.report_problem_outlined),
        label: const Text('Report', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning,',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.fullName}!',
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: primaryBlue, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 27,
              color: primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Container(
      height: 58,
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
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Where are you going?',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: primaryBlue,
            size: 25,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune_rounded, color: primaryBlue, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  // ==================== STATION CARD ====================
  Widget _buildStationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: primaryBlue,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR STATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  selectedStation,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  stationDistance,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _changeStation,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Change',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SUMMARY CARDS ====================
  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.local_taxi_rounded,
            value: _isLoading ? '...' : '$_taxiCount',
            label: 'Taxis\navailable',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            icon: Icons.location_city_rounded,
            value: _isLoading ? '...' : '$_nearbyCount',
            label: 'Nearby\nstations',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            icon: Icons.access_time_rounded,
            value: _isLoading ? '...' : '~$_avgWait min',
            label: 'Average\nwaiting',
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      height: 137,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: primaryBlue, size: 21),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.25,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== POPULAR ROUTES ====================
  Widget _buildPopularRoutes() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_popularRoutes.isEmpty) {
      return const Center(child: Text('No popular routes available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'POPULAR ROUTES',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
                letterSpacing: 0.8,
              ),
            ),
                        TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'View all',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._popularRoutes.map((route) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _routeCard(
              from: route['from'] ?? 'Unknown',
              to: route['to'] ?? 'Unknown',
              waitTime: '~${route['waitTime'] ?? 5} min',
            ),
          );
        }),
      ],
    );
  }

  Widget _routeCard({
    required String from,
    required String to,
    required String waitTime,
  }) {
    return GestureDetector(
      onTap: () {
        _showRouteDetails(from: from, to: to, waitTime: waitTime);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.local_taxi_rounded,
                color: primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      from,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: primaryBlue,
                      size: 16,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      to,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.access_time_rounded,
              size: 15,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Text(
              waitTime,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.chevron_right_rounded,
              color: primaryBlue,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BOTTOM NAVIGATION ====================
  Widget _buildBottomNavigation() {
    return Container(
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                index: 0,
              ),
              _navItem(
                icon: Icons.location_on_outlined,
                activeIcon: Icons.location_on_rounded,
                label: 'Track',
                index: 1,
              ),
              _navItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'Trips',
                index: 2,
              ),
              _navItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          selectedIndex = index;
        });

        // Tab 1 — Track → Live Tracking
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TrackScreen(),
            ),
          ).then((_) {
            if (mounted) setState(() => selectedIndex = 0);
          });
          return;
        }

        // Tab 2 — Trips → History screen
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HistoryScreen(),
            ),
          ).then((_) {
            if (mounted) setState(() => selectedIndex = 0);
          });
          return;
        }

        // Tab 3 — Profile
        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileScreen(
                fullName: widget.fullName,
                phoneNumber: widget.email,
              ),
            ),
          ).then((_) {
            if (mounted) setState(() => selectedIndex = 0);
          });
          return;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? primaryBlue : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? primaryBlue : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CHANGE STATION ====================
  void _changeStation() {
    if (_terminals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No terminals available'),
          backgroundColor: Colors.red,
        ),
      );
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
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: primaryBlue,
                      size: 21,
                    ),
                  ),
                  title: Text(
                    stationName,
                    style: const TextStyle(
                      color: darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: primaryBlue,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      selectedStation = stationName;
                      stationDistance =
                          '${(terminal['distance'] ?? 1.2).toStringAsFixed(1)} km away';
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

  // ==================== ROUTE DETAILS ====================
  void _showRouteDetails({
    required String from,
    required String to,
    required String waitTime,
  }) {
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
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  color: primaryBlue,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$from → $to',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '$waitTime waiting time',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You joined the $from → $to queue'),
                        backgroundColor: primaryBlue,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Join Queue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
    Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Could not load data. Check your connection.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}