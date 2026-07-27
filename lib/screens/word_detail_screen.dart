import 'package:flutter/material.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';
import 'practice_screen.dart';

class WordDetailScreen extends StatelessWidget {
  final Word word;
  const WordDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Store.instance,
      builder: (context, _) {
        final learned = Store.instance.isLearned(word.id);
        final fav = Store.instance.isFav(word.id);
        return Scaffold(
          appBar: AppBar(title: const Text('Word'), actions: [
            IconButton(
              onPressed: () => Store.instance.toggleFav(word.id),
              icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: const Color(0xFFEC4899))),
          ]),
          body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kPrimary, kPrimaryDeep]),
                borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(word.word, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(20)),
                    child: Text(word.level, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.volume_up, color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text('say:  ${word.say}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _btn(Icons.volume_up, 'Listen', kPrimary, () => Speech.instance.speak(word.word))),
              const SizedBox(width: 12),
              Expanded(child: _btn(Icons.slow_motion_video, 'Slow', kAccent, () => Speech.instance.speak(word.word, slow: true))),
            ]),
            const SizedBox(height: 20),
            _label('MEANING'),
            Text(word.meaning, style: const TextStyle(color: kInk, fontSize: 16, height: 1.5)),
            const SizedBox(height: 18),
            _label('EXAMPLE'),
            GestureDetector(
              onTap: () => Speech.instance.speak(word.example),
              child: Container(
                padding: const EdgeInsets.all(14), width: double.infinity,
                decoration: BoxDecoration(color: kField, borderRadius: BorderRadius.circular(12), border: Border.all(color: kLine)),
                child: Row(children: [
                  Expanded(child: Text('"${word.example}"', style: const TextStyle(color: kInk, fontSize: 15.5, fontStyle: FontStyle.italic, height: 1.4))),
                  const Icon(Icons.volume_up, color: kPrimary, size: 20),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: kAccent, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeScreen(fixedText: word.word, fixedId: word.id))),
              icon: const Icon(Icons.mic), label: const Text('Practice Saying It')),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: learned ? kGood : kPrimary,
                side: BorderSide(color: learned ? kGood : kLine),
                padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () => Store.instance.toggleLearned(word.id),
              icon: Icon(learned ? Icons.check_circle : Icons.check_circle_outline),
              label: Text(learned ? 'Learned' : 'Mark as Learned')),
          ]),
        );
      },
    );
  }

  Widget _btn(IconData i, String label, Color color, VoidCallback onTap) => FilledButton.icon(
    style: FilledButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14)),
    onPressed: onTap, icon: Icon(i), label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)));

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(color: kMuted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .6)));
}
