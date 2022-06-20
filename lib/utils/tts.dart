import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TTS {
  late FlutterTts tts;
  late List<dynamic> languages;
  late TtsState ttsState;

  TTS() {
    ttsState = TtsState.stopped;
    tts = FlutterTts();
    initializeTTS();
  }

  initializeTTS() async {
    languages = await tts.getLanguages;

    await tts.setLanguage("en-US");

    await tts.setSpeechRate(0.3);

    await tts.setVolume(5.0);

    await tts.setPitch(1.0);

    await tts.isLanguageAvailable("en-US");
  }

  Future speak(String text) async {
    var result = await tts.speak(text);
    if (result == 1) ttsState = TtsState.playing;
  }
}
