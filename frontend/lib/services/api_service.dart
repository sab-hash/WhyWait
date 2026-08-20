import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ==================== TERMINALS ====================

  static Future<List<Map<String, dynamic>>> getTerminals() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/terminals'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load terminals');
    }

    final data = jsonDecode(response.body);

    return List<Map<String, dynamic>>.from(data['terminals']);
  }

  // ==================== TAXI STATUS ====================

  static Future<Map<String, dynamic>> getTaxiStatus() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/taxis/status'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load taxi status');
    }

    final data = jsonDecode(response.body);

    return {
      'available': data['available'] ?? 0,
      'nearby_stations': data['nearby_stations'] ?? 0,
      'average_wait': data['average_wait'] ?? 0,
    };
  }

  // ==================== POPULAR ROUTES ====================

  static Future<List<Map<String, dynamic>>> getPopularRoutes() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      {'from': 'Bole', 'to': 'Piazza', 'waitTime': 5},
      {'from': 'Megenagna', 'to': 'Bole', 'waitTime': 8},
      {'from': 'Mexico', 'to': 'Piazza', 'waitTime': 6},
    ];
  }
}
