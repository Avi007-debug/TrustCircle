import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  Future<bool> init() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) => debugPrint('Speech to text error: $error'),
        onStatus: (status) => debugPrint('Speech to text status: $status'),
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('Failed to init speech to text: $e');
      return false;
    }
  }

  Future<void> startListening(Function(String) onResult) async {
    final isAvailable = await init();
    if (!isAvailable) return;

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;
}

final voiceService = VoiceService();
