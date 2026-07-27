import 'package:flutter/material.dart';
import '../store.dart';
import '../theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String _cat = 'All';
  List<Quiz>? _quiz;
  int _i = 0, _correct = 0, _picked = -1;
  bool _answered = false;

  void _start() {
    final pool = Store.instance.quizzesIn(_cat)..shuffle();
    setState(() { _quiz = pool.take(10).toList(); _i = 0; _correct = 0; _picked = -1; _answered = false; });
  }

  void _pick(int i) {
    if (_answered) return;
    setState(() { _picked = i; _answered = true; if (i == _quiz![_i].correct) _correct++; });
  }

  void _next() {
    if (_i < _quiz!.length - 1) {
      setState(() { _i++; _picked = -1; _answered = false; });
    } else {
      final pct = (_correct / _quiz!.length * 100).round();
      Store.instance.recordQuiz(pct);
      setState(() => _i = _quiz!.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz - Test Yourself')),
      body: _quiz == null ? _setup() : (_i >= _quiz!.length ? _result() : _run()),
    );
  }

  Widget _setup() {
    final cats = Store.instance.quizCategories;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
      const Icon(Icons.quiz, size: 56, color: kPrimary),
      const SizedBox(height: 12),
      const Center(child: Text('Test Your English', style: TextStyle(color: kInk, fontSize: 20, fontWeight: FontWeight.w800))),
      const SizedBox(height: 6),
      const Center(child: Text('10 questions with instant answers and explanations.', textAlign: TextAlign.center, style: TextStyle(color: kMuted))),
      const SizedBox(height: 24),
      const Text('Choose a topic', style: TextStyle(color: kInk, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Wrap(spacing: 10, runSpacing: 10, children: cats.map((c) => ChoiceChip(
        label: Text(c), selected: _cat == c, onSelected: (_) => setState(() => _cat = c),
        selectedColor: kPrimary, labelStyle: TextStyle(color: _cat == c ? Colors.white : kInk, fontWeight: FontWeight.w600),
        backgroundColor: kCard)).toList()),
      const SizedBox(height: 24),
      FilledButton(style: FilledButton.styleFrom(backgroundColor: kPrimary, padding: const EdgeInsets.symmetric(vertical: 15)),
        onPressed: _start, child: const Text('Start Quiz', style: TextStyle(fontWeight: FontWeight.w700))),
    ]);
  }

  Widget _run() {
    final q = _quiz![_i];
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Row(children: [
        Text('Question ${_i + 1} of ${_quiz!.length}', style: const TextStyle(color: kMuted)),
        const Spacer(),
        Text('Score $_correct', style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: _i / _quiz!.length, minHeight: 5, backgroundColor: kField, color: kPrimary))),
      Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: kAccent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
          child: Text(q.category, style: const TextStyle(color: kAccent, fontSize: 11, fontWeight: FontWeight.w700))),
        const SizedBox(height: 14),
        Text(q.q, style: const TextStyle(color: kInk, fontSize: 20, fontWeight: FontWeight.w700, height: 1.35)),
        const SizedBox(height: 18),
        ...List.generate(q.options.length, (i) => _option(q, i)),
        if (_answered) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: kField, borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline, color: kPrimary, size: 20), const SizedBox(width: 10),
              Expanded(child: Text(q.explain, style: const TextStyle(color: kInk, fontSize: 14, height: 1.4))),
            ])),
        ],
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: SizedBox(width: double.infinity,
        child: FilledButton(style: FilledButton.styleFrom(backgroundColor: _answered ? kPrimary : kLine, padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: _answered ? _next : null,
          child: Text(_i == _quiz!.length - 1 ? 'See Result' : 'Next', style: const TextStyle(fontWeight: FontWeight.w700))))),
    ]);
  }

  Widget _option(Quiz q, int i) {
    Color border = kLine, bg = kCard, fg = kInk;
    IconData? icon;
    if (_answered) {
      if (i == q.correct) { border = kGood; bg = kGood.withValues(alpha: 0.1); fg = kGood; icon = Icons.check_circle; }
      else if (i == _picked) { border = kBad; bg = kBad.withValues(alpha: 0.1); fg = kBad; icon = Icons.cancel; }
    }
    return GestureDetector(
      onTap: () => _pick(i),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 1.5)),
        child: Row(children: [
          Expanded(child: Text(q.options[i], style: TextStyle(color: fg, fontSize: 15.5, fontWeight: FontWeight.w600))),
          if (icon != null) Icon(icon, color: fg, size: 20),
        ]),
      ),
    );
  }

  Widget _result() {
    final total = _quiz!.length;
    final pct = (_correct / total * 100).round();
    final good = pct >= 70;
    return Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(good ? '🎉' : '💪', style: const TextStyle(fontSize: 56)),
      const SizedBox(height: 8),
      Text('$_correct / $total correct', style: const TextStyle(color: kInk, fontSize: 26, fontWeight: FontWeight.w900)),
      Text('$pct%', style: TextStyle(color: good ? kGood : kWarn, fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text(good ? 'Great work! Keep it up.' : 'Good effort - review and try again.', textAlign: TextAlign.center, style: const TextStyle(color: kMuted)),
      const SizedBox(height: 24),
      SizedBox(width: 200, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: kPrimary, padding: const EdgeInsets.symmetric(vertical: 13)),
        onPressed: () => setState(() => _quiz = null), child: const Text('New Quiz'))),
      const SizedBox(height: 8),
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
    ])));
  }
}
