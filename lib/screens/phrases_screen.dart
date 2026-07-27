import 'package:flutter/material.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';

class PhrasesScreen extends StatefulWidget {
  const PhrasesScreen({super.key});
  @override
  State<PhrasesScreen> createState() => _PhrasesScreenState();
}

class _PhrasesScreenState extends State<PhrasesScreen> {
  String _type = 'all';

  @override
  Widget build(BuildContext context) {
    final all = Store.instance.phrases;
    final list = _type == 'all' ? all : all.where((p) => p.type == _type).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Phrases & Idioms')),
      body: Column(children: [
        SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          for (final t in const [['all', 'All'], ['idiom', 'Idioms'], ['phrase', 'Phrases']])
            Padding(padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(t[1]), selected: _type == t[0], onSelected: (_) => setState(() => _type = t[0]),
                selectedColor: kPrimary, labelStyle: TextStyle(color: _type == t[0] ? Colors.white : kInk, fontWeight: FontWeight.w600), backgroundColor: kCard)),
        ])),
        const SizedBox(height: 6),
        Expanded(child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final p = list[i];
            return Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kLine)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(p.phrase, style: const TextStyle(color: kInk, fontWeight: FontWeight.w800, fontSize: 16.5))),
                  IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => Speech.instance.speak(p.phrase), icon: const Icon(Icons.volume_up, color: kPrimary, size: 22)),
                  const SizedBox(width: 6),
                  IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                    onPressed: () { Store.instance.toggleFav(p.id); setState(() {}); },
                    icon: Icon(Store.instance.isFav(p.id) ? Icons.favorite : Icons.favorite_border, color: const Color(0xFFEC4899), size: 22)),
                ]),
                const SizedBox(height: 4),
                Text(p.meaning, style: const TextStyle(color: kInk, fontSize: 14, height: 1.4)),
                const SizedBox(height: 6),
                GestureDetector(onTap: () => Speech.instance.speak(p.example),
                  child: Text('e.g. "${p.example}"', style: const TextStyle(color: kMuted, fontSize: 13, fontStyle: FontStyle.italic))),
              ]),
            );
          })),
      ]),
    );
  }
}
