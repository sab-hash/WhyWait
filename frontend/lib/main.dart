import 'package:flutter/material.dart';

import 'features/driver/driver_home_screen.dart';

void main() {
  runApp(const TaxiApp());
}

class TaxiApp extends StatelessWidget {
  const TaxiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DriverHomeScreen(),
    );
  }
}