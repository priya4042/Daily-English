import 'package:flutter/material.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';
import 'practice_screen.dart';

class SentencesScreen extends StatefulWidget {
  const SentencesScreen({super.key});
  @override
  State<SentencesScreen> createState() => _SentencesScreenState();
}

class _SentencesScreenState extends State<SentencesScreen> {
  String? _cat;

  @override
  Widget build(BuildContext context) {
    final s = Store.instance;
    final cats = s.sentenceCategories;
    _cat ??= cats.first;
    final list = s.sentencesIn(_cat!);
    return Column(children: [
      const Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, 2),
        child: Align(alignment: Alignment.centerLeft, child: Text('Everyday Speaking', style: TextStyle(color: kInk, fontSize: 22, fontWeight: FontWeight.w800)))),
      const Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Align(alignment: Alignment.centerLeft, child: Text('Real sentences English speakers use. Tap to hear, or practice saying them.', style: TextStyle(color: kMuted, fontSize: 12.5)))),
      SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
        for (final c in cats) Padding(padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(label: Text(c), selected: _cat == c, onSelected: (_) => setState(() => _cat = c),
            selectedColor: kAccent, labelStyle: TextStyle(color: _cat == c ? Colors.white : kInk, fontWeight: FontWeight.w600), backgroundColor: kCard)),
      ])),
      const SizedBox(height: 6),
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final x = list[i];
          return Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kLine)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('"${x.text}"', style: const TextStyle(color: kInk, fontSize: 16.5, fontWeight: FontWeight.w700, height: 1.35))),
              ]),
              const SizedBox(height: 4),
              Text(x.note, style: const TextStyle(color: kMuted, fontSize: 12.5, height: 1.35)),
              const SizedBox(height: 8),
              Row(children: [
                _act(Icons.volume_up, 'Listen', kPrimary, () => Speech.instance.speak(x.text)),
                const SizedBox(width: 8),
                _act(Icons.slow_motion_video, 'Slow', kMuted, () => Speech.instance.speak(x.text, slow: true)),
                const Spacer(),
                _act(Icons.mic, 'Practice', kAccent, () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PracticeScreen(fixedText: x.text, fixedId: x.id)))),
              ]),
            ]),
          );
        })),
    ]);
  }

  Widget _act(IconData i, String label, Color color, VoidCallback onTap) => TextButton.icon(
    style: TextButton.styleFrom(foregroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    onPressed: onTap, icon: Icon(i, size: 18), label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)));
}
