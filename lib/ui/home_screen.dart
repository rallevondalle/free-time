import 'dart:async';

import 'package:flutter/material.dart';

import '../core/session.dart';
import '../data/session_repo.dart';
import '../native/free_time_platform.dart';
import 'points_ring.dart';
import 'theme.dart';

const _dailyGoal = 600;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repo});
  final SessionRepo repo;
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
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    final elapsed = _startedAt == null ? Duration.zero : DateTime.now().difference(_startedAt!);

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
                        Text(_greeting(), style: theme.textTheme.headlineMedium),
                        Text(_dateLabel(), style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (widget.repo.isOffline) const Pill(label: 'offline', icon: Icons.cloud_off_rounded),
                ],
              ),
              const SizedBox(height: 28),

              // ---- hero ----
              Center(
                child: PointsRing(
                  points: _todayPoints,
                  goal: _dailyGoal,
                  subtitle: '${_fmt(_todayTime)} uden telefon',
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _todayPoints >= _dailyGoal ? 'Dagens mål nået' : 'Mål: $_dailyGoal point',
                  style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 28),

              // ---- status / control ----
              if (_platform.isAndroid) _androidStatus(theme),
              if (_platform.isIOS) _iosControls(theme, elapsed),
              const SizedBox(height: 32),

              // ---- timeline ----
              Row(
                children: [
                  Text('I dag', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  Text('${_today.length} ${_today.length == 1 ? 'session' : 'sessioner'}',
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

  Widget _androidStatus(ThemeData theme) {
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
                  Text(running ? 'Tæller automatisk' : 'Tælleren kører ikke', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text('Når skærmen er låst. Skærm tændt giver halve point.',
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

  Widget _iosControls(ThemeData theme, Duration elapsed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_running) ...[
          Text('Hvordan ligger telefonen?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          SegmentedButton<SessionMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: SessionMode.normal, label: const Text('Lyd'), icon: Icon(modeIcon(SessionMode.normal))),
              ButtonSegment(value: SessionMode.silent, label: const Text('Lydløs'), icon: Icon(modeIcon(SessionMode.silent))),
              ButtonSegment(value: SessionMode.airplane, label: const Text('Fly'), icon: Icon(modeIcon(SessionMode.airplane))),
            ],
            selected: {_claimed},
            onSelectionChanged: (s) => setState(() => _claimed = s.first),
          ),
          const SizedBox(height: 16),
        ],
        _running
            ? FilledButton.tonal(onPressed: _stop, child: Text('Stop  ·  ${_fmt(elapsed)}'))
            : FilledButton(onPressed: _start, child: const Text('Læg telefonen fra dig')),
      ],
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'God nat';
    if (h < 10) return 'God morgen';
    if (h < 18) return 'God dag';
    return 'God aften';
  }

  static String _dateLabel() {
    const days = ['mandag', 'tirsdag', 'onsdag', 'torsdag', 'fredag', 'lørdag', 'søndag'];
    const months = ['jan', 'feb', 'mar', 'apr', 'maj', 'jun', 'jul', 'aug', 'sep', 'okt', 'nov', 'dec'];
    final n = DateTime.now();
    return '${days[n.weekday - 1]} ${n.day}. ${months[n.month - 1]}';
  }

  static String _fmt(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
    return h > 0 ? '${h}t ${m}m' : '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = session;
    final c = modeColor(s.mode, theme.brightness);
    final flags = <String>[
      if (s.screenOn) 'skærm tændt',
      if (!s.verified) 'i bevægelse',
      if (s.source == SessionSource.reboot) 'genstart',
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
                Text('${s.mode.label} · ${_dur(s.duration)}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
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

  static String _dur(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60;
    return h > 0 ? '${h}t ${m}m' : '${m}m';
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.spa_rounded, size: 36, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text('Ingen sessioner endnu', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              android
                  ? 'Lås telefonen og læg den fra dig. Resten sker af sig selv.'
                  : 'Tryk på knappen, og læg telefonen fra dig.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
