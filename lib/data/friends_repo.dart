import 'package:supabase_flutter/supabase_flutter.dart';

class FriendsRepo {
  FriendsRepo(this._client);
  final SupabaseClient _client;
  String get _uid => _client.auth.currentUser!.id;

  Future<Map<String, dynamic>?> myProfile() async =>
      _client.from('profiles').select().eq('id', _uid).maybeSingle();

  Future<void> createProfile(String username, {String? platform}) =>
      _client.from('profiles').insert({
        'id': _uid,
        'username': username,
        'platform': platform,
      });

  Future<void> sendRequest(String username) async {
    final target = await _client
        .from('profiles')
        .select('id')
        .eq('username', username)
        .maybeSingle();
    if (target == null) throw Exception('Bruger findes ikke');
    await _client.from('friendships').insert({
      'requester_id': _uid,
      'addressee_id': target['id'],
    });
  }

  Future<void> accept(String requesterId) => _client
      .from('friendships')
      .update({'status': 'accepted'})
      .eq('requester_id', requesterId)
      .eq('addressee_id', _uid);

  /// Pending requests addressed to me, with requester profile.
  Future<List<Map<String, dynamic>>> incoming() async {
    final rows = await _client
        .from('friendships')
        .select('requester_id, profiles!friendships_requester_id_fkey(username, display_name)')
        .eq('addressee_id', _uid)
        .eq('status', 'pending');
    return List<Map<String, dynamic>>.from(rows);
  }
}
