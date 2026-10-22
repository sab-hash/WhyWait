import 'package:flutter/material.dart';
import '../../services/grpc_client.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  String? _fromTerminalId;
  String? _toTerminalId;
  List<Map<String, dynamic>> _terminals = [];
  List<RouteSuggestion> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTerminals();
  }

  Future<void> _loadTerminals() async {
    final response = await GrpcClient().getTerminals();
    setState(() {
      _terminals = response.terminals.map((t) => {
        'id': t.id,
        'name': t.name,
        'latitude': t.latitude,
        'longitude': t.longitude,
      }).toList();
    });
  }

  Future<void> _getRouteSuggestions() async {
    if (_fromTerminalId == null || _toTerminalId == null) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Replace with real gRPC call when available
      // For now, mock data
      await Future.delayed(const Duration(seconds: 1));
      _suggestions = [
        RouteSuggestion(
          description: 'Direct Taxi',
          segments: [
            RouteSegment(type: 'Taxi', from: 'Bole', to: 'Piazza', duration: 15),
          ],
          totalDuration: 15,
        ),
        RouteSuggestion(
          description: 'Taxi + Minibus',
          segments: [
            RouteSegment(type: 'Taxi', from: 'Bole', to: 'Mexico', duration: 8),
            RouteSegment(type: 'Minibus', from: 'Mexico', to: 'Piazza', duration: 12),
          ],
          totalDuration: 20,
        ),
        RouteSuggestion(
          description: 'Minibus Only',
          segments: [
            RouteSegment(type: 'Minibus', from: 'Bole', to: 'Piazza', duration: 25),
          ],
          totalDuration: 25,
        ),
      ];
    } catch (e) {
      print('Error getting route suggestions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Your Trip'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // From dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'From',
                border: OutlineInputBorder(),
              ),
              value: _fromTerminalId,
              items: _terminals.map<DropdownMenuItem<String>>((t) {
                return DropdownMenuItem<String>(
                  value: t['id'] as String?,
                  child: Text(t['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _fromTerminalId = value),
            ),
            const SizedBox(height: 16),
            // To dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'To',
                border: OutlineInputBorder(),
              ),
              value: _toTerminalId,
              items: _terminals.map<DropdownMenuItem<String>>((t) {
                return DropdownMenuItem<String>(
                  value: t['id'] as String?,
                  child: Text(t['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _toTerminalId = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fromTerminalId != null && _toTerminalId != null
                  ? _getRouteSuggestions
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Find Routes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  suggestion.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${suggestion.totalDuration} min',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...suggestion.segments.map((seg) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      seg.type == 'Taxi'
                                          ? Icons.local_taxi
                                          : Icons.directions_bus,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${seg.type}: ${seg.from} → ${seg.to} (${seg.duration} min)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Models
class RouteSuggestion {
  final String description;
  final List<RouteSegment> segments;
  final int totalDuration;

  RouteSuggestion({
    required this.description,
    required this.segments,
    required this.totalDuration,
  });
}

class RouteSegment {
  final String type;
  final String from;
  final String to;
  final int duration;

  RouteSegment({
    required this.type,
    required this.from,
    required this.to,
    required this.duration,
  });
}