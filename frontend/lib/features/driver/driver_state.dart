import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../data/driver_mock_data.dart';
import '../../data/driver_trip_data.dart';
import '../../models/driver_models.dart';
import '../../models/driver_trip.dart';

/// Configuration for driver-side features.
class DriverConfig {
  /// Whether passengers can rate drivers.
  static const bool ratingsEnabled = true;

  /// Commission percentage, or null when no commission is charged.
  static const double? commissionPercent = null;

  /// Whether drivers can update their seat count while loading.
  static const bool driverEditsSeats = true;

  // Queue order is view-only from the driver side.
}

enum Verification { verified, pending, actionNeeded }

/// Shared in-memory state for the driver screens.
///
/// IMPORTANT:
/// This class currently uses mock data and local state.
/// SOS, GPS tracking, reports, documents, earnings and notifications
/// are NOT persisted to or synchronized with the Go backend yet.
class DriverState extends ChangeNotifier {
  DriverState._();

  static final DriverState instance = DriverState._();

  // --------------------------------------------------------------------------
  // Assigned route
  // --------------------------------------------------------------------------

  static const int totalSeats = 14;
  static const int farePerSeat = 25;
  static const int routeMinutes = 25;

  DateTime get routeValidFrom {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  DateTime get routeValidUntil {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }

  final DriverProfile profile = DriverMockData.profile;
  final DriverVehicle vehicle = DriverMockData.vehicle();
  final List<Station> stations = DriverMockData.stations;

  // --------------------------------------------------------------------------
  // Online status and trip state
  // --------------------------------------------------------------------------

  bool _isOnline = true;
  TripStage _stage = TripStage.inQueue;

  int _seatsFilled = 0;
  int _queuePosition = 3;
  int _queueLength = 6;

  double _progress = 0;
  bool _forward = true;

  Timer? _simulation;

  bool get isOnline => _isOnline;

  TripStage get stage => _stage;

  int get seatsFilled => _seatsFilled;

  int get seatsLeft => totalSeats - _seatsFilled;

  /// Queue position is unavailable while offline or during a trip.
  int? get queuePosition {
    if (!_isOnline || isOnTrip) return null;
    return _queuePosition;
  }

  int get queueLength => _queueLength;

  /// Loading counts as being on a trip.
  bool get isOnTrip => _stage != TripStage.inQueue;

  /// A driver cannot go offline during a trip.
  bool get canGoOffline => !isOnTrip;

  String get tripFrom => _forward ? 'Mexico' : 'Bole';

  String get tripTo => _forward ? 'Bole' : 'Mexico';

  /// Changes the driver's online status.
  ///
  /// Returns an error message when the requested change is not allowed.
  String? setOnline(bool value) {
    if (value == _isOnline) return null;

    if (!value && !canGoOffline) {
      return "You can't go offline during a trip. End the trip first.";
    }

    _isOnline = value;

    if (value) {
      _queueLength += 1;
      _queuePosition = _queueLength;
    } else {
      _queueLength = math.max(0, _queueLength - 1);
      _queuePosition = 0;
    }

    notifyListeners();
    return null;
  }

  /// Advances the trip through its allowed stages.
  ///
  /// Returns an error message when the transition is not allowed.
  String? advance() {
    if (!_isOnline) {
      return 'Go online first.';
    }

    switch (_stage) {
      case TripStage.inQueue:
        _stage = TripStage.loading;
        break;

      case TripStage.loading:
        if (_seatsFilled < 1) {
          return 'Update the seat count before departing.';
        }

        _stage = TripStage.departed;
        _progress = 0.04;
        _queueLength = math.max(0, _queueLength - 1);
        _queuePosition = 0;
        break;

      case TripStage.departed:
        _stage = TripStage.onRoute;
        _startSimulation();
        break;

      case TripStage.onRoute:
        _stage = TripStage.arrived;
        _progress = 1.0;
        _stopSimulation();
        break;

      case TripStage.arrived:
        // Use completeTrip() after confirming cash collection.
        return null;
    }

    notifyListeners();
    return null;
  }

  /// Updates the number of filled seats while loading.
  String? setSeats(int value) {
    if (!DriverConfig.driverEditsSeats) {
      return 'Terminal staff update the seat count.';
    }

    if (_stage != TripStage.loading) {
      return 'You can update the seats while loading.';
    }

    _seatsFilled = value.clamp(0, totalSeats);

    notifyListeners();
    return null;
  }

  /// Completes a trip after the taxi reaches its destination.
  void completeTrip({required bool cashConfirmed}) {
    if (_stage != TripStage.arrived) return;

    _recordTrip(
      TripResult.completed,
      cashConfirmed: cashConfirmed,
    );

    _forward = !_forward;

    _resetToQueue(rejoinQueue: true);
  }

  /// Cancels a loading session before the taxi departs.
  void cancelLoading() {
    if (_stage != TripStage.loading) return;

    _recordTrip(TripResult.cancelled);

    _resetToQueue(rejoinQueue: false);
  }

  /// Ends a trip early, such as when the taxi breaks down.
  void endTripInterrupted() {
    if (!isOnTrip) return;

    _recordTrip(TripResult.interrupted);

    _resetToQueue(rejoinQueue: true);
  }

  final List<DriverTrip> _trips = <DriverTrip>[];

  void _recordTrip(
    TripResult result, {
    bool cashConfirmed = false,
  }) {
    _trips.insert(
      0,
      DriverTrip(
        date: DateTime.now(),
        from: tripFrom,
        to: tripTo,
        seats: _seatsFilled,
        farePerSeat: farePerSeat,
        status: result,
        cashConfirmed: cashConfirmed,
      ),
    );
  }

  void _resetToQueue({required bool rejoinQueue}) {
    _stopSimulation();

    _stage = TripStage.inQueue;
    _seatsFilled = 0;
    _progress = 0;

    // Clear the active delay without deleting the last reported problem.
    _problem = null;

    if (rejoinQueue) {
      _queueLength = 6;
      _queuePosition = _queueLength;
    }

    notifyListeners();
  }

  // Stubs; real implementations land in commits 7 and 8.
  void _startSimulation() {}
  void _stopSimulation() {}
  ProblemReport? _problem;
}