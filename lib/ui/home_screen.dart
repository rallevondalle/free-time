import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../core/session.dart';
import '../core/settings.dart';
import '../data/session_repo.dart';
import '../native/free_time_platform.dart';
import 'l10n_ext.dart';
import 'package:intl/intl.dart';

import 'measure_intro_screen.dart';
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
  // iOS, airplane only: what the user says is still switched on.
  bool _claimedWifiOn = false;
  bool _claimedBtOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sub = _platform.sessions.listen((s) => widget.repo.submit([s]).then((_) => _refresh()));
    var ticks = 0;
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_running) setState(() {});
      // Android: the mode can change under us (quick settings never pauses the
      // activity), so poll it while the screen is visible.
      if (_platform.isAndroid && ++ticks % 2 == 0) _pollState();
    });
    // Android needs its permissions up front for the always-on counter.
    // iOS asks from the "how we measure" screen before the first session.
    if (_platform.isAndroid) _platform.requestPermissions();
    widget.settings.addListener(_onSettings);
    _refresh();
  }

  void _onSettings() => setState(() {});

  Future<void> _pollState() async {
    final state = await _platform.currentState();
    if (!mounted) return;
    if (state.mode != _state?.mode ||
        state.serviceRunning != _state?.serviceRunning ||
        state.wifiOn != _state?.wifiOn ||
        state.bluetoothOn != _state?.bluetoothOn) {
      setState(() => _state = state);
    }
  }

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

  /// Draw first from what is on the phone (queue + cache), then try the
  /// network. In airplane mode the first pass is all the user ever sees.
  Future<void> _refresh() async {
    final pending = await _platform.drainPendingSessions();
    if (pending.isNotEmpty) await widget.repo.enqueue(pending);
    final state = await _platform.currentState();
    final running = await _platform.isSessionRunning();
    await _loadToday(state: state, running: running);
    await widget.repo.flush();
    await _loadToday();
  }

  Future<void> _loadToday({DeviceState? state, bool? running}) async {
    List<Session> today;
    try {
      today = await widget.repo.today();
    } catch (_) {
      today = _today; // nothing cached yet: keep what we have
    }
    if (!mounted) return;
    setState(() {
      if (state != null) _state = state;
      if (running != null) {
        _running = running;
        _startedAt = running ? (_startedAt ?? state?.sessionStartedAt ?? DateTime.now()) : null;
      }
      _today = today;
    });
  }

  Future<void> _start() async {
    if (_platform.isIOS && !widget.settings.measureIntroSeen) {
      final go = await MeasureIntroScreen.show(context, firstRun: true);
      await widget.settings.setMeasureIntroSeen();
      if (!go || !mounted) return;
    }
    await _platform.startSession(
      selfReportedMode: _platform.isIOS ? _claimed : null,
      wifiOn: _claimedWifiOn,
      bluetoothOn: _claimedBtOn,
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

  Duration get _elapsed => _startedAt == null ? Duration.zero : DateTime.now().difference(_startedAt!);

  /// The mode a session would get right now. Android: measured. iOS: the
  /// self-reported mode, unless a measured Focus beats it (mirrors the bridge).
  SessionMode get _effectiveMode {
    final measured = _state?.mode ?? SessionMode.normal;
    if (_platform.isAndroid) return measured;
    if (measured == SessionMode.dnd && _claimed.multiplier < SessionMode.dnd.multiplier) return SessionMode.dnd;
    return _claimed;
  }

  bool get _unverified => _platform.isIOS && !(_state?.screenTime ?? false);

  bool get _wifiOn => _platform.isAndroid ? (_state?.wifiOn ?? false) : _claimedWifiOn;
  bool get _bluetoothOn => _platform.isAndroid ? (_state?.bluetoothOn ?? false) : _claimedBtOn;

  /// Points per minute right now, mirrors [Session.estimatedPoints].
  double get _factor =>
      _effectiveMode.multiplierWith(wifiOn: _wifiOn, bluetoothOn: _bluetoothOn) * (_unverified ? 0.5 : 1.0);

  /// Live preview of the running session.
  int get _livePoints => _running ? (_elapsed.inSeconds / 60.0 * _factor).floor() : 0;

  int get _todayPoints =>
      _today.fold(0, (sum, s) => sum + (s.points ?? s.estimatedPoints)) + _livePoints;
  Duration get _todayTime =>
      _today.fold(Duration.zero, (sum, s) => sum + s.duration) + (_running ? _elapsed : Duration.zero);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = context.l10n;
    final elapsed = _elapsed;
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

              // ---- factor ----
              _factorCard(theme, t),
              const SizedBox(height: 12),

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

  /// The multiplier, big and unmissable, with what makes it up.
  Widget _factorCard(ThemeData theme, AppLocalizations t) {
    final scheme = theme.colorScheme;
    final mode = _effectiveMode;
    final c = modeColor(mode, theme.brightness);
    final locale = Localizations.localeOf(context).toString();
    final factorText = NumberFormat('0.0#', locale).format(_factor);
    final measuredFocus = _platform.isIOS && _state?.mode == SessionMode.dnd;
    final chips = <Widget>[
      Pill(label: mode.label(t), icon: modeIcon(mode), color: c),
      if (mode == SessionMode.airplane) ...[
        Pill(label: _wifiOn ? t.radioWifiOn : t.radioWifiOff, icon: _wifiOn ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: _wifiOn ? scheme.onSurfaceVariant : c),
        Pill(label: _bluetoothOn ? t.radioBluetoothOn : t.radioBluetoothOff,
            icon: _bluetoothOn ? Icons.bluetooth_rounded : Icons.bluetooth_disabled_rounded,
            color: _bluetoothOn ? scheme.onSurfaceVariant : c),
      ],
      if (measuredFocus) Pill(label: t.factorFocusOn, icon: Icons.check_rounded, color: modeColor(SessionMode.dnd, theme.brightness)),
      if (_unverified) Pill(label: t.factorUnverified, icon: Icons.help_outline_rounded, color: scheme.onSurfaceVariant),
    ];
    return Card(
      color: c.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.factorTitle.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$factorText×',
                    style: theme.textTheme.displayMedium?.copyWith(color: c, fontWeight: FontWeight.w800, height: 1.0)),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(t.factorPerMinute(factorText),
                        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: chips),
            if (_platform.isIOS) ...[
              const SizedBox(height: 8),
              Text(t.factorIosHint, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ] else if (mode == SessionMode.airplane && (_wifiOn || _bluetoothOn)) ...[
              const SizedBox(height: 8),
              Text(t.airplaneRadiosHint, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ],
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
            Pill(label: '${NumberFormat('0.0#', Localizations.localeOf(context).toString()).format(_factor)}×',
                icon: modeIcon(mode), color: modeColor(mode, theme.brightness)),
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
              ButtonSegment(value: SessionMode.vibrate, label: Text(t.modeShortVibrate), icon: Icon(modeIcon(SessionMode.vibrate))),
              ButtonSegment(value: SessionMode.silent, label: Text(t.modeShortSilent), icon: Icon(modeIcon(SessionMode.silent))),
              ButtonSegment(value: SessionMode.airplane, label: Text(t.modeShortAirplane), icon: Icon(modeIcon(SessionMode.airplane))),
            ],
            selected: {_claimed},
            onSelectionChanged: (s) => setState(() => _claimed = s.first),
          ),
          if (_claimed == SessionMode.airplane) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(t.radioWifiOff),
              value: !_claimedWifiOn,
              onChanged: (v) => setState(() => _claimedWifiOn = !v),
            ),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(t.radioBluetoothOff),
              value: !_claimedBtOn,
              onChanged: (v) => setState(() => _claimedBtOn = !v),
            ),
          ],
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
      // Android measures motion (trigger sensor), so an unverified auto
      // session there means "moving". Reboots the service never saw coming,
      // and iOS sessions without Screen Time, are just unverified.
      if (!s.verified)
        (!Platform.isIOS && s.source == SessionSource.auto ? t.flagMoving : t.flagUnverified),
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
