import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SttScreen extends StatefulWidget {
  SttScreen({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SttScreen> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    Future.delayed(const Duration(seconds: 5), () {
      speak("welcome to blind assistant");
      setState(() {});
    });
  }

  initTts() async {
    await flutterTts.setLanguage("en-us");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.awaitSpeakCompletion(true);
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult, localeId: "en_US");

    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  speak(String wordsToSay) async {
    await flutterTts.speak(wordsToSay);
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (_lastWords.contains('ahmed')) {
        Future.delayed(const Duration(seconds: 2), () {
          speak('hello ahmed');
        });
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _speechToText.isNotListening ? _startListening : _stopListening,
        child: Container(
          padding: EdgeInsets.all(16),
          color: Colors.black87,
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                color: Colors.white,
                size: 100.0,
              ),
              SizedBox(
                height: 50.0,
              ),
              Text(
                _speechToText.isListening
                    ? _lastWords
                    : _speechEnabled
                        ? 'Tap the microphone to start listening...'
                        : 'Speech not available',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
