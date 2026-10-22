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

  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String phone,
    required String email,
  }) async {
    final token = await LocalStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final response = await http.put(
      Uri.parse('http://localhost:8080/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullName': fullName,
        'phone': phone,
        'email': email,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to update profile');
    }

    return Map<String, dynamic>.from(data['user']);
  }

  // ==================== REPORTS ====================

  static Future<Map<String, dynamic>> createReport({
    required String tripId,
    required String issueType,
    required String description,
    String? vehicleDetails,
    int? rating,
  }) async {
    final token = await LocalStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse('http://localhost:8080/reports'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'trip_id': tripId,
        'issue_type': issueType,
        'description': description,
        'vehicle_details': vehicleDetails,
        'rating': rating,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(data['error'] ?? 'Failed to create report');
    }

    return Map<String, dynamic>.from(data['report']);
  }

  static Future<List<Map<String, dynamic>>> getMyReports() async {
    final token = await LocalStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('http://localhost:8080/reports/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to fetch reports');
    }

    return List<Map<String, dynamic>>.from(data['reports'] ?? []);
  }

  // ==================== TRIPS & ANALYTICS ====================

  static Future<List<Map<String, dynamic>>> getMyTrips() async {
    final token = await LocalStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('http://localhost:8080/trips/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to fetch trips');
    }

    return List<Map<String, dynamic>>.from(data['trips'] ?? []);
  }

  static Future<Map<String, dynamic>> getTripDetails(String id) async {
    final token = await LocalStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('http://localhost:8080/trips/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to fetch trip details');
    }

    return Map<String, dynamic>.from(data['trip']);
  }

  static Future<Map<String, dynamic>> getTripAnalytics({String? month}) async {
    final token = await LocalStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse('http://localhost:8080/trips/analytics').replace(
      queryParameters: month != null ? {'month': month} : null,
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to fetch analytics');
    }

    return Map<String, dynamic>.from(data['analytics']);
  }

  static Future<List<Map<String, dynamic>>> getShortcuts() async {
    final token = await LocalStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('http://localhost:8080/trips/shortcuts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to fetch shortcuts');
    }

    return List<Map<String, dynamic>>.from(data['shortcuts'] ?? []);
  }

  // ==================== ROUTE PLANNER ====================

  static Future<Map<String, dynamic>> planRoute({
    required String from,
    required String to,
  }) async {
    final uri = Uri.parse('http://localhost:8080/routes/plan').replace(
      queryParameters: {'from': from, 'to': to},
    );

    final response = await http.get(uri);
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to plan route');
    }

    return Map<String, dynamic>.from(data['plan']);
  }
}

