import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class Word {
  final String id, word, say, meaning, example, level;
  Word.fromJson(Map<String, dynamic> j)
      : id = j['id'], word = j['word'], say = j['say'],
        meaning = j['meaning'], example = j['example'], level = j['level'];
}

class Sentence {
  final String id, category, text, note;
  Sentence.fromJson(Map<String, dynamic> j)
      : id = j['id'], category = j['category'], text = j['text'], note = j['note'];
}

class Phrase {
  final String id, phrase, meaning, example, type;
  Phrase.fromJson(Map<String, dynamic> j)
      : id = j['id'], phrase = j['phrase'], meaning = j['meaning'],
        example = j['example'], type = j['type'];
}

/// One point of a lesson (a rule/usage) with a speakable example.
class LessonItem {
  final String point, example;
  LessonItem.fromJson(Map<String, dynamic> j) : point = j['point'], example = j['example'];
}

/// A grammar rule or word-usage lesson (beginner -> advanced).
class Lesson {
  final String id, title, subtitle, level, tip;
  final List<LessonItem> items;
  Lesson.fromJson(Map<String, dynamic> j)
      : id = j['id'], title = j['title'], subtitle = j['subtitle'],
        level = j['level'], tip = j['tip'] ?? '',
        items = (j['items'] as List).map((e) => LessonItem.fromJson(e)).toList();
}

/// One line of a conversation.
class ConvLine {
  final String s, text; // s = 'A' or 'B'
  ConvLine.fromJson(Map<String, dynamic> j) : s = j['s'], text = j['text'];
}

/// A multiple-choice quiz question.
class Quiz {
  final String id, category, q, explain;
  final List<String> options;
  final int correct;
  Quiz.fromJson(Map<String, dynamic> j)
      : id = j['id'], category = j['category'], q = j['q'], explain = j['explain'] ?? '',
        options = (j['options'] as List).map((e) => e.toString()).toList(), correct = j['correct'];
}

/// A two-person dialogue for real-life speaking practice.
class Conversation {
  final String id, title, situation, level;
  final List<ConvLine> lines;
  Conversation.fromJson(Map<String, dynamic> j)
      : id = j['id'], title = j['title'], situation = j['situation'], level = j['level'],
        lines = (j['lines'] as List).map((e) => ConvLine.fromJson(e)).toList();
}

/// App settings (accent), persisted.
class Settings extends ChangeNotifier {
  Settings._();
  static final Settings instance = Settings._();
  String accent = 'en-US'; // 'en-US' | 'en-GB'
  bool reminderOn = false;
  int reminderHour = 20, reminderMin = 0;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    accent = p.getString('accent') ?? 'en-US';
    reminderOn = p.getBool('reminder_on') ?? false;
    reminderHour = p.getInt('reminder_h') ?? 20;
    reminderMin = p.getInt('reminder_m') ?? 0;
    notifyListeners();
  }

  Future<void> setAccent(String a) async {
    accent = a;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('accent', a);
  }

  Future<void> saveReminder() async {
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool('reminder_on', reminderOn);
    await p.setInt('reminder_h', reminderHour);
    await p.setInt('reminder_m', reminderMin);
  }
}

/// Loads content and tracks learning progress (learned words, streak, goal).
class Store extends ChangeNotifier {
  Store._();
  static final Store instance = Store._();

  final List<Word> words = [];
  final List<Sentence> sentences = [];
  final List<Phrase> phrases = [];
  final List<Lesson> grammar = [];
  final List<Lesson> usage = [];
  final List<Conversation> conversations = [];
  final List<Quiz> quizzes = [];
  int quizzesDone = 0;
  int bestQuizPercent = 0;

  final Set<String> _learned = {};      // word ids marked learned
  final Set<String> _practiced = {};    // ids practiced with a good score
  final Set<String> _favorites = {};    // favorited word/phrase/sentence ids
  final Set<String> _activity = {};     // 'YYYY-MM-DD' study days
  final Map<String, int> _learnedByDay = {};
  int dailyGoal = 5;
  bool loaded = false;

  Future<void> load() async {
    words.addAll((jsonDecode(await rootBundle.loadString('assets/words.json')) as List)
        .map((e) => Word.fromJson(e)));
    sentences.addAll((jsonDecode(await rootBundle.loadString('assets/sentences.json')) as List)
        .map((e) => Sentence.fromJson(e)));
    phrases.addAll((jsonDecode(await rootBundle.loadString('assets/phrases.json')) as List)
        .map((e) => Phrase.fromJson(e)));
    grammar.addAll((jsonDecode(await rootBundle.loadString('assets/grammar.json')) as List)
        .map((e) => Lesson.fromJson(e)));
    usage.addAll((jsonDecode(await rootBundle.loadString('assets/usage.json')) as List)
        .map((e) => Lesson.fromJson(e)));
    conversations.addAll((jsonDecode(await rootBundle.loadString('assets/conversations.json')) as List)
        .map((e) => Conversation.fromJson(e)));
    quizzes.addAll((jsonDecode(await rootBundle.loadString('assets/quiz.json')) as List)
        .map((e) => Quiz.fromJson(e)));
    final p = await SharedPreferences.getInstance();
    quizzesDone = p.getInt('quizzes_done') ?? 0;
    bestQuizPercent = p.getInt('best_quiz') ?? 0;
    _learned.addAll(p.getStringList('learned') ?? []);
    _practiced.addAll(p.getStringList('practiced') ?? []);
    _favorites.addAll(p.getStringList('favorites') ?? []);
    _activity.addAll(p.getStringList('activity') ?? []);
    dailyGoal = p.getInt('daily_goal') ?? 5;
    final lbd = p.getString('learned_by_day');
    if (lbd != null && lbd.isNotEmpty) {
      try { (jsonDecode(lbd) as Map<String, dynamic>).forEach((k, v) => _learnedByDay[k] = v as int); } catch (_) {}
    }
    loaded = true;
    notifyListeners();
  }

