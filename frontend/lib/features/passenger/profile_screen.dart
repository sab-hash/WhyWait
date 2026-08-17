import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taxi App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF3F5F8),
        useMaterial3: true,
      ),
      home: const ProfileScreen(),
    );
  }
}

class _UserData {
  static const String name = 'Abebe Kebede';
  static const String phone = '+251 912 345 678';
  static const String avatarUrl =
      'https://i.pravatar.cc/300?img=13';

  static const String trips = '24';
  static const String favorites = '3';
  static const String avgWait = '~6m';

  static const String savedStations = 'Mexico, Bole, CMC';
  static const String language = 'English';
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color primaryBlue = Color(0xFF14448C);
  static const Color darkText = Color(0xFF1A1D29);
  static const Color subText = Color(0xFF7A8194);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}