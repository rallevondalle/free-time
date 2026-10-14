import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'l10n_ext.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  bool _sent = false;
  bool _busy = false;
  bool _error = false;

  Future<void> _send() async {
    setState(() { _error = false; _busy = true; });
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: _email.text.trim(),
        emailRedirectTo: 'co.componental.freetime://login',
      );
      setState(() => _sent = true);
    } catch (e) {
      setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = context.l10n;
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
                      if (_sent)
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
                        )
                      else ...[
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(hintText: t.emailHint, prefixIcon: const Icon(Icons.alternate_email_rounded)),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: _busy ? null : _send,
                          child: _busy
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                              : Text(t.sendLoginLink),
                        ),
                        const SizedBox(height: 12),
                        Text(t.noPasswordHint, textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                      if (_error) ...[
                        const SizedBox(height: 16),
                        Text(t.authError, style: TextStyle(color: scheme.error)),
                      ],
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
