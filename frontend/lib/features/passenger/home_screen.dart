import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const navy = Color(0xFF0F172A);
  static const yellow = Color(0xFFFACC15);
  static const softWhite = Color(0xFFF8FAFC);

  int selectedIndex = 0;

  String selectedStation = 'Bole Taxi Station';
  String stationDistance = '1.2 km away';

  final List<String> stations = [
    'Bole Taxi Station',
    'Piazza Taxi Station',
    'Megenagna Taxi Station',
    'Mexico Taxi Station',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 18),
              _buildStationCard(),
              const SizedBox(height: 22),
              _buildSummaryCards(),
              const SizedBox(height: 28),
              _buildPopularRoutes(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

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
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Rara!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
          ],
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: navy,
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.person_outline,
            size: 29,
            color: navy,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Where are you going?',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: navy,
            size: 27,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildStationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: yellow.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: navy,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR STATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  selectedStation,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  stationDistance,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _changeStation,
            style: OutlinedButton.styleFrom(
              foregroundColor: navy,
              side: const BorderSide(
                color: navy,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.local_taxi_outlined,
            value: '12',
            label: 'Taxis\navailable',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            icon: Icons.location_city_outlined,
            value: '4',
            label: 'Nearby\nstations',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            icon: Icons.access_time,
            value: '~8 min',
            label: 'Average\nwaiting time',
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
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: navy,
            size: 27,
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              height: 1.3,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRoutes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'POPULAR ROUTES',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: navy,
                letterSpacing: 0.5,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View all',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _routeCard(
          from: 'Bole',
          to: 'Piazza',
          waitTime: '~10 min wait',
        ),
        const SizedBox(height: 12),
        _routeCard(
          from: 'Bole',
          to: 'Megenagna',
          waitTime: '~7 min wait',
        ),
        const SizedBox(height: 12),
        _routeCard(
          from: 'Bole',
          to: 'Mexico',
          waitTime: '~9 min wait',
        ),
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
        _showRouteDetails(
          from: from,
          to: to,
          waitTime: waitTime,
        );
      },
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    from,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: navy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: yellow,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    to,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: navy,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.access_time,
              size: 17,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              waitTime,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.chevron_right,
              color: navy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
              ),
              _navItem(
                icon: Icons.location_on_outlined,
                activeIcon: Icons.location_on,
                label: 'Track',
                index: 1,
              ),
              _navItem(
                icon: Icons.description_outlined,
                activeIcon: Icons.description,
                label: 'Trips',
                index: 2,
              ),
              _navItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
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
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? navy : Colors.grey.shade500,
              size: 25,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? navy : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeStation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Station',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(height: 16),
              ...stations.map(
                (station) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: navy,
                    ),
                    title: Text(
                      station,
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: station == selectedStation
                        ? const Icon(
                            Icons.check_circle,
                            color: yellow,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        selectedStation = station;
                        stationDistance =
                            station == 'Bole Taxi Station'
                                ? '1.2 km away'
                                : '2.4 km away';
                      });

                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRouteDetails({
    required String from,
    required String to,
    required String waitTime,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: yellow.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_taxi,
                  size: 35,
                  color: navy,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '$from → $to',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                waitTime,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'You joined the $from → $to queue',
                        ),
                        backgroundColor: navy,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: navy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Join Queue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}