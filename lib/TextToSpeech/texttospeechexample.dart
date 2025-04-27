import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await _flutterTts.setLanguage("vi-VN");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }
}
