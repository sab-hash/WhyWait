import 'package:flutter/material.dart';
import '../../services/grpc_client.dart';
import '../../services/passenger_state.dart';

class NearbyStationsScreen extends StatefulWidget {
  const NearbyStationsScreen({super.key});

  @override
  State<NearbyStationsScreen> createState() => _NearbyStationsScreenState();
}

class _NearbyStationsScreenState extends State<NearbyStationsScreen> {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color lightBlue = Color(0xFFE3F2FD);

  List<Map<String, dynamic>> _terminals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await GrpcClient().getTerminals();
      setState(() {
        _terminals = res.terminals
            .map((t) => {
                  'id': t.id,
                  'name': t.name,
                  'address': t.address,
                  'city': t.city,
                })
            .toList();
        _isLoading = false;
      });
      PassengerState().terminals = _terminals;
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nearby Stations',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Line taxi terminals around you',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _terminals.isEmpty
                        ? const Center(child: Text('No stations found'))
                        : ListView.separated(
                            itemCount: _terminals.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final t = _terminals[i];
                              return _stationCard(
                                name: t['name'] ?? 'Unknown',
                                address: t['address'] ?? '',
                                city: t['city'] ?? '',
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stationCard({
    required String name,
    required String address,
    required String city,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.location_on_rounded,
                color: primaryBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [address, city].where((e) => e.isNotEmpty).join(', '),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: primaryBlue),
        ],
      ),
    );
  }
}