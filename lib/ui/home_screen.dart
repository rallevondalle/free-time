import 'dart:async';

import 'package:flutter/material.dart';

import '../core/session.dart';
import '../core/settings.dart';
import '../data/session_repo.dart';
import '../native/free_time_platform.dart';
import 'l10n_ext.dart';
import 'package:intl/intl.dart';

import 'points_ring.dart';
import 'theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repo, required this.settings});
  final SessionRepo repo;
  final Settings settings;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _platform = FreeTimePlatform.instance;
  StreamSubscription<Session>? _sub;
  Timer? _tick;

  DeviceState? _state;
  bool _running = false;
  DateTime? _startedAt;
  List<Session> _today = const [];
  SessionMode _claimed = SessionMode.normal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sub = _platform.sessions.listen((s) => widget.repo.submit([s]).then((_) => _refresh()));
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_running) setState(() {});
    });
    _platform.requestPermissions();
    widget.settings.addListener(_onSettings);
    _refresh();
  }

  void _onSettings() => setState(() {});

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.settings.removeListener(_onSettings);
    _sub?.cancel();
    _tick?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final pending = await _platform.drainPendingSessions();
    if (pending.isNotEmpty) await widget.repo.submit(pending);
    await widget.repo.flush();
    final state = await _platform.currentState();
    final running = await _platform.isSessionRunning();
    final today = await widget.repo.today();
    if (!mounted) return;
    setState(() {
      _state = state;
      _running = running;
      if (!running) _startedAt = null;
      _today = today;
    });
  }

  Future<void> _start() async {
    await _platform.startSession(selfReportedMode: _platform.isIOS ? _claimed : null);
    setState(() {
      _running = true;
      _startedAt = DateTime.now();
    });
  }

  Future<void> _stop() async {
    final finished = await _platform.stopSession();
    await widget.repo.submit(finished);
    await _refresh();
  }

  int get _todayPoints => _today.fold(0, (sum, s) => sum + (s.points ?? s.estimatedPoints));
  Duration get _todayTime => _today.fold(Duration.zero, (sum, s) => sum + s.duration);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = context.l10n;
    final elapsed = _startedAt == null ? Duration.zero : DateTime.now().difference(_startedAt!);
    final goal = widget.settings.dailyGoal;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              // ---- header ----
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting(t), style: theme.textTheme.headlineMedium),
                        Text(_dateLabel(Localizations.localeOf(context)), style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (widget.repo.isOffline) Pill(label: t.offline, icon: Icons.cloud_off_rounded),
                ],
              ),
              const SizedBox(height: 28),

              // ---- hero ----
              Center(
                child: PointsRing(
                  points: _todayPoints,
                  goal: goal,
                  subtitle: t.timeWithoutPhone(_fmt(_todayTime)),
                  label: t.pointsToday,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _todayPoints >= goal ? t.goalReached : t.goalLabel(goal),
                  style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 28),

              // ---- status / control ----
              if (_platform.isAndroid) _androidStatus(theme, t),
              if (_platform.isIOS) _iosControls(theme, t, elapsed),
              const SizedBox(height: 32),

              // ---- timeline ----
              Row(
                children: [
                  Text(t.today, style: theme.textTheme.titleLarge),
                  const Spacer(),
                  Text(t.sessionCount(_today.length),
                      style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 12),
              if (_today.isEmpty)
                _EmptyState(android: _platform.isAndroid)
              else
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < _today.length; i++) ...[
                        _SessionTile(session: _today[i]),
                        if (i < _today.length - 1) const Divider(indent: 68),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _androidStatus(ThemeData theme, AppLocalizations t) {
    final scheme = theme.colorScheme;
    final running = _state?.serviceRunning ?? false;
    final mode = _state?.mode ?? SessionMode.normal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (running ? scheme.primary : scheme.error).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(running ? Icons.radio_button_checked_rounded : Icons.error_outline_rounded,
                  color: running ? scheme.primary : scheme.error),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(running ? t.trackingOn : t.trackingOff, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(t.trackingHint,
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Pill(label: '${mode.multiplier}×', icon: modeIcon(mode), color: modeColor(mode, theme.brightness)),
          ],
        ),
      ),
    );
  }

  Widget _iosControls(ThemeData theme, AppLocalizations t, Duration elapsed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_running) ...[
          Text(t.howIsPhoneLying, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          SegmentedButton<SessionMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: SessionMode.normal, label: Text(t.modeShortNormal), icon: Icon(modeIcon(SessionMode.normal))),
              ButtonSegment(value: SessionMode.silent, label: Text(t.modeShortSilent), icon: Icon(modeIcon(SessionMode.silent))),
              ButtonSegment(value: SessionMode.airplane, label: Text(t.modeShortAirplane), icon: Icon(modeIcon(SessionMode.airplane))),
            ],
            selected: {_claimed},
            onSelectionChanged: (s) => setState(() => _claimed = s.first),
          ),
          const SizedBox(height: 16),
        ],
        _running
            ? FilledButton.tonal(onPressed: _stop, child: Text(t.stopWithTime(_fmt(elapsed))))
            : FilledButton(onPressed: _start, child: Text(t.putPhoneDown)),
      ],
    );
  }

  static String _greeting(AppLocalizations t) {
    final h = DateTime.now().hour;
    if (h < 5) return t.greetingNight;
    if (h < 10) return t.greetingMorning;
    if (h < 18) return t.greetingDay;
    return t.greetingEvening;
  }

  static String _dateLabel(Locale locale) =>
      DateFormat.MMMMEEEEd(locale.toString()).format(DateTime.now());

  String _fmt(Duration d) {
    final hu = Localizations.localeOf(context).languageCode == 'da' ? 't' : 'h';
    final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
    return h > 0 ? '$h$hu ${m}m' : '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = context.l10n;
    final s = session;
    final c = modeColor(s.mode, theme.brightness);
    final flags = <String>[
      if (s.screenOn) t.flagScreenOn,
      if (!s.verified) t.flagMoving,
      if (s.source == SessionSource.reboot) t.flagReboot,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: c.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
            child: Icon(modeIcon(s.mode), color: c, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${s.mode.label(t)} · ${_dur(context, s.duration)}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  '${_hm(s.startedAt)}–${_hm(s.endedAt)}${flags.isEmpty ? '' : ' · ${flags.join(', ')}'}',
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text('+${s.points ?? s.estimatedPoints}',
              style: theme.textTheme.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  static String _dur(BuildContext context, Duration d) {
    final hu = Localizations.localeOf(context).languageCode == 'da' ? 't' : 'h';
    final h = d.inHours, m = d.inMinutes % 60;
    return h > 0 ? '$h$hu ${m}m' : '${m}m';
  }

  static String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.android});
  final bool android;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.spa_rounded, size: 36, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(t.noSessionsTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              android ? t.noSessionsAndroid : t.noSessionsIos,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
