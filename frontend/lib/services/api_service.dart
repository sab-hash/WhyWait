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
    await Future.delayed(const Duration(milliseconds: 500));

    return {'available': 12, 'nearby_stations': 4, 'average_wait': 8};
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
