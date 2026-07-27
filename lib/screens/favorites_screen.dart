import 'package:flutter/material.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';
import 'word_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Store.instance,
      builder: (context, _) {
        final s = Store.instance;
        final words = s.favWords, phrases = s.favPhrases, sentences = s.favSentences;
        final empty = words.isEmpty && phrases.isEmpty && sentences.isEmpty;
        return Scaffold(
          appBar: AppBar(title: const Text('My Favorites')),
          body: empty
            ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.favorite_border, size: 64, color: kMuted),
                SizedBox(height: 12),
                Text('No favorites yet', style: TextStyle(color: kInk, fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('Tap the heart on any word or phrase to save it here for quick review.',
                  textAlign: TextAlign.center, style: TextStyle(color: kMuted)),
              ])))
            : ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
                if (words.isNotEmpty) ...[
                  _head('WORDS'),
                  ...words.map((w) => _tile(context, w.word, w.meaning, w.id, () => Speech.instance.speak(w.word),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WordDetailScreen(word: w))))),
                ],
                if (phrases.isNotEmpty) ...[
                  _head('PHRASES & IDIOMS'),
                  ...phrases.map((p) => _tile(context, p.phrase, p.meaning, p.id, () => Speech.instance.speak(p.phrase))),
                ],
                if (sentences.isNotEmpty) ...[
                  _head('SENTENCES'),
                  ...sentences.map((x) => _tile(context, x.text, x.note, x.id, () => Speech.instance.speak(x.text))),
                ],
              ]),
        );
      },
    );
  }

  Widget _head(String t) => Padding(padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
    child: Text(t, style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .6)));

  Widget _tile(BuildContext context, String title, String sub, String id, VoidCallback onSpeak, {VoidCallback? onTap}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kLine)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: kInk, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMuted, fontSize: 12.5)),
          ])),
          IconButton(onPressed: onSpeak, icon: const Icon(Icons.volume_up, color: kPrimary)),
          IconButton(onPressed: () => Store.instance.toggleFav(id), icon: const Icon(Icons.favorite, color: Color(0xFFEC4899))),
        ])),
    ),
  );
}
