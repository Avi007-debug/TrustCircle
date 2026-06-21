
/// LocalAiService mimics the on-device AI functionality provided by Melange.
/// In a full production environment, this would load a .tflite model
/// exported from the Melange library or load a custom Melange model
/// directly on-device.
class LocalAiService {
  Future<Map<String, dynamic>> analyzeSentimentOffline(String text) async {
    // Mimic on-device processing delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final lowerText = text.toLowerCase();
    int score = 50;
    
    // Keyword-based fallback heuristic
    if (lowerText.contains('happy') || lowerText.contains('great') || lowerText.contains('good') || lowerText.contains('thanks')) {
      score += 30;
    }
    if (lowerText.contains('sad') || lowerText.contains('bad') || lowerText.contains('angry') || lowerText.contains('upset')) {
      score -= 30;
    }
    
    score = score.clamp(0, 100);
    
    String sentiment = 'neutral';
    String riskLevel = 'Medium';
    if (score > 60) {
      sentiment = 'positive';
      riskLevel = 'Low';
    } else if (score < 40) {
      sentiment = 'negative';
      riskLevel = 'High';
    }

    return {
      'sentiment': sentiment,
      'confidence': 0.85,
      'riskLevel': riskLevel,
      'suggestedScore': score,
      'source': 'Melange On-Device Model (Simulated)'
    };
  }
}

final localAiServiceProvider = LocalAiService();
