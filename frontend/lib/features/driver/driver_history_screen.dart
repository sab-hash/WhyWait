import 'package:flutter/material.dart';

class DriverTrip {
  final DateTime date;
  final String time;
  final String from;
  final String to;
  final int passengers;
  final int fare;

  const DriverTrip({
    required this.date,
    required this.time,
    required this.from,
    required this.to,
    required this.passengers,
    required this.fare,
  });
}

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  static const Color primeBlue = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xFFF7F9FC);

  int selectedTab = 0;

  final List<DriverTrip> trips = [
    DriverTrip(
      date: DateTime(2026, 8, 18),
      time: '08:30 AM',
      from: 'Bole',
      to: 'Megenagna',
      passengers: 10,
      fare: 300,
    ),
    DriverTrip(
      date: DateTime(2026, 8, 18),
      time: '11:15 AM',
      from: 'Megenagna',
      to: 'Piassa',
      passengers: 8,
      fare: 240,
    ),
    DriverTrip(
      date: DateTime(2026, 8, 17),
      time: '05:45 PM',
      from: 'Megenagna',
      to: 'Piassa',
      passengers: 12,
      fare: 360,
    ),
    DriverTrip(
      date: DateTime(2026, 8, 16),
      time: '02:15 PM',
      from: 'Piassa',
      to: 'Bole',
      passengers: 9,
      fare: 270,
    ),
    DriverTrip(
      date: DateTime(2026, 8, 15),
      time: '09:10 AM',
      from: 'Mexico',
      to: 'Megenagna',
      passengers: 11,
      fare: 330,
    ),
    DriverTrip(
      date: DateTime(2026, 8, 14),
      time: '06:20 PM',
      from: 'Bole',
      to: 'Mexico',
      passengers: 9,
      fare: 270,
    ),
    DriverTrip(
      date: DateTime(2026, 8, 12),
      time: '04:30 PM',
      from: 'Piassa',
      to: 'Megenagna',
      passengers: 12,
      fare: 360,
    ),
    DriverTrip(
      date: DateTime(2026, 8, 10),
      time: '08:50 AM',
      from: 'Bole',
      to: 'Piassa',
      passengers: 8,
      fare: 240,
    ),
    DriverTrip(
      date: DateTime(2026, 8, 7),
      time: '10:30 AM',
      from: 'Megenagna',
      to: 'Bole',
      passengers: 10,
      fare: 300,
    ),
  ];

  DateTime get today {
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
    );
  }

  DateTime get startOfWeek {
    return today.subtract(
      Duration(days: today.weekday - 1),
    );
  }

  List<DriverTrip> get filteredTrips {
    if (selectedTab == 0) {
      return trips.where((trip) {
        return _isSameDay(trip.date, today);
      }).toList();
    }

    if (selectedTab == 1) {
      return trips.where((trip) {
        return !trip.date.isBefore(startOfWeek);
      }).toList();
    }

    return trips;
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  int get totalPassengers {
    return filteredTrips.fold(
      0,
      (sum, trip) => sum + trip.passengers,
    );
  }

  int get totalEarnings {
    return filteredTrips.fold(
      0,
      (sum, trip) => sum + trip.fare,
    );
  }

  String get selectedTitle {
    if (selectedTab == 0) {
      return 'Today';
    }

    if (selectedTab == 1) {
      return 'This Week';
    }

    return 'All Trips';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primeBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Trip History',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabs(),
            _buildSummary(),
            Expanded(
              child: filteredTrips.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        4,
                        16,
                        24,
                      ),
                      itemCount: filteredTrips.length,
                      itemBuilder: (context, index) {
                        return _buildTripCard(
                          filteredTrips[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        8,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildTab(
            title: 'Today',
            index: 0,
          ),
          _buildTab(
            title: 'This Week',
            index: 1,
          ),
          _buildTab(
            title: 'All',
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required int index,
  }) {
    final bool isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? primeBlue
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        14,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.route_rounded,
              title: selectedTitle,
              value: '${filteredTrips.length}',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.people_alt_rounded,
              title: 'Passengers',
              value: '$totalPassengers',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.payments_rounded,
              title: 'Earnings',
              value: '$totalEarnings',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: primeBlue,
            size: 22,
          ),
          const SizedBox(height: 7),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(DriverTrip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primeBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  color: primeBlue,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(trip.date),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      trip.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${trip.fare} ETB',
                style: const TextStyle(
                  color: primeBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _buildRouteRow(
            icon: Icons.circle,
            iconSize: 9,
            title: 'From',
            location: trip.from,
          ),

          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(
              width: 1,
              height: 20,
              color: Colors.grey.shade300,
            ),
          ),

          _buildRouteRow(
            icon: Icons.location_on_rounded,
            iconSize: 18,
            title: 'To',
            location: trip.to,
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people_alt_outlined,
                  color: primeBlue,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  '${trip.passengers} passengers',
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 5),
                const Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow({
    required IconData icon,
    required double iconSize,
    required String title,
    required String location,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          child: Icon(
            icon,
            color: primeBlue,
            size: iconSize,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              location,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: primeBlue.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: primeBlue,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No trips found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'There are no completed trips for $selectedTitle.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}