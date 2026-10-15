import 'package:flutter/material.dart';

import '../native/free_time_platform.dart';
import 'l10n_ext.dart';

/// iOS: "how we measure". Shown once before the first session, and again from
/// More → Permissions. Explains each signal first; the OS prompt only appears
/// when the user taps Allow on that row. Both permissions are optional.
class MeasureIntroScreen extends StatefulWidget {
  const MeasureIntroScreen({super.key, required this.firstRun});

  /// First run: the primary button continues to the session. Otherwise the
  /// screen is informational and the button just closes it.
  final bool firstRun;

  static Future<bool> show(BuildContext context, {required bool firstRun}) async {
    final r = await Navigator.of(context).push<bool>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => MeasureIntroScreen(firstRun: firstRun)),
    );
    return r ?? false;
  }

  @override
  State<MeasureIntroScreen> createState() => _MeasureIntroScreenState();
}

class _MeasureIntroScreenState extends State<MeasureIntroScreen> {
  final _platform = FreeTimePlatform.instance;
  IosPermissions _perms = const IosPermissions(focus: false, screenTime: false);
  String? _busy;

  @override
  void initState() {
    super.initState();
    _platform.permissionStatus().then((p) {
      if (mounted) setState(() => _perms = p);
    });
  }

  Future<void> _request(String name) async {
    setState(() => _busy = name);
    final p = await _platform.requestPermission(name);
    if (!mounted) return;
    setState(() {
      _perms = p;
      _busy = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = context.l10n;
    final anyGranted = _perms.focus || _perms.screenTime;

    return Scaffold(
      appBar: AppBar(title: Text(t.measureTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(t.measureIntro, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            _Row(
              icon: Icons.spa_rounded,
              title: t.measureSessionTitle,
              body: t.measureSessionBody,
            ),
            const SizedBox(height: 12),
            _Row(
              icon: Icons.nightlight_round,
              title: t.measureFocusTitle,
              body: t.measureFocusBody,
              optional: t.measureOptional,
              granted: _perms.focus,
              busy: _busy == 'focus',
              onAllow: () => _request('focus'),
            ),
            const SizedBox(height: 12),
            _Row(
              icon: Icons.hourglass_bottom_rounded,
              title: t.measureScreenTimeTitle,
              body: t.measureScreenTimeBody,
              optional: t.measureOptional,
              granted: _perms.screenTime,
              busy: _busy == 'screenTime',
              onAllow: () => _request('screenTime'),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline_rounded, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(t.measurePrivacy,
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                ),
              ],
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(widget.firstRun && !anyGranted ? t.measureSkip : t.measureContinue),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.body,
    this.optional,
    this.granted,
    this.busy = false,
    this.onAllow,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? optional;
  final bool? granted;
  final bool busy;
  final VoidCallback? onAllow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: scheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
                if (optional != null && granted != true)
                  Text(optional!, style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 10),
            Text(body, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            if (onAllow != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: granted == true
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 18, color: scheme.primary),
                          const SizedBox(width: 6),
                          Text(t.measureAllowed,
                              style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary)),
                        ],
                      )
                    : FilledButton.tonal(
                        onPressed: busy ? null : onAllow,
                        child: Text(t.measureAllow),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
