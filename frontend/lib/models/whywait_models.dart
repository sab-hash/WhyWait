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

class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;

  User({
    this.id = '',
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.role = 'passenger',
  });
}

class AuthResponse {
  final bool success;
  final String? token;
  final String? message;
  final User? user;

  AuthResponse({required this.success, this.token, this.message, this.user});

  factory AuthResponse.ok([String? token, User? user]) =>
      AuthResponse(success: true, token: token, user: user);
  factory AuthResponse.fail(String message) =>
      AuthResponse(success: false, message: message);
}

class Terminal {
  final String id;
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;

  Terminal({
    required this.id,
    required this.name,
    this.address = '',
    this.city = '',
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
  final int waitTime;

  PopularRoute({
    required this.from,
    required this.to,
    required this.fare,
    this.waitTime = 0,
  });
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
  final int available;
  final int nearbyStations;
  final int averageWait;

  TaxiStatusResponse({
    required this.taxis,
    this.available = 0,
    this.nearbyStations = 0,
    this.averageWait = 0,
  });
}

class TrackRequest {
  String station = '';
}

class TaxiUpdate {
  final String taxiId;
  final String plate;
  final String driverName;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final String status;
  final int etaMinutes;

  TaxiUpdate({
    required this.taxiId,
    this.plate = '',
    this.driverName = '',
    required this.latitude,
    required this.longitude,
    this.distanceKm = 0,
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

  Future<AuthResponse> login(LoginRequest req) async => AuthResponse.ok(
        'mock-token',
        User(
          id: 'u-1',
          fullName: 'Abebe Tesfaye',
          email: req.email,
          phone: req.email,
          role: 'passenger',
        ),
      );

  Future<AuthResponse> register(RegisterRequest req) async => AuthResponse.ok(
        'mock-token',
        User(
          id: 'u-2',
          fullName: req.fullName,
          email: req.email,
          phone: req.phone,
          role: 'passenger',
        ),
      );

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
        plate: 'AA-12345',
        driverName: 'Abebe Tesfaye',
        latitude: 9.005401,
        longitude: 38.763611,
        distanceKm: 1.8,
        status: 'en_route',
        etaMinutes: 4,
      );
    }
  }

  Future<LocationResponse> updateLocation(LocationUpdate req) async =>
      LocationResponse(success: true);

  Future<DriverStatusResponse> updateDriverStatus(
          DriverStatusRequest req) async =>
      DriverStatusResponse(success: true);
}