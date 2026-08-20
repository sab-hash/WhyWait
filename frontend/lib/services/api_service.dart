import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8080";

  // Get all terminals
  static Future<List<dynamic>> getTerminals() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/terminals'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['terminals'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching terminals: $e');
      return [];
    }
  }

  // Get taxi status (available, total, average wait, nearby stations)
  static Future<Map<String, dynamic>> getTaxiStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/taxis/status'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching taxi status: $e');
      return {};
    }
  }

  // Get popular routes
  static Future<List<dynamic>> getPopularRoutes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/routes/popular'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['routes'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching popular routes: $e');
      return [];
    }
  }

  // Get approaching taxis
  static Future<List<dynamic>> getApproachingTaxis(String station) async {
    try {
      final url = Uri.parse('$baseUrl/taxis/approaching?station=${Uri.encodeComponent(station)}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['taxis'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching approaching taxis: $e');
      return [];
    }
  }
}