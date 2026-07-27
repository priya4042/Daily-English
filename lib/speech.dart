import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'store.dart';

/// Wraps text-to-speech (native English pronunciation) and speech-to-text
/// (speak-and-check practice) into one simple helper.
class Speech {
  Speech._();
  static final Speech instance = Speech._();

  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  bool _sttReady = false;
  bool _awaitSet = false;
  void Function()? _onDone;

  /// Speak [text] in the chosen accent, optionally slowly. [pitch] lets
  /// dialogues use two slightly different voices for speaker A and B.
  Future<void> speak(String text, {bool slow = false, double pitch = 1.0, bool awaitDone = false}) async {
    await _tts.stop();
    if (awaitDone && !_awaitSet) { await _tts.awaitSpeakCompletion(true); _awaitSet = true; }
    await _tts.setLanguage(Settings.instance.accent); // 'en-US' or 'en-GB'
    await _tts.setSpeechRate(slow ? 0.32 : 0.46);
    await _tts.setPitch(pitch);
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() => _tts.stop();

  /// Ask the OS for microphone/speech permission and init recognition.
  Future<bool> initStt() async {
    if (_sttReady) return true;
    _sttReady = await _stt.initialize(
      onError: (_) {},
      onStatus: (s) { if (s == 'done' || s == 'notListening') _onDone?.call(); },
    );
    return _sttReady;
  }

  bool get isListening => _stt.isListening;

  /// Start listening; [onResult] is called with the recognized words (partial
  /// then final). [onDone] fires when listening stops.
  Future<void> listen(void Function(String words, bool isFinal) onResult, {void Function()? onDone}) async {
    _onDone = onDone;
    await _stt.listen(
      onResult: (r) => onResult(r.recognizedWords, r.finalResult),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenFor: const Duration(seconds: 8),
        pauseFor: const Duration(seconds: 3),
        localeId: Settings.instance.accent == 'en-GB' ? 'en_GB' : 'en_US',
      ),
    );
  }

  Future<void> stopListening() => _stt.stop();

  /// Score how closely [spoken] matches [target], 0..100, by word overlap.
  static int score(String target, String spoken) {
    List<String> norm(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9\s']"), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final t = norm(target);
    final s = norm(spoken);
    if (t.isEmpty) return 0;
    final pool = List<String>.from(s);
    int hit = 0;
    for (final w in t) {
      final i = pool.indexOf(w);
      if (i >= 0) { hit++; pool.removeAt(i); }
    }
    return ((hit / t.length) * 100).round();
  }
}
