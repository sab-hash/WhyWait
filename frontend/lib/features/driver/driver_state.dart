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
}