import 'package:flutter/material.dart';

import '../../../core/errors/app_failure.dart';

enum AuthMode { login, register, recovery }

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.authenticate,
    required this.recover,
    required this.offline,
  });
  final Future<void> Function(String email, String password, String? name)
  authenticate;
  final Future<void> Function(String email, String code, String password)
  recover;
  final VoidCallback offline;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final recovery = TextEditingController();
  AuthMode mode = AuthMode.login;
  bool busy = false;
  bool visible = false;
  String? error;
  @override
  void dispose() {
    for (final controller in [email, password, name, recovery]) {
      controller.dispose();
    }
    super.dispose();
  }

  void changeMode(AuthMode next) {
    setState(() {
      mode = next;
      error = null;
      password.clear();
      recovery.clear();
      form.currentState?.reset();
    });
  }

  Future<void> submit() async {
    if (busy || !form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (mode == AuthMode.recovery) {
        await widget.recover(
          email.text.trim(),
          recovery.text.trim(),
          password.text,
        );
        if (mounted) changeMode(AuthMode.login);
      } else {
        await widget.authenticate(
          email.text.trim(),
          password.text,
          mode == AuthMode.register ? name.text.trim() : null,
        );
      }
    } catch (failure) {
      if (mounted) {
        setState(() {
          error = failure is AppFailure
              ? failure.message
              : 'Could not complete the request. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('TaskFlow QA Lab')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AutofillGroup(
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(switch (mode) {
                    AuthMode.login => 'Welcome back',
                    AuthMode.register => 'Create your account',
                    AuthMode.recovery => 'Recover your account',
                  }, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Text(
                    mode == AuthMode.recovery
                        ? 'Use the recovery code you saved when registering. No email is sent.'
                        : 'Your online tasks belong to your account. Offline demo data stays on this device.',
                  ),
                  const SizedBox(height: 24),
                  if (mode == AuthMode.register) ...[
                    TextFormField(
                      key: const Key('account-name'),
                      controller: name,
                      enabled: !busy,
                      decoration: const InputDecoration(labelText: 'Name'),
                      autofillHints: const [AutofillHints.name],
                      validator: (v) =>
                          v == null || v.trim().isEmpty || v.trim().length > 80
                          ? 'Enter a name of 1-80 characters.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    key: const Key('account-email'),
                    controller: email,
                    enabled: !busy,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    validator: (v) =>
                        v == null ||
                            v.trim().length > 254 ||
                            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(v.trim())
                        ? 'Enter a valid email.'
                        : null,
                  ),
                  if (mode == AuthMode.recovery) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('account-recovery'),
                      controller: recovery,
                      enabled: !busy,
                      decoration: const InputDecoration(
                        labelText: 'Recovery code',
                      ),
                      autocorrect: false,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter your recovery code.'
                          : null,
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('account-password'),
                    controller: password,
                    enabled: !busy,
                    obscureText: !visible,
                    enableSuggestions: false,
                    autocorrect: false,
                    autofillHints: [
                      mode == AuthMode.login
                          ? AutofillHints.password
                          : AutofillHints.newPassword,
                    ],
                    decoration: InputDecoration(
                      labelText: mode == AuthMode.recovery
                          ? 'New password'
                          : 'Password',
                      helperText: mode == AuthMode.login
                          ? null
                          : '12-128 characters; spaces are preserved.',
                      suffixIcon: IconButton(
                        tooltip: visible ? 'Hide password' : 'Show password',
                        onPressed: busy
                            ? null
                            : () => setState(() {
                                visible = !visible;
                              }),
                        icon: Icon(
                          visible ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    onFieldSubmitted: (_) => submit(),
                    validator: (v) =>
                        v == null ||
                            v.isEmpty ||
                            v.length > 128 ||
                            (mode != AuthMode.login && v.length < 12)
                        ? 'Enter ${mode == AuthMode.login ? 'your password' : '12-128 characters'}.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  if (error != null)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  FilledButton(
                    key: const Key('account-submit'),
                    onPressed: busy ? null : submit,
                    child: Text(
                      busy
                          ? 'Please wait…'
                          : switch (mode) {
                              AuthMode.login => 'Sign in',
                              AuthMode.register => 'Register',
                              AuthMode.recovery => 'Reset password',
                            },
                    ),
                  ),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => changeMode(
                            mode == AuthMode.login
                                ? AuthMode.register
                                : AuthMode.login,
                          ),
                    child: Text(
                      mode == AuthMode.login
                          ? 'Create account'
                          : 'Back to sign in',
                    ),
                  ),
                  if (mode == AuthMode.login)
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => changeMode(AuthMode.recovery),
                      child: const Text('Forgot password?'),
                    ),
                  const Divider(),
                  OutlinedButton(
                    onPressed: busy ? null : widget.offline,
                    child: const Text('Use offline demo'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
