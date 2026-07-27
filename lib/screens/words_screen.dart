import 'package:flutter/material.dart';
import '../ad_helper.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';
import 'word_detail_screen.dart';

class WordsScreen extends StatefulWidget {
  final InterstitialManager interstitial;
  const WordsScreen({super.key, required this.interstitial});
  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  String _level = 'All';
  static const _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];
  int _opened = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Store.instance,
      builder: (context, _) {
        final s = Store.instance;
        final list = _level == 'All' ? s.words : s.wordsOfLevel(_level);
        return Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(children: [
              const Text('Vocabulary', style: TextStyle(color: kInk, fontSize: 22, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('${s.learnedCount}/${s.words.length} learned', style: const TextStyle(color: kMuted, fontSize: 12.5)),
            ])),
          SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
            for (final l in _levels) Padding(padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(l), selected: _level == l,
                onSelected: (_) => setState(() => _level = l),
                selectedColor: kPrimary, labelStyle: TextStyle(color: _level == l ? Colors.white : kInk, fontWeight: FontWeight.w600),
                backgroundColor: kCard)),
          ])),
          const SizedBox(height: 6),
          Expanded(child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final w = list[i];
              final learned = s.isLearned(w.id);
              final col = levelColor(w.level);
              return GestureDetector(
                onTap: () {
                  if (_opened++ % 5 == 4) widget.interstitial.maybeShow();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => WordDetailScreen(word: w)));
                },
                child: Container(padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kLine)),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(w.word, style: const TextStyle(color: kInk, fontWeight: FontWeight.w800, fontSize: 17)),
                        const SizedBox(width: 8),
                        if (learned) const Icon(Icons.check_circle, color: kGood, size: 16),
                        const Spacer(),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: col.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
                          child: Text(w.level, style: TextStyle(color: col, fontSize: 10.5, fontWeight: FontWeight.w700))),
                      ]),
                      const SizedBox(height: 3),
                      Text(w.say, style: const TextStyle(color: kPrimary, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(w.meaning, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMuted, fontSize: 13)),
                    ])),
                    const SizedBox(width: 6),
                    IconButton(onPressed: () => Speech.instance.speak(w.word), icon: const Icon(Icons.volume_up, color: kPrimary)),
                  ]),
                ),
              );
            })),
        ]);
      },
    );
  }
}
