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

  // ==================== ANALYTICS STATE ====================
  String _selectedMonth = 'Oct 2026';

    final List<CommuteShortcut> shortcuts = const [
    CommuteShortcut(
      icon: Icons.home_work_rounded,
      label: 'Home ➔ Work',
      from: 'Megenagna',
      to: 'Mexico',
    ),
    CommuteShortcut(
      icon: Icons.work_history_rounded,
      label: 'Work ➔ Home',
      from: 'Mexico',
      to: 'Megenagna',
    ),
  ];

      final List<Map<String, dynamic>> trips = [
    {
      'date': 'Today',
      'from': 'Bole',
      'to': 'Mexico Square',
      'time': '10:30 AM',
      'fare': 'ETB 35',
      'payment': 'Telebirr',
      'plate': 'AA-3-A12345',
      'association': 'Zone 1',
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
      'payment': 'Telebirr',
      'plate': 'AA-3-B67890',
      'association': 'Zone 2',
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
      'payment': 'CBE Birr',
      'plate': 'AA-3-C11223',
      'association': 'Zone 3',
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
      'payment': 'CBE Birr',
      'plate': 'AA-3-D44556',
      'association': 'Zone 1',
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

  // ==================== COMPUTED ANALYTICS ====================

  /// Total fare across all trips, parsed from strings like "ETB 35".
  double get _totalSpend {
    double sum = 0;
    for (final trip in trips) {
      final fareStr = trip['fare'] as String? ?? '';
      final digits = fareStr.replaceAll(RegExp(r'[^0-9.]'), '');
      sum += double.tryParse(digits) ?? 0;
    }
    return sum;
  }

  /// Minutes saved from using tokens.
  /// Placeholder: 15 minutes saved per trip until the backend provides real data.
  int get _timeSavedMinutes => trips.length * 15;

  /// Percent of trips that used at least one Taxi leg.
  int get _taxiPercent {
    if (trips.isEmpty) return 0;
    final taxiTrips = trips.where((trip) {
      final legs = trip['legs'] as List<dynamic>;
      return legs.any((leg) => leg['type'] == 'Taxi');
    }).length;
    return ((taxiTrips / trips.length) * 100).round();
  }

  /// Percent of trips that used at least one Minibus leg.
  int get _busPercent {
    if (trips.isEmpty) return 0;
    final busTrips = trips.where((trip) {
      final legs = trip['legs'] as List<dynamic>;
      return legs.any((leg) => leg['type'] == 'Minibus');
    }).length;
    return ((busTrips / trips.length) * 100).round();
  }

  String get _timeSavedDisplay {
    final hours = _timeSavedMinutes ~/ 60;
    final mins = _timeSavedMinutes % 60;
    return '$hours Hours $mins Mins';
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
              const SizedBox(height: 22),
              _buildSectionLabel('ONE-TAP COMMUTE SHORTCUTS'),
              const SizedBox(height: 10),
              ...shortcuts.map((s) => _buildShortcutCard(s)),
              const SizedBox(height: 22),
              _buildSectionLabel('MONTHLY IMPACT & SPEND'),
              const SizedBox(height: 10),
              _buildAnalyticsCard(),
              const SizedBox(height: 22),
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
        const Expanded(
          child: Text(
            'Trip History',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
        ),
        _buildMonthChip(),
      ],
    );
  }

  Widget _buildMonthChip() {
    return GestureDetector(
      onTap: _pickMonth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primeBlue.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: primeBlue,
            ),
            const SizedBox(width: 6),
            Text(
              _selectedMonth,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primeBlue,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: primeBlue,
            ),
          ],
        ),
      ),
    );
  }

    void _pickMonth() {
    const months = [
      'Jul 2026',
      'Aug 2026',
      'Sep 2026',
      'Oct 2026',
      'Nov 2026',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => Padding(
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
              'Select Month',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: primeBlue,
              ),
            ),
            const SizedBox(height: 15),
            ...months.map((m) {
              final isSelected = m == _selectedMonth;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primeBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: primeBlue,
                    size: 21,
                  ),
                ),
                title: Text(
                  m,
                  style: const TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: primeBlue,
                      )
                    : null,
                onTap: () {
                  setState(() => _selectedMonth = m);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

    Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        letterSpacing: 1,
        fontWeight: FontWeight.w800,
        color: primeBlue,
      ),
    );
  }

      Widget _buildShortcutCard(CommuteShortcut shortcut) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primeBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(shortcut.icon, color: primeBlue, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      shortcut.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${shortcut.from} ➔ ${shortcut.to}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _getTokenButton(shortcut),
        ],
      ),
    );
  }

  Widget _getTokenButton(CommuteShortcut shortcut) {
    return ElevatedButton(
      onPressed: () => _getTokenFor(shortcut),
      style: ElevatedButton.styleFrom(
        backgroundColor: primeBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.confirmation_number_rounded, size: 15),
          SizedBox(width: 5),
          Text(
            'Get Token',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  void _getTokenFor(CommuteShortcut shortcut) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Token issued: ${shortcut.from} ➔ ${shortcut.to}'),
          backgroundColor: primeBlue,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }
    Widget _buildAnalyticsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              Expanded(
                child: _analyticsTile(
                  icon: Icons.payments_rounded,
                  label: 'TOTAL SPEND',
                  value: 'Br. ${_totalSpend.toStringAsFixed(2)}',
                  suffix: ' ETB',
                  color: primeBlue,
                ),
              ),
              Container(width: 1, height: 56, color: Colors.grey.shade200),
              Expanded(
                child: _analyticsTile(
                  icon: Icons.access_time_rounded,
                  label: 'TIME SAVED',
                  value: _timeSavedDisplay,
                  suffix: '',
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
                    const SizedBox(height: 16),
                    _buildBreakdownBar(),
        ],
      ),
    );
  }

  Widget _analyticsTile({
    required IconData icon,
    required String label,
    required String value,
    required String suffix,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1,
                  ),
                ),
              ),
              if (suffix.isNotEmpty)
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

    Widget _buildBreakdownBar() {
    final int taxi = _taxiPercent.clamp(1, 100);
    final int bus = _busPercent.clamp(1, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Spending breakdown',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            Text(
              '$_taxiPercent% Taxi · $_busPercent% Bus',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: primeBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Expanded(
                flex: taxi,
                child: Container(height: 10, color: primeBlue),
              ),
              const SizedBox(width: 2),
              Expanded(
                flex: bus,
                child: Container(
                  height: 10,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(width: 8),
                          Icon(
                            Icons.payments_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trip['payment'] ?? '—',
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Plate: ${trip['plate'] ?? '—'}  ·  Assoc: ${trip['association'] ?? '—'}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
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

// ==================== DATA MODELS ====================

class CommuteShortcut {
  final IconData icon;
  final String label;
  final String from;
  final String to;

  const CommuteShortcut({
    required this.icon,
    required this.label,
    required this.from,
    required this.to,
  });
}