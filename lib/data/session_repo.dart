import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../core/session.dart';

abstract class SessionRepo {
  bool get isOffline;
  Future<void> submit(Iterable<Session> sessions);
  Future<void> flush();
  Future<List<Session>> today();
  Future<List<Session>> thisWeek();
  Future<List<Map<String, dynamic>>> leaderboard();
}

/// Uploads sessions to Supabase, with a local retry queue.
class SupabaseSessionRepo implements SessionRepo {
  SupabaseSessionRepo(this._client, this._prefs);

  final SupabaseClient _client;
  final SharedPreferences _prefs;
  static const _queueKey = 'pending_upload';

  @override
  bool get isOffline => false;

  String get _uid => _client.auth.currentUser!.id;

  @override
  Future<void> submit(Iterable<Session> sessions) async {
    final queue = _loadQueue()..addAll(sessions);
    await _saveQueue(queue);
    await flush();
  }

  @override
  Future<void> flush() async {
    final queue = _loadQueue();
    if (queue.isEmpty) return;
    try {
      await _client.from('sessions').upsert(
            queue.map((s) => s.toRow(_uid)).toList(),
            onConflict: 'user_id,client_id',
            ignoreDuplicates: true,
          );
      await _saveQueue([]);
    } catch (_) {
      // Keep the queue; retry on next flush.
    }
  }

  @override
  Future<List<Session>> today() => _since(_startOfToday());

  @override
  Future<List<Session>> thisWeek() => _since(_startOfWeek());

  Future<List<Session>> _since(DateTime start) async {
    final rows = await _client
        .from('sessions')
        .select()
        .eq('user_id', _uid)
        .gte('started_at', start.toUtc().toIso8601String())
        .order('started_at', ascending: false);
    return rows.map(Session.fromRow).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> leaderboard() async {
    final rows = await _client.rpc('friend_leaderboard');
    return List<Map<String, dynamic>>.from(rows as List);
  }

  List<Session> _loadQueue() => _decode(_prefs.getString(_queueKey));

  Future<void> _saveQueue(List<Session> q) =>
      _prefs.setString(_queueKey, _encode(q));
}

/// Offline mode: everything stays on the device. Used when the app is built
/// without a Supabase key, so the measurement layer can be tested alone.
class LocalSessionRepo implements SessionRepo {
  LocalSessionRepo(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'local_sessions';

  @override
  bool get isOffline => true;

  @override
  Future<void> submit(Iterable<Session> sessions) async {
    final all = _all();
    final known = all.map((s) => s.clientId).toSet();
    for (final s in sessions) {
      if (known.add(s.clientId)) all.add(s);
    }
    await _prefs.setString(_key, _encode(all));
  }

  @override
  Future<void> flush() async {}

  @override
  Future<List<Session>> today() async => _since(_startOfToday());

  @override
  Future<List<Session>> thisWeek() async => _since(_startOfWeek());

  List<Session> _since(DateTime start) => _all()
      .where((s) => s.startedAt.isAfter(start))
      .toList()
    ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  @override
  Future<List<Map<String, dynamic>>> leaderboard() async {
    final week = await thisWeek();
    return [
      {
        'username': 'dig (offline)',
        'display_name': null,
        'points': week.fold<int>(0, (a, s) => a + s.estimatedPoints),
        'minutes': week.fold<int>(0, (a, s) => a + s.duration.inMinutes),
      }
    ];
  }

  List<Session> _all() => _decode(_prefs.getString(_key));
}

DateTime _startOfToday() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime _startOfWeek() {
  final t = _startOfToday();
  return t.subtract(Duration(days: t.weekday - 1));
}

List<Session> _decode(String? raw) {
  if (raw == null) return [];
  return (jsonDecode(raw) as List)
      .map((e) => Session.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

String _encode(List<Session> q) => jsonEncode(q.map((s) => s.toJson()).toList());
