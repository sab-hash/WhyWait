import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/local_storage.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF0B3D78),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await LocalStorage.clearAll();
              if (context.mounted) context.go('/login');
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          '🚧 Admin Dashboard Under Construction 🚧',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}