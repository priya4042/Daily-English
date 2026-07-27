import 'package:flutter/material.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';

class LessonDetailScreen extends StatelessWidget {
  final Lesson lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
        Text(lesson.title, style: const TextStyle(color: kInk, fontSize: 24, fontWeight: FontWeight.w900, height: 1.25)),
        const SizedBox(height: 4),
        Text(lesson.subtitle, style: const TextStyle(color: kMuted, fontSize: 14)),
        if (lesson.tip.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: kPrimary.withValues(alpha: 0.25))),
            child: Row(children: [
              const Icon(Icons.lightbulb, color: kPrimary, size: 20), const SizedBox(width: 10),
              Expanded(child: Text(lesson.tip, style: const TextStyle(color: kInk, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4))),
            ])),
        ],
        const SizedBox(height: 18),
        ...lesson.items.asMap().entries.map((e) => _item(e.key + 1, e.value)),
      ]),
    );
  }

  Widget _item(int n, LessonItem it) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kLine)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 24, height: 24, alignment: Alignment.center,
          decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Text('$n', style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w800, fontSize: 12))),
        const SizedBox(width: 10),
        Expanded(child: Text(it.point, style: const TextStyle(color: kInk, fontSize: 15, height: 1.45, fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () => Speech.instance.speak(it.example),
        child: Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: kField, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Expanded(child: Text('"${it.example}"', style: const TextStyle(color: kInk, fontSize: 14.5, fontStyle: FontStyle.italic, height: 1.4))),
            const SizedBox(width: 8),
            const Icon(Icons.volume_up, color: kPrimary, size: 20),
          ])),
      ),
    ]),
  );
}
