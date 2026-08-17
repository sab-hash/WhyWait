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

// SERVICE
class TaxiService {
  Future<List<Taxi>> fetchNearbyTaxis() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockTaxis;
  }
}

// Pickup point: Mexico (Addis Ababa)
const LatLng pickupLocation = LatLng(9.0092, 38.7469);

final List<Taxi> _mockTaxis = [
  const Taxi(
    id: '1',
    name: 'Taxi 1',
    plate: 'AA 32-81',
    distanceKm: 1.2,
    etaMinutes: 4,
    status: TaxiStatus.available,
    latitude: 9.0125,
    longitude: 38.7510,
  ),
  const Taxi(
    id: '2',
    name: 'Taxi 2',
    plate: 'AA 14-72',
    distanceKm: 2.8,
    etaMinutes: 9,
    status: TaxiStatus.filling,
    latitude: 9.0165,
    longitude: 38.7440,
  ),
  const Taxi(
    id: '3',
    name: 'Taxi 3',
    plate: 'AA 55-03',
    distanceKm: 4.1,
    etaMinutes: 13,
    status: TaxiStatus.available,
    latitude: 9.0200,
    longitude: 38.7550,
  ),
];