import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

enum TaxiStatus { available, filling }

class Taxi {
  final String id;
  final String name;
  final String plate;
  final double distanceKm;
  final int etaMinutes;
  final TaxiStatus status;
  final double latitude;
  final double longitude;

  const Taxi({
    required this.id,
    required this.name,
    required this.plate,
    required this.distanceKm,
    required this.etaMinutes,
    required this.status,
    required this.latitude,
    required this.longitude,
  });
}