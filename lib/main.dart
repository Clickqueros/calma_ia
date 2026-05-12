import 'package:flutter/material.dart';
import 'screens/landing_page.dart';

void main() {
  runApp(const CalmaApp());
}

class CalmaApp extends StatelessWidget {
  const CalmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calma IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4EFF)),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}
