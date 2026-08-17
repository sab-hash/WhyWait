import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// MODEL
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

  factory Taxi.fromJson(Map<String, dynamic> json) {
    return Taxi(
      id: json['id'].toString(),
      name: json['name'] as String,
      plate: json['plate'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      etaMinutes: json['eta_minutes'] as int,
      status: (json['status'] as String) == 'available'
          ? TaxiStatus.available
          : TaxiStatus.filling,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plate': plate,
      'distance_km': distanceKm,
      'eta_minutes': etaMinutes,
      'status': status == TaxiStatus.available ? 'available' : 'filling',
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}