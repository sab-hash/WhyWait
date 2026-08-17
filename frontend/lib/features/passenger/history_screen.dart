import 'package:flutter/material.dart';
import 'trip_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedTab = 0;

  final List<String> tabs = [
    'All',
    'Completed',
    'Cancelled',
  ];

  final List<Map<String, String>> trips = [
    {
      'date': 'Today',
      'from': 'Bole',
      'to': 'Mexico Square',
      'time': '10:30 AM',
      'price': 'ETB 250',
      'status': 'Completed',
    },
    {
      'date': 'Today',
      'from': 'Kazanchis',
      'to': 'Piassa',
      'time': '1:15 PM',
      'price': 'ETB 180',
      'status': 'Completed',
    },
    {
      'date': 'Yesterday',
      'from': 'CMC',
      'to': 'Bole',
      'time': '9:20 AM',
      'price': 'ETB 300',
      'status': 'Completed',
    },
    {
      'date': 'Yesterday',
      'from': 'Sarbet',
      'to': 'Megenagna',
      'time': '4:45 PM',
      'price': 'ETB 220',
      'status': 'Cancelled',
    },
  ];

  List<Map<String, String>> get filteredTrips {
    if (selectedTab == 0) {
      return trips;
    }

    final status = selectedTab == 1
        ? 'Completed'
        : 'Cancelled';

    return trips
        .where((trip) => trip['status'] == status)
        .toList();
  }

  List<Map<String, String>> get todayTrips {
    return filteredTrips
        .where((trip) => trip['date'] == 'Today')
        .toList();
  }

  List<Map<String, String>> get yesterdayTrips {
    return filteredTrips
        .where((trip) => trip['date'] == 'Yesterday')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              _buildHeader(),

              const SizedBox(height: 25),

              _buildTabs(),

              const SizedBox(height: 25),

              Expanded(
                child: filteredTrips.isEmpty
                    ? _buildEmptyState()
                    : _buildTripList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 8),
        const Text(
          'Trip History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) {
            final isSelected = selectedTab == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTab = index;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFC107)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.black
                          : Colors.grey[600],
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

  Widget _buildTripList() {
    return ListView(
      children: [
        if (todayTrips.isNotEmpty) ...[
          const Text(
            'Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...todayTrips.map(
            (trip) => _buildTripCard(trip),
          ),
        ],

        if (yesterdayTrips.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            'Yesterday',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...yesterdayTrips.map(
            (trip) => _buildTripCard(trip),
          ),
        ],

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTripCard(Map<String, String> trip) {
    final isCancelled = trip['status'] == 'Cancelled';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TripDetailsScreen(trip: trip),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
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
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107)
                        .withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_taxi,
                    color: Color(0xFFFFC107),
                    size: 25,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip['from']} → ${trip['to']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        trip['time']!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  trip['price']!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Divider(height: 1),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  isCancelled
                      ? Icons.cancel
                      : Icons.check_circle,
                  color: isCancelled
                      ? Colors.red
                      : Colors.green,
                  size: 18,
                ),

                const SizedBox(width: 6),

                Text(
                  trip['status']!,
                  style: TextStyle(
                    color: isCancelled
                        ? Colors.red
                        : Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                const Text(
                  'View details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFA000),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;

    if (selectedTab == 1) {
      title = 'No completed trips';
    } else if (selectedTab == 2) {
      title = 'No cancelled trips';
    } else {
      title = 'No trips yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107)
                  .withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history,
              size: 45,
              color: Color(0xFFFFA000),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Your trip history will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}