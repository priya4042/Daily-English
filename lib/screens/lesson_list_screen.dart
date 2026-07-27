import 'package:flutter/material.dart';
import '../store.dart';
import '../theme.dart';
import 'lesson_detail_screen.dart';

/// A list of lessons (grammar or word usage), grouped by level when useful.
class LessonListScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Lesson> lessons;
  final bool grouped;
  const LessonListScreen({super.key, required this.title, required this.subtitle, required this.lessons, this.grouped = true});

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Lesson>>{};
    for (final l in lessons) { (groups[l.level] ??= []).add(l); }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        Padding(padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(subtitle, style: const TextStyle(color: kMuted, fontSize: 13.5, height: 1.4))),
        if (grouped)
          for (final entry in groups.entries) ...[
            Padding(padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: _levelColor(entry.key), shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(entry.key.toUpperCase(), style: TextStyle(color: _levelColor(entry.key), fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: .5)),
              ])),
            ...entry.value.map((l) => _row(context, l)),
          ]
        else
          ...lessons.map((l) => _row(context, l)),
      ]),
    );
  }

  Color _levelColor(String l) {
    switch (l) {
      case 'Beginner': return kGood;
      case 'Intermediate': return kWarn;
      case 'Advanced': return kBad;
      default: return kPrimary;
    }
  }

  Widget _row(BuildContext context, Lesson l) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: l))),
      child: Container(padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kLine)),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(11)),
            child: const Icon(Icons.menu_book_outlined, color: kPrimary, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.title, style: const TextStyle(color: kInk, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text(l.subtitle, style: const TextStyle(color: kMuted, fontSize: 12.5)),
          ])),
          const Icon(Icons.chevron_right, color: kMuted),
        ])),
    ),
  );
}
