import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriverApiService {
  static const String baseUrl = "http://localhost:8080";

  // ==================== AUTH & TOKEN ====================

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('driver_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
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
      if (data['token'] != null) {
        await saveToken(data['token']);
      }
      return data;
    }
    throw Exception('Login failed');
  }

  // ==================== PROFILE & VEHICLE ====================

  static Future<Map<String, dynamic>> getProfile() async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$baseUrl/driver/profile'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load driver profile');
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? phone,
    String? email,
    String? licenseNumber,
    String? association,
  }) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/driver/profile'),
      headers: headers,
      body: jsonEncode({
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (licenseNumber != null) 'license_number': licenseNumber,
        if (association != null) 'association': association,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to update driver profile');
  }

  static Future<Map<String, dynamic>> getVehicle() async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$baseUrl/driver/vehicle'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load driver vehicle');
  }

  // ==================== DISPATCH & SHIFT ====================

  static Future<Map<String, dynamic>> getDispatch() async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$baseUrl/driver/dispatch'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load dispatch info');
  }

  static Future<bool> updateStatus(String taxiId, bool isOnline) async {
    try {
      final headers = await _authHeaders();
      final url = Uri.parse('$baseUrl/driver/status');
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({'taxi_id': taxiId, 'is_online': isOnline}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> setShiftActive(bool active) async {
    try {
      final headers = await _authHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/driver/shift'),
        headers: headers,
        body: jsonEncode({'active': active}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> proceedToGate() async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(Uri.parse('$baseUrl/driver/gate'), headers: headers);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ==================== ACTIVE TRIP & SEATS ====================

  static Future<Map<String, dynamic>> getActiveTrip() async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$baseUrl/driver/trip/active'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load active trip');
  }

  static Future<Map<String, dynamic>> updateSeats({int? seatsFilled, int? seatsOpen, int? delta}) async {
    final headers = await _authHeaders();
    final body = <String, dynamic>{};
    if (seatsFilled != null) body['seats_filled'] = seatsFilled;
    if (seatsOpen != null) body['seats_open'] = seatsOpen;
    if (delta != null) body['delta'] = delta;

    final response = await http.put(
      Uri.parse('$baseUrl/driver/trip/seats'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to update seat count');
  }

  static Future<Map<String, dynamic>> markBusFull() async {
    final headers = await _authHeaders();
    final response = await http.post(Uri.parse('$baseUrl/driver/trip/full'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to mark bus full');
  }

  static Future<Map<String, dynamic>> advanceTripStage([String? nextStage]) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/driver/trip/advance'),
      headers: headers,
      body: jsonEncode({if (nextStage != null) 'next_stage': nextStage}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to advance trip');
  }

  static Future<Map<String, dynamic>> completeTrip({bool cashConfirmed = false}) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/driver/trip/complete'),
      headers: headers,
      body: jsonEncode({'cash_confirmed': cashConfirmed}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to complete trip');
  }

  static Future<bool> cancelTrip() async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(Uri.parse('$baseUrl/driver/trip/cancel'), headers: headers);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ==================== PERFORMANCE & EARNINGS ====================

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final headers = await _authHeaders();
      final url = Uri.parse('$baseUrl/driver/stats');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> getEarnings({String period = 'today'}) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/driver/earnings?period=$period'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load earnings');
  }

  static Future<List<Map<String, dynamic>>> getTrips({String period = 'all'}) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/driver/trips?period=$period'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['trips'] ?? []);
    }
    throw Exception('Failed to load driver trips');
  }

  static Future<bool> confirmTripCash(String tripId) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/driver/trips/$tripId/confirm-cash'),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  // ==================== SAFETY & SOS ====================

  static Future<Map<String, dynamic>> reportProblem({
    required String type,
    int delayMinutes = 10,
    String note = '',
    bool endTrip = false,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/driver/problems'),
      headers: headers,
      body: jsonEncode({
        'type': type,
        'delay_minutes': delayMinutes,
        'note': note,
        'end_trip': endTrip,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to report problem');
  }

  static Future<Map<String, dynamic>> triggerSOS({double? latitude, double? longitude}) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/driver/sos'),
      headers: headers,
      body: jsonEncode({
        'latitude': latitude ?? 9.0120,
        'longitude': longitude ?? 38.8050,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to trigger SOS');
  }

  static Future<bool> cancelSOS() async {
    final headers = await _authHeaders();
    final response = await http.post(Uri.parse('$baseUrl/driver/sos/cancel'), headers: headers);
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> getSOSStatus() async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$baseUrl/driver/sos/status'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {'is_active': false};
  }

  static Future<List<Map<String, dynamic>>> getContacts() async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$baseUrl/driver/contacts'), headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['contacts'] ?? []);
    }
    return [];
  }

  static Future<Map<String, dynamic>> addContact({
    required String name,
    required String relationship,
    required String phone,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/driver/contacts'),
      headers: headers,
      body: jsonEncode({'name': name, 'relationship': relationship, 'phone': phone}),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to add contact');
  }

  static Future<bool> deleteContact(String contactId) async {
    final headers = await _authHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/driver/contacts/$contactId'), headers: headers);
    return response.statusCode == 200;
  }

  // ==================== DOCUMENTS & DEMAND ====================

  static Future<Map<String, dynamic>> getDocuments() async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$baseUrl/driver/documents'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load documents');
  }

  static Future<Map<String, dynamic>> getDemand() async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$baseUrl/driver/demand'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load demand map');
  }

  static Future<Map<String, dynamic>> getNotifications() async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$baseUrl/driver/notifications'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {'notifications': [], 'unread_count': 0};
  }

  static Future<bool> markNotificationRead(String id) async {
    final headers = await _authHeaders();
    final response = await http.put(Uri.parse('$baseUrl/driver/notifications/$id/read'), headers: headers);
    return response.statusCode == 200;
  }

  static Future<bool> markAllNotificationsRead() async {
    final headers = await _authHeaders();
    final response = await http.put(Uri.parse('$baseUrl/driver/notifications/read-all'), headers: headers);
    return response.statusCode == 200;
  }

  // ==================== GPS LOCATION ====================

  static Future<bool> sendLocation({
    required String taxiId,
    required double latitude,
    required double longitude,
    required double speed,
    required double heading,
  }) async {
    try {
      final headers = await _authHeaders();
      final url = Uri.parse('$baseUrl/taxis/location');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'taxi_id': taxiId,
          'latitude': latitude,
          'longitude': longitude,
          'speed': speed,
          'heading': heading,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}