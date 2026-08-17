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
  static const Color darkText = Color(0xFF172B4D);

  final List<Map<String, dynamic>> trips = [
    {
      'date': 'Today',
      'from': 'Bole',
      'to': 'Mexico Square',
      'time': '10:30 AM',
      'fare': 'ETB 35',
      'legs': [
        {
          'type': 'Taxi',
          'from': 'Bole',
          'to': 'Mexico Square',
          'fare': 'ETB 35',
        },
      ],
    },
    {
      'date': 'Today',
      'from': 'CMC',
      'to': 'Piassa',
      'time': '1:15 PM',
      'fare': 'ETB 45',
      'legs': [
        {
          'type': 'Minibus',
          'from': 'CMC',
          'to': 'Megenagna',
          'fare': 'ETB 25',
        },
        {
          'type': 'Taxi',
          'from': 'Megenagna',
          'to': 'Piassa',
          'fare': 'ETB 20',
        },
      ],
    },
    {
      'date': 'Yesterday',
      'from': 'Sarbet',
      'to': 'Bole',
      'time': '9:20 AM',
      'fare': 'ETB 20',
      'legs': [
        {
          'type': 'Minibus',
          'from': 'Sarbet',
          'to': 'Bole',
          'fare': 'ETB 20',
        },
      ],
    },
    {
      'date': 'Yesterday',
      'from': 'Kazanchis',
      'to': 'CMC',
      'time': '4:45 PM',
      'fare': 'ETB 40',
      'legs': [
        {
          'type': 'Taxi',
          'from': 'Kazanchis',
          'to': 'Megenagna',
          'fare': 'ETB 25',
        },
        {
          'type': 'Minibus',
          'from': 'Megenagna',
          'to': 'CMC',
          'fare': 'ETB 15',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get todayTrips {
    return trips
        .where((trip) => trip['date'] == 'Today')
        .toList();
  }

  List<Map<String, dynamic>> get yesterdayTrips {
    return trips
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
              const SizedBox(height: 28),
              const Text(
                'Your journeys',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'See the public transportation you used.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: trips.isEmpty
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
            color: darkText,
          ),
        ),
      ],
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
          const SizedBox(height: 10),
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
        color: darkText,
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final List<dynamic> legs = trip['legs'];

    final Set<String> transportTypes = legs
        .map<String>(
          (leg) => leg['type'] as String,
        )
        .toSet();

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
        margin: const EdgeInsets.only(bottom: 15),
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
                    Icons.directions_transit,
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
                          color: darkText,
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
                            trip['time'],
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
                  trip['fare'],
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
                const Icon(
                  Icons.directions_car_outlined,
                  size: 17,
                  color: primeBlue,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _transportText(
                      transportTypes,
                      legs.length,
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primeBlue,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.chevron_right,
                  color: primeBlue,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _transportText(
    Set<String> types,
    int numberOfLegs,
  ) {
    if (numberOfLegs == 1) {
      return types.first;
    }

    return '$numberOfLegs vehicles · ${types.join(' + ')}';
  }

  Widget _buildEmptyState() {
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
              Icons.directions_transit,
              size: 46,
              color: primeBlue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No journeys yet',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your public transportation history will appear here.',
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