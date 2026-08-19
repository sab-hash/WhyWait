import 'package:flutter/material.dart';
import 'features/driver/driver_profile_screen.dart'; // adjust path to wherever you saved it

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaxiTrack Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B3D78)),
      ),
      home: const DriverProfileScreen(
        fullName: 'Yonas Tesfaye',
        phoneNumber: '+251 911 223 344',
        rating: 4.8,
        totalTrips: 312,
        earningsToday: 850,
        vehicleModel: 'Toyota Vitz',
        vehiclePlate: 'AA 21-45',
        vehicleColor: 'White',
      ),
    );
  }
}