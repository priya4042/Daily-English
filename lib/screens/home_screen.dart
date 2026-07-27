import 'package:flutter/material.dart';
import '../ad_helper.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';
import 'word_detail_screen.dart';
import 'phrases_screen.dart';
import 'practice_screen.dart';
import 'settings_screen.dart';
import 'lesson_list_screen.dart';
import 'conversations_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  final InterstitialManager interstitial;
  final void Function(int) onGoTo;
  const HomeScreen({super.key, required this.interstitial, required this.onGoTo});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Store.instance,
      builder: (context, _) {
        final s = Store.instance;
        final wod = s.wordOfDay;
        return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
          Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(gradient: const LinearGradient(colors: [kPrimary, kAccent]), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.record_voice_over, color: Colors.white, size: 24)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Daily English', style: TextStyle(color: kInk, fontSize: 20, fontWeight: FontWeight.w900)),
              Text('Words - Speaking - Pronunciation', style: TextStyle(color: kMuted, fontSize: 12)),
            ])),
            if (s.streak > 0)
              Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(color: kWarn.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
                child: Text('🔥 ${s.streak}', style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w800, fontSize: 12))),
            IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              icon: const Icon(Icons.settings_outlined, color: kMuted)),
          ]),
          const SizedBox(height: 12),
          // Word of the day
          if (wod != null) GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WordDetailScreen(word: wod))),
            child: Container(padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [kPrimary, kPrimaryDeep]), borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('WORD OF THE DAY', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                const SizedBox(height: 8),
                Row(children: [
                  Text(wod.word, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  GestureDetector(onTap: () => Speech.instance.speak(wod.word),
                    child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.volume_up, color: Colors.white))),
                ]),
                Text('say:  ${wod.say}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(wod.meaning, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.4)),
              ])),
          ),
          const SizedBox(height: 14),
          // Daily goal
          Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kLine)),
            child: Row(children: [
              SizedBox(width: 50, height: 50, child: Stack(alignment: Alignment.center, children: [
                SizedBox(width: 50, height: 50, child: CircularProgressIndicator(value: s.goalProgress, strokeWidth: 5, backgroundColor: kField, color: s.goalMet ? kGood : kPrimary)),
                Text('${s.learnedToday}', style: const TextStyle(color: kInk, fontWeight: FontWeight.w800)),
              ])),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.goalMet ? "Daily goal reached! 🎉" : "Today's goal", style: const TextStyle(color: kInk, fontWeight: FontWeight.w700, fontSize: 15)),
                Text('${s.learnedToday} of ${s.dailyGoal} words learned today', style: const TextStyle(color: kMuted, fontSize: 12.5)),
              ])),
            ])),
          const SizedBox(height: 18),
          const Text('Start Learning', style: TextStyle(color: kInk, fontSize: 16, fontWeight: FontWeight.w800)),
          const Text('Everything from beginner to advanced, in one place.', style: TextStyle(color: kMuted, fontSize: 12.5)),
          const SizedBox(height: 10),
          GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5, children: [
              _tile(Icons.menu_book, 'Vocabulary', '${s.words.length} words', kPrimary, () => onGoTo(1)),
              _tile(Icons.rule, 'Grammar Rules', '${s.grammar.length} lessons', const Color(0xFF6366F1),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonListScreen(title: 'Grammar Rules', subtitle: 'Learn the rules of English, from beginner to advanced. Tap any example to hear it.', lessons: s.grammar)))),
              _tile(Icons.chat_bubble, 'Everyday Speaking', '${s.sentences.length} sentences', kAccent, () => onGoTo(2)),
              _tile(Icons.forum, 'Conversations', '${s.conversations.length} dialogues', const Color(0xFF0EA5E9),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConversationsScreen()))),
              _tile(Icons.compare_arrows, 'Word Usage', '${s.usage.length} tricky pairs', const Color(0xFFEC4899),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonListScreen(title: 'Word Usage', subtitle: 'Which word to use when - common mix-ups made clear.', lessons: s.usage, grouped: false)))),
              _tile(Icons.auto_awesome, 'Phrases & Idioms', '${s.phrases.length} phrases', const Color(0xFFF59E0B),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PhrasesScreen()))),
            ]),
          const SizedBox(height: 16),
          // Progress
          Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kLine)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.insights, color: kPrimary, size: 18), const SizedBox(width: 8),
                const Text('Your progress', style: TextStyle(color: kInk, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${s.learnedCount} learned - ${s.practicedCount} practiced', style: const TextStyle(color: kMuted, fontSize: 12)),
              ]),
              const SizedBox(height: 12),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: s.progress, minHeight: 8, backgroundColor: kField, color: kAccent)),
            ])),
          const SizedBox(height: 14),
          // Quiz CTA
          _cta(context, Icons.quiz, 'Test Yourself', s.quizzesDone > 0 ? 'Best score: ${s.bestQuizPercent}%  -  quiz your grammar & words' : 'Quiz your grammar, words & usage',
            const [kPrimary, kPrimaryDeep], const QuizScreen()),
          const SizedBox(height: 12),
          // Pronunciation CTA
          _cta(context, Icons.mic, 'Practice Pronunciation', 'Speak out loud and get instant feedback',
            const [kAccent, Color(0xFF0D9488)], const PracticeScreen()),
        ]);
      },
    );
  }

  Widget _cta(BuildContext context, IconData icon, String title, String sub, List<Color> colors, Widget screen) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
    child: Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: Colors.white)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
          Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
        ])),
        const Icon(Icons.chevron_right, color: Colors.white70),
      ])),
  );

  Widget _tile(IconData icon, String title, String sub, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kLine)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 21)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: kInk, fontWeight: FontWeight.w700, fontSize: 14)),
          Text(sub, style: const TextStyle(color: kMuted, fontSize: 11.5)),
        ]),
      ])),
  );
}
