import 'package:flutter/material.dart';

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  int selectedFilter = 0;

  final List<Map<String, dynamic>> trips = [
    {
      'date': 'Today',
      'from': 'Mexico',
      'to': 'Bole',
      'fare': 180,
      'time': '8:45 AM',
      'passengers': 3,
      'rating': 4.9,
      'distance': 4.2,
    },
    {
      'date': 'Today',
      'from': 'Bole',
      'to': 'Kazanchis',
      'fare': 150,
      'time': '10:20 AM',
      'passengers': 2,
      'rating': 5.0,
      'distance': 3.6,
    },
    {
      'date': 'Today',
      'from': 'Kazanchis',
      'to': 'Mexico',
      'fare': 170,
      'time': '11:45 AM',
      'passengers': 4,
      'rating': 4.8,
      'distance': 4.8,
    },
    {
      'date': 'Today',
      'from': 'Mexico',
      'to': 'Piassa',
      'fare': 200,
      'time': '1:15 PM',
      'passengers': 3,
      'rating': 4.7,
      'distance': 5.1,
    },
    {
      'date': 'Today',
      'from': 'Piassa',
      'to': 'Bole',
      'fare': 160,
      'time': '2:40 PM',
      'passengers': 2,
      'rating': 4.9,
      'distance': 4.0,
    },
    {
      'date': 'Today',
      'from': 'Bole',
      'to': 'Sar Bet',
      'fare': 120,
      'time': '4:10 PM',
      'passengers': 3,
      'rating': 4.6,
      'distance': 3.2,
    },
    {
      'date': 'Today',
      'from': 'Sar Bet',
      'to': 'Mexico',
      'fare': 140,
      'time': '5:25 PM',
      'passengers': 2,
      'rating': 5.0,
      'distance': 3.7,
    },
    {
      'date': 'Today',
      'from': 'Mexico',
      'to': 'Bole',
      'fare': 160,
      'time': '6:45 PM',
      'passengers': 3,
      'rating': 4.8,
      'distance': 3.6,
    },
    {
      'date': 'Yesterday',
      'from': 'Bole',
      'to': 'Mexico',
      'fare': 175,
      'time': '8:30 AM',
      'passengers': 3,
      'rating': 4.9,
      'distance': 4.1,
    },
    {
      'date': 'Yesterday',
      'from': 'Mexico',
      'to': 'Kazanchis',
      'fare': 145,
      'time': '10:05 AM',
      'passengers': 2,
      'rating': 4.7,
      'distance': 3.4,
    },
    {
      'date': 'Yesterday',
      'from': 'Kazanchis',
      'to': 'Piassa',
      'fare': 155,
      'time': '12:20 PM',
      'passengers': 4,
      'rating': 4.8,
      'distance': 3.9,
    },
    {
      'date': 'Yesterday',
      'from': 'Piassa',
      'to': 'Bole',
      'fare': 190,
      'time': '3:15 PM',
      'passengers': 3,
      'rating': 5.0,
      'distance': 4.7,
    },
  ];

  List<Map<String, dynamic>> get filteredTrips {
    if (selectedFilter == 0) {
      return trips.where((trip) {
        return trip['date'] == 'Today';
      }).toList();
    }

    if (selectedFilter == 1) {
      return trips;
    }

    return trips;
  }

  int get totalTrips {
    return filteredTrips.length;
  }

  int get totalEarnings {
    return filteredTrips.fold(
      0,
      (sum, trip) => sum + (trip['fare'] as int),
    );
  }

  double get averageRating {
    if (filteredTrips.isEmpty) {
      return 0;
    }

    final total = filteredTrips.fold<double>(
      0,
      (sum, trip) => sum + (trip['rating'] as double),
    );

    return total / filteredTrips.length;
  }

  double get totalDistance {
    return filteredTrips.fold<double>(
      0,
      (sum, trip) => sum + (trip['distance'] as double),
    );
  }

  String get summaryTitle {
    if (selectedFilter == 0) {
      return "Today's Summary";
    }

    if (selectedFilter == 1) {
      return "This Week's Summary";
    }

    return "All Time Summary";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Trip History',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF1565C0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 20),
              _buildFilterTabs(),
              const SizedBox(height: 24),
              _buildHistoryHeader(),
              const SizedBox(height: 12),
              _buildTripList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.18),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summaryTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Earnings',
                  value: '$totalEarnings ETB',
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.directions_car_outlined,
                  label: 'Trips',
                  value: '$totalTrips',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.star_outline,
                  label: 'Rating',
                  value: averageRating.toStringAsFixed(1),
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.route_outlined,
                  label: 'Distance',
                  value: '${totalDistance.toStringAsFixed(1)} km',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
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
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    const filters = [
      'Today',
      'This week',
      'All time',
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: List.generate(
          filters.length,
          (index) {
            final selected = selectedFilter == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFilter = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF1565C0)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    filters[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(0xFF6B7280),
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Trips',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$totalTrips trips',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTripList() {
    if (filteredTrips.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.history,
              size: 45,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 12),
            Text(
              'No trips found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final widgets = <Widget>[];
    String? previousDate;

    for (final trip in filteredTrips) {
      if (trip['date'] != previousDate) {
        previousDate = trip['date'];

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(
              top: 4,
              bottom: 10,
            ),
            child: Text(
              trip['date'],
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTripCard(trip),
        ),
      );
    }

    return Column(
      children: widgets,
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final rating = trip['rating'] as double;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9EDF2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.route,
                  color: Color(0xFF1565C0),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trip['from']} → ${trip['to']}',
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trip['time'],
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.people_outline,
                          size: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${trip['passengers']} passengers',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${trip['fare']} ETB',
                style: const TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: const Color(0xFFF0F2F5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.route_outlined,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 5),
              Text(
                '${trip['distance']} km',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.star,
                size: 17,
                color: Color(0xFFFFB300),
              ),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: false,
              ),
              _buildNavItem(
                icon: Icons.map_outlined,
                label: 'Map',
                selected: false,
              ),
              _buildNavItem(
                icon: Icons.history,
                label: 'History',
                selected: true,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected
                  ? const Color(0xFF1565C0)
                  : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF1565C0)
                    : const Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}