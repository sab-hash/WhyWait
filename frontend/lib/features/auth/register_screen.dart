import 'package:flutter/material.dart';
final fullNameController = TextEditingController();
final phoneController = TextEditingController();
final emailController = TextEditingController();

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xFFF7F9FC),

  body: Column(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),

        decoration: const BoxDecoration(
          color: Color(0xFF1565C0),

          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),

        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,

              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),

            Container(
              width: 70,
              height: 70,

              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.local_taxi,
                size: 36,
                color: Color(0xFF1565C0),
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Create Account',

              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Join Why Wait?',

              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),

      Expanded(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(24),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'FULL NAME',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF555555),
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: fullNameController,

          decoration: const InputDecoration(
            hintText: 'Abebe Kebede',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'PHONE NUMBER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF555555),
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: phoneController,

          keyboardType: TextInputType.phone,

          decoration: const InputDecoration(
            hintText: '09XXXXXXXX',
            prefixIcon: Icon(Icons.phone_outlined),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'EMAIL',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF555555),
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: emailController,

          keyboardType: TextInputType.emailAddress,

          decoration: const InputDecoration(
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    ),
  ),
),
    ],
  ),
);
  }
}