import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/settings.dart';
import 'faq_content.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.settings, required this.signedIn});
  final Settings settings;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text('Mere', style: theme.textTheme.headlineMedium),
            Text('Indstillinger, spørgsmål og kontakt',
                style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 24),

            Text('Dagsmål', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            _GoalCard(settings: settings),
            const SizedBox(height: 28),

            Text('Spørgsmål og svar', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < faq.length; i++) ...[
                    _FaqTile(item: faq[i]),
                    if (i < faq.length - 1) const Divider(indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text('Kontakt', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(Icons.mail_outline_rounded, color: scheme.primary),
                title: Text(contactEmail, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                subtitle: Text('Tryk for at kopiere',
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: contactEmail));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail kopieret')));
                },
              ),
            ),
            const SizedBox(height: 28),

            if (signedIn)
              TextButton.icon(
                onPressed: () => Supabase.instance.client.auth.signOut(),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Log ud'),
                style: TextButton.styleFrom(foregroundColor: scheme.onSurfaceVariant),
              ),
            const SizedBox(height: 8),
            Center(
              child: Text('Free Time · ingen reklamer, ingen datasalg',
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ),
          ],
        ),
      ),
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
                      child: Text('point om dagen', style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(_describe(goal), style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in Settings.goalPresets)
                      ChoiceChip(
                        label: Text('$p'),
                        selected: goal == p,
                        onSelected: (_) => settings.setDailyGoal(p),
                      ),
                    ActionChip(
                      label: const Text('Andet'),
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

  static String _describe(int goal) {
    final silentH = goal / 120;
    final airplaneH = goal / 240;
    return 'Svarer til ${_h(silentH)} lydløs eller ${_h(airplaneH)} i flytilstand.';
  }

  static String _h(double h) => h == h.roundToDouble() ? '${h.round()} t' : '${h.toStringAsFixed(1).replaceAll('.', ',')} t';

  Future<void> _custom(BuildContext context) async {
    final ctrl = TextEditingController(text: '${settings.dailyGoal}');
    final v = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dagsmål'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(suffixText: 'point'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuller')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text.trim())),
            child: const Text('Gem'),
          ),
        ],
      ),
    );
    if (v != null && v > 0) await settings.setDailyGoal(v);
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});
  final FaqItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(item.q, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.onSurfaceVariant,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.a, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}
