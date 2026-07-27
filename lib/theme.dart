import 'package:flutter/material.dart';

// Friendly, encouraging learning-app palette (light).
const kPrimary = Color(0xFF5B5BF0);   // indigo
const kPrimaryDeep = Color(0xFF3B34C9);
const kAccent = Color(0xFF14B8A6);    // teal
const kBg = Color(0xFFF5F6FE);
const kCard = Color(0xFFFFFFFF);
const kInk = Color(0xFF1C1F33);
const kMuted = Color(0xFF6B7192);
const kLine = Color(0xFFE6E8F5);
const kField = Color(0xFFF0F1FB);
const kGood = Color(0xFF16A34A);
const kBad = Color(0xFFEF4444);
const kWarn = Color(0xFFF59E0B);

Color levelColor(String level) {
  switch (level) {
    case 'Beginner': return kGood;
    case 'Intermediate': return kWarn;
    case 'Advanced': return kBad;
    default: return kMuted;
  }
}

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: kBg,
      colorScheme: ColorScheme.fromSeed(seedColor: kPrimary, brightness: Brightness.light)
          .copyWith(primary: kPrimary, surface: kBg),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: kBg, foregroundColor: kInk, elevation: 0, centerTitle: false,
        titleTextStyle: TextStyle(color: kInk, fontSize: 20, fontWeight: FontWeight.w800),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
