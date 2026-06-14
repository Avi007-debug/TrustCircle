import 'package:flutter/material.dart';

void main() {
  runApp(const TrustCircleApp());
}

class TrustCircleApp extends StatelessWidget {
  const TrustCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TrustCircle',
      home: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Text(
            'TrustCircle',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}