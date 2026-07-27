import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_helper.dart';
import 'notifications.dart';
import 'store.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/words_screen.dart';
import 'screens/sentences_screen.dart';
import 'screens/practice_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.instance.load();
  await Store.instance.load();
  await Notifs.init();
  await MobileAds.instance.initialize();
  runApp(const DailyEnglishApp());
}

class DailyEnglishApp extends StatelessWidget {
  const DailyEnglishApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily English',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final InterstitialManager interstitial = InterstitialManager(showEvery: 4);
  BannerAd? _banner;
  bool _bannerReady = false;

  @override
  void initState() {
    super.initState();
    interstitial.load();
    _loadBanner();
  }

  void _loadBanner() {
    _banner = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) { if (mounted) setState(() => _bannerReady = true); },
        onAdFailedToLoad: (ad, e) { ad.dispose(); _banner = null; },
      ),
    )..load();
  }

  @override
  void dispose() { _banner?.dispose(); interstitial.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(interstitial: interstitial, onGoTo: (i) => setState(() => _index = i)),
      WordsScreen(interstitial: interstitial),
      const SentencesScreen(),
      const PracticeScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_bannerReady && _banner != null)
          SizedBox(width: _banner!.size.width.toDouble(), height: _banner!.size.height.toDouble(),
            child: AdWidget(ad: _banner!)),
        NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Words'),
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Speaking'),
            NavigationDestination(icon: Icon(Icons.mic_none), selectedIcon: Icon(Icons.mic), label: 'Practice'),
          ],
        ),
      ]),
    );
  }
}
