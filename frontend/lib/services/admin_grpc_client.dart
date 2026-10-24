import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_web.dart';

import '../generated/whywait.pb.dart';
import '../generated/whywait.pbgrpc.dart';

class AdminGrpcClient {
  static final AdminGrpcClient _instance = AdminGrpcClient._internal();
  factory AdminGrpcClient() => _instance;
  AdminGrpcClient._internal();

  late TaxiServiceClient _stub;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    // ✅ We instantiate directly based on the platform to avoid type errors
    if (kIsWeb) {
      final channel = GrpcWebClientChannel.xhr(Uri.parse('http://localhost:8080'));
      _stub = TaxiServiceClient(channel);
    } else {
      final channel = ClientChannel(
        'localhost',
        port: 50051,
        options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
      );
      _stub = TaxiServiceClient(channel);
    }
    
    _initialized = true;
  }

  Future<AdminStatsResponse> getAdminStats() async {
    await _ensureInitialized();
    return _stub.getAdminStats(Empty());
  }

  Future<GetReportsResponse> getReports({String status = '', int limit = 100, int offset = 0}) async {
    await _ensureInitialized();
    final req = GetReportsRequest()..status = status..limit = limit..offset = offset;
    return _stub.getReports(req);
  }

  Future<UpdateReportStatusResponse> updateReportStatus(String reportId, String status) async {
    await _ensureInitialized();
    final req = UpdateReportStatusRequest()..reportId = reportId..status = status;
    return _stub.updateReportStatus(req);
  }

  Future<RegisterTaxiDriverResponse> registerTaxiDriver({
    required String driverName,
    required String phone,
    required String email,
    required String password,
    required String vehiclePlate,
    required String vehicleModel,
    required String vehicleColor,
    required String terminalAId,
    required String terminalBId,
  }) async {
    await _ensureInitialized();
    final req = RegisterTaxiDriverRequest()
      ..driverName = driverName
      ..phone = phone
      ..email = email
      ..password = password
      ..vehiclePlate = vehiclePlate
      ..vehicleModel = vehicleModel
      ..vehicleColor = vehicleColor
      ..terminalAId = terminalAId
      ..terminalBId = terminalBId;
    return _stub.registerTaxiDriver(req);
  }

  Future<TaxiRoutesResponse> getTaxiRoutes() async {
    await _ensureInitialized();
    return _stub.getTaxiRoutes(Empty());
  }

  Future<TerminalsResponse> getTerminals() async {
    await _ensureInitialized();
    return _stub.getTerminals(Empty());
  }
}