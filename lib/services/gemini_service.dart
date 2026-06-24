import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants/app_constants.dart';
import '../data/models/pulse_model.dart';
import '../data/models/insight_model.dart';

class GeminiService {
  GenerativeModel? _model;

  GenerativeModel get _getModel {
    _model ??= GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConstants.geminiApiKey,
    );
    return _model!;
  }

  Future<InsightModel?> generateInsight({
    required String circleId,
    required List<PulseModel> pulses,
    required int gratitudeCount,
  }) async {
    if (AppConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      // Return mock data when no key is configured
      return InsightModel(
        id: 'mock',
        circleId: circleId,
        summary:
            'Trust appears stable across this circle. Members are engaging with consistent positivity.',
        riskLevel: 'Low',
        suggestion:
            'Consider scheduling a casual group call to strengthen bonds further.',
        conversationStarter:
            "What's one thing someone in this circle did recently that made you feel appreciated?",
        timestamp: DateTime.now(),
      );
    }

    final avgTrust = pulses.isEmpty
        ? 0.0
        : pulses.map((p) => p.trustScore).reduce((a, b) => a + b) /
            pulses.length;

    final avgHeard = pulses.isEmpty
        ? 0.0
        : pulses.map((p) => p.heard).reduce((a, b) => a + b) / pulses.length;

    final avgSafe = pulses.isEmpty
        ? 0.0
        : pulses.map((p) => p.safe).reduce((a, b) => a + b) / pulses.length;

    final prompt = '''
You are "Aura", the AI Wisdom Guide for TrustCircle, a sanctuary app designed to build emotional safety and deepen relationships.
You are analyzing a Trust Circle. Your goal is to provide a highly empathetic, insightful, and unique piece of wisdom based on the members' daily pulse check-ins and gratitude expressions.

DATA:
- Number of daily check-ins (last 7 days): ${pulses.length}
- Average Trust Score: ${avgTrust.toStringAsFixed(1)}%
- Average "Feeling Heard" score: ${avgHeard.toStringAsFixed(1)}/10
- Average "Feeling Safe" score: ${avgSafe.toStringAsFixed(1)}/10
- Gratitude posts this week: $gratitudeCount

INSTRUCTIONS:
1. "summary": Provide a 2-3 sentence deeply empathetic analysis of their emotional safety and connection. Use warm, poetic, and encouraging language (e.g. "Your sanctuary is glowing with appreciation...").
2. "riskLevel": Must be exactly "Low", "Medium", or "High" based on the trust score.
3. "suggestion": A creative, non-generic 1-2 sentence actionable suggestion to foster deeper connection (e.g., "Consider a vulnerability hour where everyone shares one hidden stressor").
4. "conversationStarter": A thought-provoking, emotionally engaging question to spark meaningful dialogue.

Respond ONLY with valid JSON matching exactly this structure (no extra text, no markdown block wrappers like ```json):
{
  "summary": "",
  "riskLevel": "",
  "suggestion": "",
  "conversationStarter": ""
}
''';

    try {
      final response = await _getModel.generateContent([
        Content.text(prompt),
      ]);

      final text = response.text ?? '';
      // Extract JSON from response
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) throw Exception('Invalid JSON response from Gemini');

      final jsonStr = text.substring(jsonStart, jsonEnd + 1);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      return InsightModel(
        id: '',
        circleId: circleId,
        summary: data['summary'] as String? ?? '',
        riskLevel: data['riskLevel'] as String? ?? 'Low',
        suggestion: data['suggestion'] as String? ?? '',
        conversationStarter: data['conversationStarter'] as String? ?? '',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Return the actual error so the user can see what failed with the API
      return InsightModel(
        id: '',
        circleId: circleId,
        summary: 'AI Generation Failed: $e\n\nPlease check if your Gemini API key is valid and has billing/quotas enabled.',
        riskLevel: avgTrust >= 75 ? 'Low' : (avgTrust >= 50 ? 'Medium' : 'High'),
        suggestion: 'Ensure your API key is correctly injected using --dart-define=GEMINI_API_KEY=...',
        conversationStarter: 'Are we configured correctly?',
        timestamp: DateTime.now(),
      );
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // NEW FEATURES: Voice Check-In and Resolve Guide
  // ════════════════════════════════════════════════════════════════════════════

  Future<Map<String, double>> analyzeVoiceJournal(String transcript) async {
    final prompt = '''
    Analyze this journal entry for emotional indicators and suggest trust scores for: heard, respected, safe, connected. 
    The scores must be from 1 to 10.
    Journal entry: "$transcript"
    
    Respond ONLY with valid JSON matching exactly this structure:
    {
      "heard": 0.0,
      "respected": 0.0,
      "safe": 0.0,
      "connected": 0.0
    }
    ''';
    
    try {
      final response = await _getModel.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) throw Exception('Invalid JSON');
      
      final data = jsonDecode(text.substring(jsonStart, jsonEnd + 1)) as Map<String, dynamic>;
      return {
        'heard': (data['heard'] as num).toDouble(),
        'respected': (data['respected'] as num).toDouble(),
        'safe': (data['safe'] as num).toDouble(),
        'connected': (data['connected'] as num).toDouble(),
      };
    } catch (e) {
      debugPrint('Error analyzing voice: $e');
      return {'heard': 5.0, 'respected': 5.0, 'safe': 5.0, 'connected': 5.0};
    }
  }

  Future<String> generateResolveGuide(String circleId, double trustScore, List<dynamic> pulseData) async {
    final prompt = '''
    The trust score in this circle has dropped to ${trustScore.toStringAsFixed(0)}%. 
    Based on recent pulse data, generate a conflict resolution guide.
    Include 3 sections:
    1. Conflict Resolution Steps (numbered action items)
    2. Conversation Suggestions (specific phrases)
    3. Guided Questions (to ask each other)
    ''';
    
    try {
      final response = await _getModel.generateContent([Content.text(prompt)]);
      return response.text ?? 'Could not generate guide.';
    } catch (e) {
      debugPrint('Error generating resolve guide: \$e');
      return 'Failed to generate guide.';
    }
  }
}

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});
