import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/settings.dart';
import 'l10n_ext.dart';

/// Email + 6-digit code. The code is in the email next to the magic link, so
/// the mail can be read on any device and the code typed here. The link still
/// works when the mail is opened on the phone itself.
///
/// "Continue without an account" flips [Settings.localOnly]; main.dart then
/// shows the local-only shell.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.settings});
  final Settings settings;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _sent = false;
  bool _busy = false;
  String? _error;

  Future<void> _send() async {
    final t = context.l10n;
    setState(() { _error = null; _busy = true; });
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: _email.text.trim(),
        emailRedirectTo: 'dk.rassta.freetime://login',
      );
      setState(() { _sent = true; _code.clear(); });
    } catch (e) {
      setState(() => _error = t.authError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final t = context.l10n;
    final code = _code.text.trim();
    if (code.length != 6) return;
    setState(() { _error = null; _busy = true; });
    try {
      // Signs in; main.dart's auth stream swaps this screen for the shell.
      await Supabase.instance.client.auth.verifyOTP(
        email: _email.text.trim(),
        token: code,
        type: OtpType.email,
      );
    } catch (e) {
      if (mounted) setState(() => _error = t.codeError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = context.l10n;
    final spinner = const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5));
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120, right: -80,
            child: Container(width: 320, height: 320,
                decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary.withValues(alpha: 0.10))),
          ),
          Positioned(
            top: 120, left: -140,
            child: Container(width: 280, height: 280,
                decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.secondary.withValues(alpha: 0.10))),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.spa_rounded, size: 44, color: scheme.primary),
                      const SizedBox(height: 16),
                      Text(t.appName, style: theme.textTheme.displayLarge?.copyWith(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(t.authSubtitle,
                          style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 40),
                      if (_sent) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Icon(Icons.mark_email_read_rounded, color: scheme.primary),
                                const SizedBox(width: 14),
                                Expanded(child: Text(t.linkSent(_email.text.trim()), style: theme.textTheme.bodyMedium)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _code,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                          autofillHints: const [AutofillHints.oneTimeCode],
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 8, fontWeight: FontWeight.w800),
                          textInputAction: TextInputAction.done,
                          onChanged: (v) { if (v.length == 6) _verify(); },
                          onSubmitted: (_) => _verify(),
                          decoration: InputDecoration(hintText: t.codeHint),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: _busy ? null : _verify,
                          child: _busy ? spinner : Text(t.verifyCode),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _busy ? null : _send,
                          child: Text(t.resendCode),
                        ),
                      ] else ...[
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.go,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(hintText: t.emailHint, prefixIcon: const Icon(Icons.alternate_email_rounded)),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: _busy ? null : _send,
                          child: _busy ? spinner : Text(t.sendLoginLink),
                        ),
                        const SizedBox(height: 12),
                        Text(t.noPasswordHint, textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: scheme.error)),
                      ],
                      const SizedBox(height: 36),
                      OutlinedButton(
                        onPressed: _busy ? null : () => widget.settings.setLocalOnly(true),
                        child: Text(t.continueWithoutAccount),
                      ),
                      const SizedBox(height: 8),
                      Text(t.withoutAccountHint, textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
