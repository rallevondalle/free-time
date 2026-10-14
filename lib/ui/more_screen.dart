import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../core/settings.dart';
import 'l10n_ext.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.settings, required this.signedIn});
  final Settings settings;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = context.l10n;
    final faq = _faqItems(t);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(t.moreTitle, style: theme.textTheme.headlineMedium),
            Text(t.moreSubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 24),

            Text(t.dailyGoal, style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            _GoalCard(settings: settings),
            const SizedBox(height: 28),

            Text(t.language, style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            _LanguageCard(settings: settings),
            const SizedBox(height: 28),

            Text(t.faqTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < faq.length; i++) ...[
                    _FaqTile(q: faq[i].$1, a: faq[i].$2),
                    if (i < faq.length - 1) const Divider(indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(t.contact, style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(Icons.mail_outline_rounded, color: scheme.primary),
                title: Text(contactEmail, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                subtitle: Text(t.tapToCopy, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: contactEmail));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.emailCopied)));
                },
              ),
            ),
            const SizedBox(height: 28),

            if (signedIn)
              TextButton.icon(
                onPressed: () => Supabase.instance.client.auth.signOut(),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(t.signOut),
                style: TextButton.styleFrom(foregroundColor: scheme.onSurfaceVariant),
              ),
            const SizedBox(height: 8),
            Center(child: Text(t.footer, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))),
          ],
        ),
      ),
    );
  }

  static List<(String, String)> _faqItems(AppLocalizations t) => [
        (t.faq1Q, t.faq1A),
        (t.faq2Q, t.faq2A),
        (t.faq3Q, t.faq3A),
        (t.faq4Q, t.faq4A),
        (t.faq5Q, t.faq5A),
        (t.faq6Q, t.faq6A),
        (t.faq7Q, t.faq7A),
        (t.faq8Q, t.faq8A),
        (t.faq9Q, t.faq9A),
        (t.faq10Q, t.faq10A),
        (t.faq11Q, t.faq11A),
        (t.faq12Q, t.faq12A(contactEmail)),
      ];
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.settings});
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final current = settings.locale?.languageCode;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String?>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: null, label: Text(t.languageSystem)),
                const ButtonSegment(value: 'da', label: Text('Dansk')),
                const ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {current},
              onSelectionChanged: (s) => settings.setLocale(s.first == null ? null : Locale(s.first!)),
            ),
          ),
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.settings});
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = context.l10n;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final goal = settings.dailyGoal;
        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$goal', style: theme.textTheme.headlineMedium?.copyWith(color: scheme.primary)),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(t.pointsPerDay, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(t.goalEquivalent(_h(context, goal / 120), _h(context, goal / 240)),
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in Settings.goalPresets)
                      ChoiceChip(label: Text('$p'), selected: goal == p, onSelected: (_) => settings.setDailyGoal(p)),
                    ActionChip(
                      label: Text(t.other),
                      avatar: const Icon(Icons.edit_rounded, size: 16),
                      onPressed: () => _custom(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _h(BuildContext context, double h) {
    final da = Localizations.localeOf(context).languageCode == 'da';
    final n = h == h.roundToDouble() ? '${h.round()}' : h.toStringAsFixed(1).replaceAll('.', da ? ',' : '.');
    return context.l10n.hoursShort(n);
  }

  Future<void> _custom(BuildContext context) async {
    final t = context.l10n;
    final ctrl = TextEditingController(text: '${settings.dailyGoal}');
    final v = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.dailyGoal),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(suffixText: t.pointsUnit),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text.trim())),
            child: Text(t.save),
          ),
        ],
      ),
    );
    if (v != null && v > 0) await settings.setDailyGoal(v);
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.q, required this.a});
  final String q;
  final String a;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(q, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.onSurfaceVariant,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(a, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}
