import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gemini_service.dart';
import 'local_ai_service.dart';

final aiRouterServiceProvider = Provider<AiRouterService>((ref) {
  return AiRouterService(
    ref.read(geminiServiceProvider),
    LocalAiService(),
  );
});

class AiRouterService {
  final GeminiService _geminiService;
  final LocalAiService _localAiService;

  AiRouterService(this._geminiService, this._localAiService);

  /// Analyzes the text. If online and forceLocal is false, uses Gemini. Otherwise, uses Local AI.
  /// Returns a map with keys 'heard', 'respected', 'safe', 'connected' on a 1-10 scale.
  Future<Map<String, double>> analyzeVoiceJournal(String text, {bool forceLocal = false}) async {
    try {
      final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
      
      // If we are connected to mobile data, wifi, ethernet, or vpn, we are online.
      final bool isOnline = !connectivityResult.contains(ConnectivityResult.none) && connectivityResult.isNotEmpty;

      if (isOnline && !forceLocal) {
        debugPrint('🌍 AI Router: Network detected. Using Gemini API.');
        return await _geminiService.analyzeVoiceJournal(text);
      } else {
        debugPrint('📵 AI Router: No network detected. Using Local AI Service.');
        final localResult = await _localAiService.analyze(text);
        
        // Map LocalAI keys (0-100) to CheckinScreen keys (1-10)
        final trust = (localResult['trust'] as num?)?.toDouble() ?? 50.0;
        final connection = (localResult['connection'] as num?)?.toDouble() ?? 50.0;
        final stress = (localResult['stress'] as num?)?.toDouble() ?? 50.0;
        final support = (localResult['support'] as num?)?.toDouble() ?? 50.0;

        final mappedScores = {
          'heard': (support / 10).clamp(1.0, 10.0),
          'respected': (trust / 10).clamp(1.0, 10.0),
          'safe': ((100 - stress) / 10).clamp(1.0, 10.0),
          'connected': (connection / 10).clamp(1.0, 10.0),
        };
        debugPrint('🧠 AI Router Mapped Scores: $mappedScores');
        return mappedScores;
      }
    } catch (e) {
      debugPrint('AI Router Error: $e. Falling back to Local AI.');
      final localResult = await _localAiService.analyze(text);
        
      final trust = (localResult['trust'] as num?)?.toDouble() ?? 50.0;
      final connection = (localResult['connection'] as num?)?.toDouble() ?? 50.0;
      final stress = (localResult['stress'] as num?)?.toDouble() ?? 50.0;
      final support = (localResult['support'] as num?)?.toDouble() ?? 50.0;

      return {
        'heard': (support / 10).clamp(1.0, 10.0),
        'respected': (trust / 10).clamp(1.0, 10.0),
        'safe': ((100 - stress) / 10).clamp(1.0, 10.0),
        'connected': (connection / 10).clamp(1.0, 10.0),
      };
    }
  }
}
