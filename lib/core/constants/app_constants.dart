import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // ── Gemini AI ─────────────────────────────────────────────────────────────
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? 'YOUR_GEMINI_API_KEY_HERE';

  // ── Trust Score Thresholds ─────────────────────────────────────────────────
  static const double excellentThreshold = 90.0;
  static const double healthyThreshold = 75.0;
  static const double watchThreshold = 50.0;

  // ── Firestore Collections ──────────────────────────────────────────────────
  static const String usersCollection = 'users';
  static const String circlesCollection = 'circles';
  static const String pulsesCollection = 'pulses';
  static const String gratitudeCollection = 'gratitude';
  static const String insightsCollection = 'insights';

  // ── Circle Types ───────────────────────────────────────────────────────────
  static const List<String> circleTypes = [
    'Family',
    'Friends',
    'Team',
    'Relationship',
    'Community',
  ];

  // ── Pulse Questions ────────────────────────────────────────────────────────
  static const List<Map<String, String>> pulseQuestions = [
    {
      'key': 'heard',
      'question': 'Did you feel heard today?',
      'emoji': '◉',
    },
    {
      'key': 'respected',
      'question': 'Did you feel respected today?',
      'emoji': '◈',
    },
    {
      'key': 'safe',
      'question': 'Did you feel safe today?',
      'emoji': '◆',
    },
    {
      'key': 'connected',
      'question': 'Did you feel connected today?',
      'emoji': '●',
    },
  ];

  // ── Gratitude Reactions ────────────────────────────────────────────────────
  static const List<String> reactions = ['♡', '✦', '☆'];
}
