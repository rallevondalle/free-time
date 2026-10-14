import 'dart:async';

import 'package:flutter/material.dart';

import '../core/session.dart';
import '../data/session_repo.dart';
import '../native/free_time_platform.dart';

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
  // iOS honor-system claims for the running session.
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
    await _platform.startSession(
      selfReportedMode: _platform.isIOS ? _claimed : null,
    );
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
    final elapsed = _startedAt == null ? Duration.zero : DateTime.now().difference(_startedAt!);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Time'),
        actions: [if (widget.repo.isOffline) const Padding(
          padding: EdgeInsets.only(right: 16),
          child: Center(child: Text('offline')),
        )],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('$_todayPoints', style: theme.textTheme.displayLarge),
                    const Text('point i dag'),
                    const SizedBox(height: 8),
                    Text('${_fmt(_todayTime)} uden telefon', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_platform.isAndroid)
              ListTile(
                leading: Icon(
                  (_state?.serviceRunning ?? false) ? Icons.check_circle_outline : Icons.error_outline,
                ),
                title: const Text('Tæller automatisk, når telefonen er låst'),
                subtitle: Text(
                  _state == null
                      ? ''
                      : 'Lydprofil nu: ${_state!.mode.label} (${_state!.mode.multiplier}x). '
                          'Skærm tændt men låst: halve point.',
                ),
              ),
            if (_platform.isIOS && !_running) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('iOS kan ikke måle lydløs og flytilstand. Sæt det selv:'),
              ),
              SegmentedButton<SessionMode>(
                segments: const [
                  ButtonSegment(value: SessionMode.normal, label: Text('Lyd')),
                  ButtonSegment(value: SessionMode.silent, label: Text('Lydløs')),
                  ButtonSegment(value: SessionMode.airplane, label: Text('Fly')),
                ],
                selected: {_claimed},
                onSelectionChanged: (s) => setState(() => _claimed = s.first),
              ),
            ],
            const SizedBox(height: 24),
            if (_platform.isIOS) SizedBox(
              height: 72,
              child: _running
                  ? FilledButton.tonal(
                      onPressed: _stop,
                      child: Text('Stop  ·  ${_fmt(elapsed)}', style: theme.textTheme.titleLarge),
                    )
                  : FilledButton(
                      onPressed: _start,
                      child: Text('Læg telefonen fra dig', style: theme.textTheme.titleLarge),
                    ),
            ),
            const SizedBox(height: 24),
            Text('I dag', style: theme.textTheme.titleMedium),
            for (final s in _today)
              ListTile(
                dense: true,
                leading: Icon(s.verified ? Icons.verified_outlined : Icons.directions_walk),
                title: Text('${s.mode.label}${s.screenOn ? ' · skærm tændt' : ''} · ${_fmt(s.duration)}'),
                subtitle: Text(
                  '${_hm(s.startedAt)}–${_hm(s.endedAt)} · ${s.source.name}'
                  '${s.pickups > 0 ? ' · ${s.pickups} afbrydelser' : ''}',
                ),
                trailing: Text('+${s.points ?? s.estimatedPoints}'),
              ),
            if (_today.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Ingen sessioner endnu i dag.'),
              ),
          ],
        ),
      ),
    );
  }

  static String _fmt(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
    return h > 0 ? '${h}t ${m}m' : '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  static String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
