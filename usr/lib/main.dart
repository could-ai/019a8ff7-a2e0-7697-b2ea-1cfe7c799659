import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TexasHoldemApp());
}

class TexasHoldemApp extends StatelessWidget {
  const TexasHoldemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '德州扑克',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}