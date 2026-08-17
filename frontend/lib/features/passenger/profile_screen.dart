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
              _buildHeader(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 32,
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              image: const DecorationImage(
                image: NetworkImage(_UserData.avatarUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            _UserData.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _UserData.phone,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }
}