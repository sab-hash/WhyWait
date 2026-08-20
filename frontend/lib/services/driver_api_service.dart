import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriverApiService {
  static const String baseUrl = "http://localhost:8080";

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_token', token);
    print('✅ Token saved: $token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('driver_token');
    print('🔍 Token retrieved: $token');
    return token;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_token');
    print('🔑 Token cleared');
  }

  static Future<Map<String, dynamic>> login(String phone, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': phone, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Login successful');
      print('🔍 Token: ${data['token']}');
      print('🔍 Role: ${data['user']['role']}');
      return data;
    }
    throw Exception('Login failed');
  }

  static Future<bool> sendLocation({
    required String taxiId,
    required double latitude,
    required double longitude,
    required double speed,
    required double heading,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('❌ No token found for sendLocation');
        return false;
      }
      final url = Uri.parse('$baseUrl/taxis/location');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'taxi_id': taxiId,
          'latitude': latitude,
          'longitude': longitude,
          'speed': speed,
          'heading': heading,
        }),
      );
      print('🔍 sendLocation Status: ${response.statusCode}');
      print('🔍 sendLocation Response: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error sending location: $e');
      return false;
    }
  }

  static Future<bool> updateStatus(String taxiId, bool isOnline) async {
    try {
      final token = await getToken();
      print('🔍 Token retrieved: $token');
      if (token == null) {
        print('❌ No token found');
        return false;
      }

      final url = Uri.parse('$baseUrl/driver/status');
      final body = jsonEncode({'taxi_id': taxiId, 'is_online': isOnline});
      print('🔍 URL: $url');
      print('🔍 Request Body: $body');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Status updated successfully');
        return true;
      } else {
        print('❌ Status update failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating status: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final token = await getToken();
      if (token == null) return {};
      final url = Uri.parse('$baseUrl/driver/stats');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching stats: $e');
      return {};
    }
  }
}