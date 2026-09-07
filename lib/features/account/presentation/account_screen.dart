import 'package:flutter/material.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, required this.api});
  final ApiClient api;
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final name = TextEditingController(text: widget.api.user?.name);
  final current = TextEditingController();
  final next = TextEditingController();
  final profile = GlobalKey<FormState>();
  final passwords = GlobalKey<FormState>();
  bool busy = false;
  String? error;
  late Future<Map<String, dynamic>> sessions = widget.api.request(
    'GET',
    '/v1/auth/sessions',
  );
  @override
  void dispose() {
    name.dispose();
    current.dispose();
    next.dispose();
    super.dispose();
  }

  Future<void> run(Future<void> Function() action, String success) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(success)));
      if (widget.api.user == null) {
        Navigator.pop(context);
        return;
      }
      current.clear();
      next.clear();
      sessions = widget.api.request('GET', '/v1/auth/sessions');
    } catch (failure) {
      if (!mounted) return;
      if (widget.api.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Signed out locally. Server revocation could not be confirmed.',
            ),
          ),
        );
        Navigator.pop(context);
        return;
      }
      error = failure is AppFailure
          ? failure.message
          : 'Request failed. Please try again.';
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> delete() async {
    if (current.text.isEmpty) {
      setState(() {
        error = 'Enter your current password before deleting your account.';
      });
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account permanently?'),
        content: const Text(
          'All online tasks and sessions for this account will be deleted. This cannot be undone. Offline demo data is not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await run(
        () => widget.api.deleteAccount(current.text),
        'Account deleted.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('Account settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                widget.api.user?.email ?? 'Signed out',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(
                'Login credentials stay in memory. Sign in again after closing or refreshing the app.',
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
              Form(
                key: profile,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      key: const Key('profile-name'),
                      controller: name,
                      enabled: !busy,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty || v.trim().length > 80
                          ? 'Enter 1-80 characters.'
                          : null,
                    ),
                    FilledButton(
                      onPressed: busy
                          ? null
                          : () {
                              if (profile.currentState!.validate()) {
                                run(
                                  () => widget.api.updateName(name.text.trim()),
                                  'Profile saved.',
                                );
                              }
                            },
                      child: const Text('Save profile'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              Form(
                key: passwords,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      key: const Key('current-password'),
                      controller: current,
                      enabled: !busy,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Current password',
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Enter your current password.'
                          : null,
                    ),
                    TextFormField(
                      key: const Key('new-password'),
                      controller: next,
                      enabled: !busy,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'New password',
                        helperText: '12-128 characters. Changing it signs out all sessions.',
                      ),
                      validator: (v) =>
                          v == null || v.length < 12 || v.length > 128
                          ? 'Enter 12-128 characters.'
                          : null,
                    ),
                    OutlinedButton(
                      onPressed: busy
                          ? null
                          : () {
                              if (passwords.currentState!.validate()) {
                                run(
                                  () => widget.api.changePassword(
                                    current.text,
                                    next.text,
                                  ),
                                  'Password changed. Please sign in again.',
                                );
                              }
                            },
                      child: const Text('Change password'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              Text(
                'Active sessions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              FutureBuilder<Map<String, dynamic>>(
                future: sessions,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return TextButton(
                      onPressed: busy
                          ? null
                          : () => setState(() {
                              sessions = widget.api.request(
                                'GET',
                                '/v1/auth/sessions',
                              );
                            }),
                      child: const Text('Could not load sessions. Retry'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator(
                      semanticsLabel: 'Loading sessions',
                    );
                  }
                  return Column(
                    children: (snapshot.data!['sessions'] as List<dynamic>)
                        .map(
                          (s) => ListTile(
                            title: Text(
                              s['current'] == true
                                  ? 'This session'
                                  : 'Another session',
                            ),
                            subtitle: Text(
                              'Started: ${s['createdAt']}\nExpires: ${s['expiresAt']}',
                            ),
                            isThreeLine: true,
                            trailing: s['current'] == true
                                ? null
                                : IconButton(
                                    tooltip: 'Revoke session',
                                    icon: const Icon(Icons.logout),
                                    onPressed: busy
                                        ? null
                                        : () => run(() async {
                                            await widget.api.request(
                                              'DELETE',
                                              '/v1/auth/sessions/${s['id']}',
                                            );
                                          }, 'Session revoked.'),
                                  ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () => run(() => widget.api.logout(), 'Signed out.'),
                child: const Text('Sign out'),
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () => run(
                        () => widget.api.logout(all: true),
                        'All sessions signed out.',
                      ),
                child: const Text('Sign out all sessions'),
              ),
              const Divider(height: 32),
              TextButton(
                onPressed: busy ? null : delete,
                child: const Text('Delete my account'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
