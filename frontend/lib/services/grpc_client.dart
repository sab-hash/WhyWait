import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_web.dart' as grpc_web;
import '../generated/whywait.pb.dart';
import '../generated/whywait.pbgrpc.dart';

class GrpcClient {
  static final GrpcClient _instance = GrpcClient._internal();
  factory GrpcClient() => _instance;
  GrpcClient._internal();

  late TaxiServiceClient _stub;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    dynamic channel;

    if (kIsWeb) {
      // 🔥 Use Web channel – works in Chrome
      channel = grpc_web.GrpcWebClientChannel.xhr(
        Uri.parse('http://localhost:8080'),
      );
    } else {
      // 📱 Use standard channel – works on Android/iOS/desktop
      channel = ClientChannel(
        'localhost',
        port: 50051,
        options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
      );
    }

    _stub = TaxiServiceClient(channel);
    _initialized = true;
  }

  TaxiServiceClient get stub {
    if (!_initialized) throw Exception('Client not initialized. Call init() first.');
    return _stub;
  }

  // ----- Auth -----
  Future<AuthResponse> login(String email, String password) async {
    final req = LoginRequest()..email = email..password = password;
    return stub.login(req);
  }

  Future<AuthResponse> register(String fullName, String phone, String email, String password) async {
    final req = RegisterRequest()
      ..fullName = fullName
      ..phone = phone
      ..email = email
      ..password = password;
    return stub.register(req);
  }

  // ----- Passenger -----
  Future<TerminalsResponse> getTerminals() async {
    return stub.getTerminals(Empty());
  }

  Future<PopularRoutesResponse> getPopularRoutes() async {
    return stub.getPopularRoutes(Empty());
  }

  Future<TaxiStatusResponse> getTaxiStatus() async {
    return stub.getTaxiStatus(Empty());
  }

  // ----- Real-time tracking (Server streaming) -----
  Stream<TaxiUpdate> trackTaxis(String station) {
    final req = TrackRequest()..station = station;
    return stub.trackTaxis(req);
  }

  // ----- Driver -----
  Future<LocationResponse> updateLocation(String taxiId, double lat, double lng, double speed, double heading) async {
    final req = LocationUpdate()
      ..taxiId = taxiId
      ..latitude = lat
      ..longitude = lng
      ..speed = speed
      ..heading = heading;
    return stub.updateLocation(req);
  }

  Future<DriverStatusResponse> updateDriverStatus(String taxiId, bool isOnline) async {
    final req = DriverStatusRequest()
      ..taxiId = taxiId
      ..isOnline = isOnline;
    return stub.updateDriverStatus(req);
  }
}