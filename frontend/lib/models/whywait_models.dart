// lib/models/whywait_models.dart
//
// Plain Dart replacements for the missing `generated/whywait.pb.dart`.
// Once the backend team provides a real .proto, this file can be deleted.

class Empty {
  const Empty();
}

class LoginRequest {
  String email = '';
  String password = '';
}

class RegisterRequest {
  String fullName = '';
  String phone = '';
  String email = '';
  String password = '';
}

class AuthResponse {
  final bool success;
  final String? token;
  final String? message;

  AuthResponse({required this.success, this.token, this.message});

  factory AuthResponse.ok([String? token]) =>
      AuthResponse(success: true, token: token);
  factory AuthResponse.fail(String message) =>
      AuthResponse(success: false, message: message);
}

class Terminal {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  Terminal({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class TerminalsResponse {
  final List<Terminal> terminals;
  TerminalsResponse({required this.terminals});
}

class PopularRoute {
  final String from;
  final String to;
  final double fare;

  PopularRoute({required this.from, required this.to, required this.fare});
}

class PopularRoutesResponse {
  final List<PopularRoute> routes;
  PopularRoutesResponse({required this.routes});
}

class TaxiStatus {
  final String taxiId;
  final String status;
  final int etaMinutes;

  TaxiStatus({
    required this.taxiId,
    required this.status,
    required this.etaMinutes,
  });
}

class TaxiStatusResponse {
  final List<TaxiStatus> taxis;
  TaxiStatusResponse({required this.taxis});
}

class TrackRequest {
  String station = '';
}

class TaxiUpdate {
  final String taxiId;
  final double latitude;
  final double longitude;
  final String status;
  final int etaMinutes;

  TaxiUpdate({
    required this.taxiId,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.etaMinutes,
  });
}

class LocationUpdate {
  String taxiId = '';
  double latitude = 0;
  double longitude = 0;
  double speed = 0;
  double heading = 0;
}

class LocationResponse {
  final bool success;
  LocationResponse({required this.success});
}

class DriverStatusRequest {
  String taxiId = '';
  bool isOnline = false;
}

class DriverStatusResponse {
  final bool success;
  DriverStatusResponse({required this.success});
}

// --- Mock client (replaces the generated TaxiServiceClient) ---

class TaxiServiceClient {
  TaxiServiceClient([dynamic channel]);

  Future<AuthResponse> login(LoginRequest req) async =>
      AuthResponse.ok('mock-token');

  Future<AuthResponse> register(RegisterRequest req) async =>
      AuthResponse.ok('mock-token');

  Future<TerminalsResponse> getTerminals(Empty _) async =>
      TerminalsResponse(terminals: const []);

  Future<PopularRoutesResponse> getPopularRoutes(Empty _) async =>
      PopularRoutesResponse(routes: const []);

  Future<TaxiStatusResponse> getTaxiStatus(Empty _) async =>
      TaxiStatusResponse(taxis: const []);

  Stream<TaxiUpdate> trackTaxis(TrackRequest req) async* {
    // Emit a fake taxi update every 2 seconds
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      yield TaxiUpdate(
        taxiId: 'AA-12345',
        latitude: 9.005401,
        longitude: 38.763611,
        status: 'en_route',
        etaMinutes: 4,
      );
    }
  }

  Future<LocationResponse> updateLocation(LocationUpdate req) async =>
      LocationResponse(success: true);

  Future<DriverStatusResponse> updateDriverStatus(DriverStatusRequest req) async =>
      DriverStatusResponse(success: true);
}