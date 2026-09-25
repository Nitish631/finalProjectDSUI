import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText speechToText = stt.SpeechToText();

  bool isListening = false;

  String recognizedText = '';

  Future<bool> initialize() async {
    final available = await speechToText.initialize(
      onStatus: (status) {
        print("Speech status: $status");
      },
      onError: (error) {
        print("Speech error: $error");
      },
    );

    return available;
  }

  Future<void> startListening({
    required Function(String text) onResult,
  }) async {
    if (!speechToText.isAvailable) {
      final available = await initialize();

      if (!available) {
        print("Speech recognition is not available");
        return;
      }
    }

    recognizedText = '';
    isListening = true;

    await speechToText.listen(
      onResult: (result) {
        recognizedText = result.recognizedWords;

        print("Recognized: $recognizedText");

        onResult(recognizedText);
      },
    );
  }

  Future<String> stopListening() async {
    await speechToText.stop();

    isListening = false;

    // Give the speech recognizer a moment to deliver
    // the final result.
    await Future.delayed(const Duration(milliseconds: 300));

    print("Final recognized text: $recognizedText");

    return recognizedText;
  }
}