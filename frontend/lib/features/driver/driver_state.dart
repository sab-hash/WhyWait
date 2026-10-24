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
}  // --------------------------------------------------------------------------
  // Route geometry and ETA
  // --------------------------------------------------------------------------

  Station stationByName(String name) {
    for (final station in stations) {
      if (station.name == name) return station;
    }

    throw StateError('Station "$name" was not found in the route data.');
  }

  /// Ordered stops for the driver's current direction.
  List<Station> get routeStops {
    final stops = DriverMockData.assignedRouteStopNames
        .map(stationByName)
        .toList();

    return _forward ? stops : stops.reversed.toList();
  }

  /// Terminal where the taxi is waiting before departure.
  Station? get currentStation {
    if (_stage == TripStage.inQueue || _stage == TripStage.loading) {
      final stops = routeStops;
      return stops.isEmpty ? null : stops.first;
    }

    return null;
  }

  /// Calculates normalized progress values for each stop.
  ///
  /// If all coordinates are identical, evenly spaced fractions prevent
  /// division by zero.
  List<double> _fractions(List<Station> stops) {
    if (stops.isEmpty) return const [];

    if (stops.length == 1) return const [0.0];

    final lengths = <double>[0.0];

    for (var i = 1; i < stops.length; i++) {
      final dLat = stops[i].lat - stops[i - 1].lat;
      final dLng = stops[i].lng - stops[i - 1].lng;

      lengths.add(
        lengths.last + math.sqrt(dLat * dLat + dLng * dLng),
      );
    }

    final total = lengths.last;

    if (total <= 0) {
      return List<double>.generate(
        stops.length,
        (index) => index / (stops.length - 1),
      );
    }

    return lengths.map((length) => length / total).toList();
  }  /// Simulated taxi position along the assigned route.
  ///
  /// This is not a real GPS location.
  ({double lat, double lng}) get driverPosition {
    final stops = routeStops;

    if (stops.isEmpty) {
      throw StateError('Cannot calculate position: the route has no stops.');
    }

    if (stops.length == 1) {
      return (
        lat: stops.first.lat,
        lng: stops.first.lng,
      );
    }

    final fractions = _fractions(stops);
    final progress = _progress.clamp(0.0, 1.0);

    for (var i = 0; i < stops.length - 1; i++) {
      if (progress <= fractions[i + 1]) {
        final span = fractions[i + 1] - fractions[i];

        final t = span <= 0
            ? 0.0
            : ((progress - fractions[i]) / span).clamp(0.0, 1.0);

        return (
          lat: stops[i].lat + (stops[i + 1].lat - stops[i].lat) * t,
          lng: stops[i].lng + (stops[i + 1].lng - stops[i].lng) * t,
        );
      }
    }

    return (
      lat: stops.last.lat,
      lng: stops.last.lng,
    );
  }

  /// Next stop and estimated minutes until the taxi reaches it.
  ({Station stop, int minutes})? get nextStop {
    if (_stage == TripStage.arrived) return null;

    final stops = routeStops;
    if (stops.length < 2) return null;

    final fractions = _fractions(stops);

    for (var i = 1; i < stops.length; i++) {
      if (fractions[i] > _progress + 0.0001) {
        final minutes = (
          (fractions[i] - _progress) * routeMinutes
        ).ceil();

        return (
          stop: stops[i],
          minutes: math.max(0, minutes + delayMinutes),
        );
      }
    }

    return null;
  }

  /// Estimated minutes remaining on the route.
  int get etaMinutes {
    if (_stage == TripStage.arrived) return 0;

    return math.max(
      0,
      ((1.0 - _progress.clamp(0.0, 1.0)) * routeMinutes).ceil() +
          delayMinutes,
    );
  }
    /// Starts the local demo simulation.
  ///
  /// Progress advances every two seconds until the destination is reached.
  /// The driver still confirms arrival through the normal trip controls.
  void _startSimulation() {
    _stopSimulation();

    if (_progress >= 1.0) return;

    _simulation = Timer.periodic(
      const Duration(seconds: 2),
      (timer) {
        if (_stage != TripStage.onRoute) {
          timer.cancel();
          if (identical(_simulation, timer)) {
            _simulation = null;
          }
          return;
        }

        _progress = math.min(1.0, _progress + 0.02);

        if (_progress >= 1.0) {
          timer.cancel();
          if (identical(_simulation, timer)) {
            _simulation = null;
          }
        }

        notifyListeners();
      },
    );
  }

  void _stopSimulation() {
    _simulation?.cancel();
    _simulation = null;
  }
    // --------------------------------------------------------------------------
  // Safety: problem reports, SOS, location sharing and contacts
  // --------------------------------------------------------------------------

  ProblemReport? _problem;
  ProblemReport? _lastProblem;

  /// Current problem, or the most recently reported problem after reset.
  ProblemReport? get problem => _problem ?? _lastProblem;

  /// Only an active trip problem affects the current ETA.
  int get delayMinutes {
    if (!isOnTrip) return 0;
    return _problem?.delayMinutes ?? 0;
  }

  /// Records a problem locally and applies its delay to the active trip.
  ///
  /// This does not send a report to the Go backend.
  void reportProblem({
    required String type,
    required int delayMinutes,
    String note = '',
  }) {
    final normalizedType = type.trim();

    if (normalizedType.isEmpty) return;

    final report = ProblemReport(
      type: normalizedType,
      note: note.trim(),
      delayMinutes: delayMinutes.clamp(0, 240),
      reportedAt: DateTime.now(),
    );

    _problem = report;
    _lastProblem = report;

    notifyListeners();
  }

  /// Clears the current and most recently displayed problem.
  void clearProblem() {
    if (_problem == null && _lastProblem == null) return;

    _problem = null;
    _lastProblem = null;

    notifyListeners();
  }
    DateTime? _sosSentAt;
  bool _shareLocation = false;

  final List<EmergencyContact> _contacts =
      DriverMockData.contacts();

  DateTime? get sosSentAt => _sosSentAt;

  bool get shareLocation => _shareLocation;

  List<EmergencyContact> get contacts =>
      List.unmodifiable(_contacts);

  /// Activates the local SOS state.
  ///
  /// This does NOT call emergency services, send notifications or transmit
  /// the driver's GPS coordinates. Those actions require backend integration.
  ///
  /// Calling this more than once while active does not reset the timestamp.
  void triggerSos() {
    if (_sosSentAt != null) return;

    _sosSentAt = DateTime.now();
    _shareLocation = true;

    notifyListeners();
  }

  /// Resets the local SOS state.
  ///
  /// This is not a backend cancellation or an emergency-services notification.
  void cancelSos() {
    if (_sosSentAt == null) return;

    _sosSentAt = null;

    notifyListeners();
  }

  /// Toggles the local location-sharing preference.
  ///
  /// This does not start or stop a GPS stream.
  void setShareLocation(bool value) {
    if (_shareLocation == value) return;

    _shareLocation = value;

    notifyListeners();
  }

  void addContact(EmergencyContact contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  void removeContact(int index) {
    if (index < 0 || index >= _contacts.length) return;

    _contacts.removeAt(index);
    notifyListeners();
  }