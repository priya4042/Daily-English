import 'package:flutter/material.dart';
import '../notifications.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';
import 'favorites_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _applyReminder() async {
    final s = Settings.instance;
    if (s.reminderOn) {
      await Notifs.requestPermission();
      await Notifs.scheduleDaily(s.reminderHour, s.reminderMin);
    } else {
      await Notifs.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([Settings.instance, Store.instance]),
      builder: (context, _) {
        final set = Settings.instance;
        final s = Store.instance;
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
            _section('ACCENT'),
            Container(decoration: _box(), child: Column(children: [
              _accentTile(context, 'American English', 'en-US', '🇺🇸', set),
              const Divider(height: 1, color: kLine),
              _accentTile(context, 'British English', 'en-GB', '🇬🇧', set),
            ])),
            const SizedBox(height: 8),
            _section('DAILY REMINDER'),
            Container(decoration: _box(), child: Column(children: [
              SwitchListTile(
                activeThumbColor: kPrimary,
                title: const Text('Daily study reminder', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Get a gentle nudge to practice every day'),
                value: set.reminderOn,
                onChanged: (v) async {
                  set.reminderOn = v; await set.saveReminder(); await _applyReminder();
                  if (v && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder set for ${TimeOfDay(hour: set.reminderHour, minute: set.reminderMin).format(context)}')));
                  }
                }),
              if (set.reminderOn)
                ListTile(
                  leading: const Icon(Icons.schedule, color: kMuted),
                  title: const Text('Reminder time'),
                  trailing: Text(TimeOfDay(hour: set.reminderHour, minute: set.reminderMin).format(context),
                    style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: set.reminderHour, minute: set.reminderMin));
                    if (t != null) { set.reminderHour = t.hour; set.reminderMin = t.minute; await set.saveReminder(); await _applyReminder(); }
                  }),
            ])),
            const SizedBox(height: 8),
            _section('MY FAVORITES'),
            Container(decoration: _box(), child: ListTile(
              leading: const Icon(Icons.favorite, color: Color(0xFFEC4899)),
              title: const Text('Saved favorites', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${s.favCount} saved words, phrases & sentences'),
              trailing: const Icon(Icons.chevron_right, color: kMuted),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
            )),
            const SizedBox(height: 8),
            _section('DAILY GOAL'),
            Container(padding: const EdgeInsets.all(16), decoration: _box(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('New words to learn per day', style: TextStyle(color: kInk, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(spacing: 10, children: [3, 5, 10, 15].map((g) {
                  final sel = s.dailyGoal == g;
                  return GestureDetector(onTap: () => s.setGoal(g),
                    child: Container(width: 52, height: 44, alignment: Alignment.center,
                      decoration: BoxDecoration(color: sel ? kPrimary : kField, borderRadius: BorderRadius.circular(12)),
                      child: Text('$g', style: TextStyle(color: sel ? Colors.white : kInk, fontWeight: FontWeight.w700, fontSize: 16))));
                }).toList()),
              ])),
            const SizedBox(height: 8),
            _section('ABOUT'),
            Container(decoration: _box(), child: const Column(children: [
              ListTile(leading: Icon(Icons.school_outlined, color: kPrimary), title: Text('Daily English'), subtitle: Text('Learn words, speaking & pronunciation - by Priya Tech Lab')),
              Divider(height: 1, color: kLine),
              ListTile(leading: Icon(Icons.verified_outlined, color: kPrimary), title: Text('Version'), subtitle: Text('1.0.0')),
            ])),
          ]),
        );
      },
    );
  }

  Widget _accentTile(BuildContext context, String title, String code, String flag, Settings set) {
    final sel = set.accent == code;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 22)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(onPressed: () { set.setAccent(code); Speech.instance.speak('Hello, this is how I sound.'); }, icon: const Icon(Icons.volume_up, color: kMuted)),
        if (sel) const Icon(Icons.check_circle, color: kGood) else const Icon(Icons.circle_outlined, color: kLine),
      ]),
      onTap: () => set.setAccent(code),
    );
  }

  BoxDecoration _box() => BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kLine));
  Widget _section(String t) => Padding(padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
    child: Text(t, style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .6)));
}
