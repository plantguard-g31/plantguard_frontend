import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart'; // or login_screen.dart

void main() {
  runApp(const PlantGuardApp());
}

class PlantGuardApp extends StatelessWidget {
  const PlantGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111111),
      ),
      home: const LoginScreen(), // change to LoginScreen() if needed
    );
  }
}
