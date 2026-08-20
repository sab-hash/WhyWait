import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/storage/local_storage.dart';

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
    final response = await http.get(
      Uri.parse('http://localhost:8080/routes/popular'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load popular routes');
    }

    final data = jsonDecode(response.body);

    return List<Map<String, dynamic>>.from(data['routes']);
  }

  // ==================== USER PROFILE ====================

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await LocalStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('http://localhost:8080/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load profile');
    }

    final data = jsonDecode(response.body);

    return Map<String, dynamic>.from(data['user']);
  }
}
