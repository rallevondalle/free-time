import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../core/session.dart';

/// The phone is the source of truth. Every session is stored locally the
/// moment the native layer hands it over, and every screen reads locally.
/// Points are per phone. The cloud only gets a copy, when there is network,
/// so friends and the weekly leaderboard can see them (Rasmus, 14/10-2026).
abstract class SessionRepo {
  bool get isOffline;

  /// Store locally. Never touches the network.
  Future<void> enqueue(Iterable<Session> sessions);

  /// [enqueue] + a best-effort [flush].
  Future<void> submit(Iterable<Session> sessions);

  /// Push what the cloud has not seen yet. Bounded by a timeout, never throws.
  Future<void> flush();

  Future<List<Session>> today();
  Future<List<Session>> thisWeek();
  Future<List<Map<String, dynamic>>> leaderboard();
}

/// Local store. Used alone when there is no account (or no Supabase key).
class LocalSessionRepo implements SessionRepo {
  LocalSessionRepo(this.prefs);

  final SharedPreferences prefs;
  static const key = 'local_sessions';

  @override
  bool get isOffline => true;

  @override
  Future<void> enqueue(Iterable<Session> sessions) async {
    final all = _all();
    final known = all.map((s) => s.clientId).toSet();
    for (final s in sessions) {
      if (known.add(s.clientId)) all.add(s);
    }
    await _saveAll(all);
  }

  @override
  Future<void> submit(Iterable<Session> sessions) => enqueue(sessions);

  @override
  Future<void> flush() async {}

  @override
  Future<List<Session>> today() async => since(startOfToday());

  @override
  Future<List<Session>> thisWeek() async => since(startOfWeek());

  /// Sessions that overlap the period: a night that started yesterday still
  /// shows under today (seen 15/10 00:02 — the powered-off session vanished
  /// from "today" at midnight).
  List<Session> since(DateTime start) => _all()
      .where((s) => s.endedAt.isAfter(start))
      .toList()
    ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  @override
  Future<List<Map<String, dynamic>>> leaderboard() async {
    final week = await thisWeek();
    return [
      {
        'username': '__me_offline__',
        'display_name': null,
        'points': week.fold<int>(0, (a, s) => a + (s.points ?? s.estimatedPoints)),
        'minutes': week.fold<int>(0, (a, s) => a + s.duration.inMinutes),
      }
    ];
  }

  List<Session> _all() => _decode(prefs.getString(key));
  Future<void> _saveAll(List<Session> all) => prefs.setString(key, _encode(all));

  /// Replace sessions by clientId (after the server scored them).
  Future<void> update(Iterable<Session> changed) async {
    final byId = {for (final s in changed) s.clientId: s};
    final all = _all().map((s) => byId[s.clientId] ?? s).toList();
    await _saveAll(all);
  }
}

/// Local store + a copy to Supabase. Reads never wait for the network.
class SupabaseSessionRepo extends LocalSessionRepo {
  SupabaseSessionRepo(this._client, SharedPreferences prefs) : super(prefs) {
    _importLegacy();
  }

  final SupabaseClient _client;

  // Pre-14/10 keys: an upload queue and a server cache. Folded into the
  // local store once, so nothing collected earlier is lost.
  static const _legacyQueueKey = 'pending_upload';
  static const _legacyCacheKey = 'sessions_cache';

  @override
  bool get isOffline => false;

  String get _uid => _client.auth.currentUser!.id;

  void _importLegacy() {
    final old = [
      ..._decode(prefs.getString(_legacyCacheKey)).map((s) => s.copyWith(synced: true)),
      ..._decode(prefs.getString(_legacyQueueKey)),
    ];
    if (old.isEmpty) return;
    enqueue(old).then((_) {
      prefs.remove(_legacyQueueKey);
      prefs.remove(_legacyCacheKey);
    });
  }

  @override
  Future<void> submit(Iterable<Session> sessions) async {
    await enqueue(sessions);
    await flush();
  }

  /// Upload everything not yet synced, then take the server's points back.
  /// Airplane mode is the normal case here: bounded, and silent on failure.
  @override
  Future<void> flush() async {
    await _pullOnce();
    final unsynced = _all().where((s) => !s.synced).toList();
    if (unsynced.isEmpty) return;
    try {
      final rows = await _client
          .from('sessions')
          .upsert(
            unsynced.map((s) => s.toRow(_uid)).toList(),
            onConflict: 'user_id,client_id',
            ignoreDuplicates: false,
          )
          .select()
          .timeout(const Duration(seconds: 10));
      final scored = {for (final r in rows) r['client_id'] as String: r['points'] as int?};
      await update(unsynced.map((s) => s.copyWith(synced: true, points: scored[s.clientId] ?? s.points)));
    } catch (_) {
      // Keep them unsynced; next flush retries.
    }
  }

  /// The cloud copy is the backup. Once per account on this phone, take it
  /// back: a reinstall or a new phone otherwise starts at zero even though
  /// everything is on the server (Rasmus reinstalled via Obtainium 15/10).
  /// Local unsynced sessions with the same clientId win; they upload next.
  Future<void> _pullOnce() async {
    final key = 'pulled_$_uid';
    if (prefs.getBool(key) == true) return;
    try {
      final rows = await _client
          .from('sessions')
          .select()
          .eq('user_id', _uid)
          .order('started_at')
          .limit(5000)
          .timeout(const Duration(seconds: 10));
      await enqueue(rows.map((r) => Session.fromRow(r).copyWith(synced: true)));
      await prefs.setBool(key, true);
    } catch (_) {
      // No network: try again on the next flush.
    }
  }

  @override
  Future<List<Map<String, dynamic>>> leaderboard() async {
    final rows = await _client.rpc('friend_leaderboard').timeout(const Duration(seconds: 8));
    return List<Map<String, dynamic>>.from(rows as List);
  }
}

DateTime startOfToday() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime startOfWeek() {
  final t = startOfToday();
  return t.subtract(Duration(days: t.weekday - 1));
}

List<Session> _decode(String? raw) {
  if (raw == null) return [];
  return (jsonDecode(raw) as List)
      .map((e) => Session.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

String _encode(List<Session> q) => jsonEncode(q.map((s) => s.toJson()).toList());
