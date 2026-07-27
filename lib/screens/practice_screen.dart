import 'package:flutter/material.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';

/// Speak-and-check pronunciation practice. Without [fixedText] it cycles a mix
/// of words and sentences; with it, you practice one specific phrase.
class PracticeScreen extends StatefulWidget {
  final String? fixedText;
  final String? fixedId;
  const PracticeScreen({super.key, this.fixedText, this.fixedId});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final List<MapEntry<String, String>> _pool; // id -> text
  int _i = 0;
  String _heard = '';
  int? _score;
  bool _listening = false;
  bool _noMic = false;

  @override
  void initState() {
    super.initState();
    if (widget.fixedText != null) {
      _pool = [MapEntry(widget.fixedId ?? 'fixed', widget.fixedText!)];
    } else {
      final s = Store.instance;
      final list = <MapEntry<String, String>>[
        ...s.words.map((w) => MapEntry(w.id, w.word)),
        ...s.sentences.map((x) => MapEntry(x.id, x.text)),
      ]..shuffle();
      _pool = list.take(40).toList();
    }
  }

  String get _target => _pool[_i].value;
  String get _targetId => _pool[_i].key;

  Future<void> _listen() async {
    if (_listening) { await Speech.instance.stopListening(); setState(() => _listening = false); return; }
    final ok = await Speech.instance.initStt();
    if (!ok) { setState(() => _noMic = true); return; }
    setState(() { _heard = ''; _score = null; _listening = true; });
    await Speech.instance.listen((words, isFinal) {
      setState(() => _heard = words);
      if (isFinal) _finish();
    }, onDone: _finish);
  }

  void _finish() {
    if (!_listening) return;
    final sc = Speech.score(_target, _heard);
    Store.instance.markPracticed(_targetId);
    setState(() { _score = sc; _listening = false; });
  }

  void _next() {
    setState(() { _i = (_i + 1) % _pool.length; _heard = ''; _score = null; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pronunciation Practice')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(children: [
          const Text('Listen, then tap the mic and say it out loud.', style: TextStyle(color: kMuted)),
          const SizedBox(height: 16),
          // Target card
          Container(width: double.infinity, padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: kLine)),
            child: Column(children: [
              Text(_target, textAlign: TextAlign.center, style: const TextStyle(color: kInk, fontSize: 24, fontWeight: FontWeight.w800, height: 1.3)),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _pill(Icons.volume_up, 'Listen', () => Speech.instance.speak(_target)),
                const SizedBox(width: 10),
                _pill(Icons.slow_motion_video, 'Slow', () => Speech.instance.speak(_target, slow: true)),
              ]),
            ])),
          const SizedBox(height: 24),
          Expanded(child: Center(child: _feedback())),
          // Mic button
          GestureDetector(
            onTap: _listen,
            child: Container(width: 88, height: 88,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: LinearGradient(colors: _listening ? [kBad, const Color(0xFFB91C1C)] : [kAccent, const Color(0xFF0D9488)]),
                boxShadow: [BoxShadow(color: (_listening ? kBad : kAccent).withValues(alpha: 0.4), blurRadius: 18, spreadRadius: 2)]),
              child: Icon(_listening ? Icons.stop : Icons.mic, color: Colors.white, size: 40)),
          ),
          const SizedBox(height: 10),
          Text(_listening ? 'Listening... tap to stop' : 'Tap to speak', style: const TextStyle(color: kMuted)),
          const SizedBox(height: 12),
          if (widget.fixedText == null)
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 13)),
              onPressed: _next, icon: const Icon(Icons.skip_next), label: const Text('Next word'))),
        ]),
      ),
    );
  }

  Widget _feedback() {
    if (_noMic) {
      return const Padding(padding: EdgeInsets.all(16),
        child: Text('Microphone or speech recognition is not available on this device. You can still Listen to the correct pronunciation above.',
          textAlign: TextAlign.center, style: TextStyle(color: kMuted)));
    }
    if (_listening) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎧', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(_heard.isEmpty ? 'Say it now...' : '"$_heard"', textAlign: TextAlign.center,
          style: const TextStyle(color: kInk, fontSize: 18, fontWeight: FontWeight.w600)),
      ]);
    }
    if (_score == null) {
      return const Text('Your result will appear here.', style: TextStyle(color: kMuted));
    }
    final s = _score!;
    final good = s >= 80, ok = s >= 50;
    final color = good ? kGood : ok ? kWarn : kBad;
    final emoji = good ? '🎉' : ok ? '👍' : '🔁';
    final msg = good ? 'Excellent pronunciation!' : ok ? 'Good try - say it once more.' : 'Keep practicing - listen and repeat.';
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 44)),
      const SizedBox(height: 6),
      Text('$s%', style: TextStyle(color: color, fontSize: 34, fontWeight: FontWeight.w900)),
      Text(msg, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      if (_heard.isNotEmpty)
        Text('You said: "$_heard"', textAlign: TextAlign.center, style: const TextStyle(color: kMuted, fontSize: 13)),
    ]);
  }

  Widget _pill(IconData i, String label, VoidCallback onTap) => FilledButton.icon(
    style: FilledButton.styleFrom(backgroundColor: kField, foregroundColor: kPrimary,
      elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
    onPressed: onTap, icon: Icon(i, size: 18), label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)));
}
