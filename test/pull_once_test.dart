// Live check of SupabaseSessionRepo._pullOnce against the real project:
// a fresh (empty) local store + a signed-in user must end up with the
// server's sessions locally. Needs network and a one-time code, so it is
// skipped unless run with
//
//   flutter test test/pull_once_test.dart \
//     --dart-define-from-file=$HOME/.config/free-time/dart_defines.json \
//     --dart-define=TEST_EMAIL=... --dart-define=TEST_OTP=123456
//
// The OTP comes from GoTrue's admin generate_link (email_otp) or the mail.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:free_time/data/session_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

const _url = String.fromEnvironment('SUPABASE_URL');
const _key = String.fromEnvironment('SUPABASE_KEY');
const _email = String.fromEnvironment('TEST_EMAIL');
const _otp = String.fromEnvironment('TEST_OTP');

void main() {
  test(
    'fresh install pulls the account\'s sessions from the cloud',
    () async {
      HttpOverrides.global = null; // flutter_test blocks HTTP by default
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final client = SupabaseClient(_url, _key);
      final res = await client.auth.verifyOTP(email: _email, token: _otp, type: OtpType.email);
      expect(res.user, isNotNull);

      final repo = SupabaseSessionRepo(client, prefs);
      expect(await repo.today(), isEmpty, reason: 'store starts empty');

      await repo.flush();

      final today = await repo.today();
      final week = await repo.thisWeek();
      // ignore: avoid_print
      print('pulled: today=${today.length} week=${week.length} '
          'todayPoints=${today.fold<int>(0, (a, s) => a + (s.points ?? 0))} '
          'allSynced=${week.every((s) => s.synced)}');
      expect(today, isNotEmpty);
      expect(week.every((s) => s.synced), isTrue);
      expect(prefs.getBool('pulled_${res.user!.id}'), isTrue);

      // Second flush must not hit the network for the pull again.
      await client.auth.signOut();
      await client.dispose();
    },
    skip: _otp.isEmpty ? 'needs TEST_OTP (see header)' : false,
    timeout: const Timeout(Duration(seconds: 60)),
  );
}
