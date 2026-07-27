# Daily English — Speak & Learn

An **offline** Android app to learn **spoken English** — from beginner to advanced. Build vocabulary, master grammar, practice real conversations, and actually **speak**, with a feature most free apps don't have: **speak-and-check pronunciation practice** (the app listens and scores how you say a word or sentence).

Built with Flutter.

## Features

- **Vocabulary** — useful and difficult words with meaning, a simple "how to say it" pronunciation guide, and examples. Tap to hear each word in a natural **American or British** voice (plus slow playback).
- **Grammar Rules** — clear beginner-to-advanced lessons: tenses, articles, prepositions, modals, conditionals, passive voice, reported speech and more, each with spoken examples.
- **Everyday Speaking** — real sentences English speakers use, grouped by situation (greetings, work, restaurant, travel, phone calls…).
- **Conversations** — two-person dialogues (job interview, coffee shop, doctor, phone call…) you can listen to and practice line by line.
- **Word Usage** — which word to use when: its/it's, say/tell, do/make, much/many, since/for, and more.
- **Phrases & Idioms** — common expressions with meaning and examples.
- **Pronunciation Practice** — tap the mic, say it out loud, and get an instant pronunciation score with feedback (uses on-device speech recognition).
- **Quiz / Test Yourself** — grammar, vocabulary and usage questions with instant answers and explanations.
- **Daily habit** — Word of the Day, daily goal, streak, and an optional daily reminder.
- **Favorites** — save words, phrases and sentences for quick review.
- **Fully offline** — no internet needed.

## Tech Stack

- **Flutter** (Dart) — Android
- `flutter_tts` — native English pronunciation (US/UK)
- `speech_to_text` — speak-and-check pronunciation practice
- `flutter_local_notifications` + `timezone` — daily study reminders
- `shared_preferences` — local progress storage
- Content bundled as JSON assets

## Getting Started

```bash
flutter pub get
flutter run
```

To build a release APK:

```bash
flutter build apk --release
```

> Release signing is configured via `android/key.properties` (not committed). Create your own keystore to build a signed release.

## Content

Lessons live in `assets/` as simple JSON files (`words.json`, `grammar.json`, `conversations.json`, `usage.json`, `sentences.json`, `phrases.json`, `quiz.json`). The content is designed to grow — just add JSON entries, no code changes needed.

## License

All rights reserved.
