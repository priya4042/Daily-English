import 'package:flutter/material.dart';
import '../store.dart';
import '../theme.dart';
import 'conversation_detail_screen.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final list = Store.instance.conversations;
    final groups = <String, List<Conversation>>{};
    for (final c in list) { (groups[c.level] ??= []).add(c); }
    Color lc(String l) => l == 'Beginner' ? kGood : l == 'Intermediate' ? kWarn : kBad;
    return Scaffold(
      appBar: AppBar(title: const Text('Conversations')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        const Padding(padding: EdgeInsets.fromLTRB(4, 0, 4, 6),
          child: Text('Listen to real two-person conversations, then practice speaking each line.', style: TextStyle(color: kMuted, fontSize: 13.5, height: 1.4))),
        for (final entry in groups.entries) ...[
          Padding(padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: lc(entry.key), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(entry.key.toUpperCase(), style: TextStyle(color: lc(entry.key), fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: .5)),
            ])),
          ...entry.value.map((c) => Padding(padding: const EdgeInsets.symmetric(vertical: 4),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ConversationDetailScreen(convo: c))),
              child: Container(padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kLine)),
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: kAccent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.forum_outlined, color: kAccent, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.title, style: const TextStyle(color: kInk, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(c.situation, style: const TextStyle(color: kMuted, fontSize: 12.5)),
                  ])),
                  const Icon(Icons.chevron_right, color: kMuted),
                ])),
            ))),
        ],
      ]),
    );
  }
}