  // ---- Categories ----
  List<String> get sentenceCategories {
    final seen = <String>[];
    for (final s in sentences) { if (!seen.contains(s.category)) seen.add(s.category); }
    return seen;
  }
  List<Sentence> sentencesIn(String cat) => sentences.where((s) => s.category == cat).toList();
  List<Word> wordsOfLevel(String level) => words.where((w) => w.level == level).toList();

  // ---- Learned words ----
  bool isLearned(String id) => _learned.contains(id);
  int get learnedCount => _learned.length;
  double get progress => words.isEmpty ? 0 : _learned.length / words.length;
  Future<void> toggleLearned(String id) async {
    final added = !_learned.contains(id);
    added ? _learned.add(id) : _learned.remove(id);
    if (added) { _recordActivity(); _bumpToday(); }
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList('learned', _learned.toList());
  }

  // ---- Practice ----
  bool isPracticed(String id) => _practiced.contains(id);
  int get practicedCount => _practiced.length;
  Future<void> markPracticed(String id) async {
    if (_practiced.add(id)) {
      _recordActivity();
      final p = await SharedPreferences.getInstance();
      await p.setStringList('practiced', _practiced.toList());
      notifyListeners();
    }
  }

  // ---- Daily goal ----
  String _dayKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  void _bumpToday() {
    final k = _dayKey(DateTime.now());
    _learnedByDay[k] = (_learnedByDay[k] ?? 0) + 1;
    SharedPreferences.getInstance().then((p) => p.setString('learned_by_day', jsonEncode(_learnedByDay)));
  }
  int get learnedToday => _learnedByDay[_dayKey(DateTime.now())] ?? 0;
  double get goalProgress => dailyGoal <= 0 ? 1 : (learnedToday / dailyGoal).clamp(0, 1).toDouble();
  bool get goalMet => learnedToday >= dailyGoal;
  Future<void> setGoal(int g) async {
    dailyGoal = g.clamp(1, 50);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt('daily_goal', dailyGoal);
  }

  // ---- Streak ----
  Future<void> _recordActivity() async {
    final key = _dayKey(DateTime.now());
    if (_activity.add(key)) {
      final p = await SharedPreferences.getInstance();
      await p.setStringList('activity', _activity.toList());
    }
  }
  int get streak {
    if (_activity.isEmpty) return 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    if (!_activity.contains(_dayKey(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!_activity.contains(_dayKey(cursor))) return 0;
    }
    int c = 0;
    while (_activity.contains(_dayKey(cursor))) { c++; cursor = cursor.subtract(const Duration(days: 1)); }
    return c;
  }

  // ---- Favorites ----
  bool isFav(String id) => _favorites.contains(id);
  int get favCount => _favorites.length;
  Future<void> toggleFav(String id) async {
    _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList('favorites', _favorites.toList());
  }
  List<Word> get favWords => words.where((w) => _favorites.contains(w.id)).toList();
  List<Phrase> get favPhrases => phrases.where((p) => _favorites.contains(p.id)).toList();
  List<Sentence> get favSentences => sentences.where((s) => _favorites.contains(s.id)).toList();

  // ---- Quiz ----
  List<String> get quizCategories {
    final seen = <String>['All'];
    for (final q in quizzes) { if (!seen.contains(q.category)) seen.add(q.category); }
    return seen;
  }
  List<Quiz> quizzesIn(String cat) => cat == 'All' ? List.of(quizzes) : quizzes.where((q) => q.category == cat).toList();
  Future<void> recordQuiz(int percent) async {
    quizzesDone++;
    if (percent > bestQuizPercent) bestQuizPercent = percent;
    _recordActivity();
    final p = await SharedPreferences.getInstance();
    await p.setInt('quizzes_done', quizzesDone);
    await p.setInt('best_quiz', bestQuizPercent);
    notifyListeners();
  }

  // ---- Word of the day (stable per day) ----
  Word? get wordOfDay {
    if (words.isEmpty) return null;
    final n = DateTime.now();
    final seed = n.year * 10000 + n.month * 100 + n.day;
    return words[seed % words.length];
  }
}
