import 'package:flutter/material.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';
import 'practice_screen.dart';

class ConversationDetailScreen extends StatefulWidget {
  final Conversation convo;
  const ConversationDetailScreen({super.key, required this.convo});
  @override
  State<ConversationDetailScreen> createState() => _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  bool _playing = false;
  int _current = -1;

  Future<void> _playAll() async {
    if (_playing) { setState(() { _playing = false; _current = -1; }); await Speech.instance.stopSpeaking(); return; }
    setState(() => _playing = true);
    final lines = widget.convo.lines;
    for (int i = 0; i < lines.length; i++) {
      if (!_playing || !mounted) break;
      setState(() => _current = i);
      await Speech.instance.speak(lines[i].text, pitch: lines[i].s == 'A' ? 1.06 : 0.82, awaitDone: true);
    }
    if (mounted) setState(() { _playing = false; _current = -1; });
  }

  @override
  void dispose() { Speech.instance.stopSpeaking(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.convo;
    return Scaffold(
      appBar: AppBar(title: const Text('Conversation')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.title, style: const TextStyle(color: kInk, fontSize: 20, fontWeight: FontWeight.w800)),
            Text(c.situation, style: const TextStyle(color: kMuted, fontSize: 13)),
          ])),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: c.lines.length,
          itemBuilder: (context, i) {
            final line = c.lines[i];
            final isA = line.s == 'A';
            final active = _current == i;
            return Align(
              alignment: isA ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                decoration: BoxDecoration(
                  color: active ? kAccent.withValues(alpha: 0.18) : (isA ? kCard : kPrimary.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isA ? 4 : 16), bottomRight: Radius.circular(isA ? 16 : 4)),
                  border: Border.all(color: active ? kAccent : kLine)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(isA ? 'Person A' : 'Person B', style: TextStyle(color: isA ? kMuted : kPrimary, fontSize: 10.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(line.text, style: const TextStyle(color: kInk, fontSize: 15.5, height: 1.35)),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    _mini(Icons.volume_up, () => Speech.instance.speak(line.text, pitch: isA ? 1.06 : 0.82)),
                    _mini(Icons.mic, () => Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeScreen(fixedText: line.text, fixedId: '${c.id}_$i')))),
                  ]),
                ]),
              ),
            );
          })),
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: SizedBox(width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _playing ? kBad : kPrimary, padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: _playAll,
            icon: Icon(_playing ? Icons.stop : Icons.play_arrow),
            label: Text(_playing ? 'Stop' : 'Play Conversation', style: const TextStyle(fontWeight: FontWeight.w700))))),
      ]),
    );
  }

  Widget _mini(IconData i, VoidCallback onTap) => IconButton(
    onPressed: onTap, icon: Icon(i, size: 18, color: kPrimary),
    padding: const EdgeInsets.all(4), constraints: const BoxConstraints(), visualDensity: VisualDensity.compact);
}
