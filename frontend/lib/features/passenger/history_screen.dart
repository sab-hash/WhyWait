import 'package:flutter/material.dart';
import 'trip_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color primeBlue = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xFFF7F9FC);

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
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),

              _buildHeader(),

              const SizedBox(height: 24),

              _buildTabs(),

              const SizedBox(height: 24),

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
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: primeBlue,
            ),
          ),
        ),

        const SizedBox(width: 14),

        const Text(
          'Trip History',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172B4D),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) {
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
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primeBlue
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
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
                          ? Colors.white
                          : const Color(0xFF718096),
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
      physics: const BouncingScrollPhysics(),
      children: [
        if (todayTrips.isNotEmpty) ...[
          _buildSectionTitle('Today'),

          const SizedBox(height: 12),

          ...todayTrips.map(
            (trip) => _buildTripCard(trip),
          ),
        ],

        if (yesterdayTrips.isNotEmpty) ...[
          const SizedBox(height: 8),

          _buildSectionTitle('Yesterday'),

          const SizedBox(height: 12),

          ...yesterdayTrips.map(
            (trip) => _buildTripCard(trip),
          ),
        ],

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF172B4D),
      ),
    );
  }

  Widget _buildTripCard(Map<String, String> trip) {
    final bool isCancelled = trip['status'] == 'Cancelled';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailsScreen(
              trip: trip,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primeBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.local_taxi,
                    color: primeBlue,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 13),

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
                          color: Color(0xFF172B4D),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),

                          const SizedBox(width: 4),

                          Text(
                            trip['time']!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Text(
                  trip['price']!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primeBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Divider(
              height: 1,
              color: Colors.grey[200],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? Colors.red.withValues(alpha: 0.08)
                        : Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCancelled
                            ? Icons.cancel
                            : Icons.check_circle,
                        color: isCancelled
                            ? Colors.red
                            : Colors.green,
                        size: 15,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        trip['status']!,
                        style: TextStyle(
                          color: isCancelled
                              ? Colors.red
                              : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    const Text(
                      'View details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primeBlue,
                      ),
                    ),

                    const SizedBox(width: 4),

                    const Icon(
                      Icons.chevron_right,
                      color: primeBlue,
                      size: 20,
                    ),
                  ],
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
            width: 95,
            height: 95,
            decoration: BoxDecoration(
              color: primeBlue.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history,
              size: 46,
              color: primeBlue,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172B4D),
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