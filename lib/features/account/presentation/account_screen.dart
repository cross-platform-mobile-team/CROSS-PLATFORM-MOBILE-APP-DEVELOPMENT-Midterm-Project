import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ui_components.dart';

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
  final nameFocus = FocusNode(debugLabel: 'account display name');
  final saveProfileFocus = FocusNode(debugLabel: 'save account profile');
  final currentPasswordFocus = FocusNode(
    debugLabel: 'account current password',
  );
  final newPasswordFocus = FocusNode(debugLabel: 'account new password');
  final changePasswordFocus = FocusNode(debugLabel: 'change account password');
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
    nameFocus.dispose();
    saveProfileFocus.dispose();
    currentPasswordFocus.dispose();
    newPasswordFocus.dispose();
    changePasswordFocus.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (!profile.currentState!.validate()) {
      nameFocus.requestFocus();
      return;
    }
    await run(() => widget.api.updateName(name.text.trim()), 'Profile saved.');
  }

  Future<void> changePassword() async {
    if (!passwords.currentState!.validate()) {
      if (current.text.isEmpty) {
        currentPasswordFocus.requestFocus();
      } else {
        newPasswordFocus.requestFocus();
      }
      return;
    }
    await run(
      () => widget.api.changePassword(current.text, next.text),
      'Password changed. Please sign in again.',
    );
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
      currentPasswordFocus.requestFocus();
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
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SurfacePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.manage_accounts_outlined,
                        size: 36,
                        color: AppTheme.accent,
                      ),
                      const SizedBox(height: 12),
                      Semantics(
                        header: true,
                        container: true,
                        child: Text(
                          widget.api.user?.email ?? 'Signed out',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Text(
                        'Login credentials stay in memory. Sign in again after closing or refreshing the app.',
                      ),
                    ],
                  ),
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
                SurfacePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeading(
                        'Profile',
                        icon: Icons.person_outline,
                        subtitle: 'How you appear in your workspace.',
                      ),
                      FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Form(
                          key: profile,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FocusTraversalOrder(
                                order: const NumericFocusOrder(1),
                                child: TextFormField(
                                  key: const Key('profile-name'),
                                  controller: name,
                                  focusNode: nameFocus,
                                  enabled: !busy,
                                  autofillHints: const [AutofillHints.name],
                                  textInputAction: TextInputAction.done,
                                  decoration: const InputDecoration(
                                    labelText: 'Display name',
                                  ),
                                  onFieldSubmitted: (_) => saveProfile(),
                                  validator: (v) =>
                                      v == null ||
                                          v.trim().isEmpty ||
                                          v.trim().length > 80
                                      ? 'Enter 1-80 characters.'
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FocusTraversalOrder(
                                order: const NumericFocusOrder(2),
                                child: FilledButton(
                                  key: const Key('save-profile'),
                                  focusNode: saveProfileFocus,
                                  onPressed: busy ? null : saveProfile,
                                  child: const Text('Save profile'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SurfacePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeading(
                        'Password and security',
                        icon: Icons.lock_outline,
                        subtitle: 'Keep access to your account in your hands.',
                      ),
                      FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: AutofillGroup(
                          child: Form(
                            key: passwords,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FocusTraversalOrder(
                                  order: const NumericFocusOrder(1),
                                  child: TextFormField(
                                    key: const Key('current-password'),
                                    controller: current,
                                    focusNode: currentPasswordFocus,
                                    enabled: !busy,
                                    obscureText: true,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Current password',
                                    ),
                                    onFieldSubmitted: (_) =>
                                        newPasswordFocus.requestFocus(),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Enter your current password.'
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FocusTraversalOrder(
                                  order: const NumericFocusOrder(2),
                                  child: TextFormField(
                                    key: const Key('new-password'),
                                    controller: next,
                                    focusNode: newPasswordFocus,
                                    enabled: !busy,
                                    obscureText: true,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    textInputAction: TextInputAction.done,
                                    decoration: const InputDecoration(
                                      labelText: 'New password',
                                      helperText: '12-128 characters. Changing it signs out all sessions.',
                                    ),
                                    onFieldSubmitted: (_) => changePassword(),
                                    validator: (v) =>
                                        v == null ||
                                            v.length < 12 ||
                                            v.length > 128
                                        ? 'Enter 12-128 characters.'
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FocusTraversalOrder(
                                  order: const NumericFocusOrder(3),
                                  child: OutlinedButton(
                                    key: const Key('change-password'),
                                    focusNode: changePasswordFocus,
                                    onPressed: busy ? null : changePassword,
                                    child: const Text('Change password'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SurfacePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeading(
                        'Active sessions',
                        icon: Icons.devices_outlined,
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
                              child: const Text(
                                'Could not load sessions. Retry',
                              ),
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
                                    leading: const Icon(
                                      Icons.computer_rounded,
                                      color: AppTheme.muted,
                                    ),
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
                            : () =>
                                  run(() => widget.api.logout(), 'Signed out.'),
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
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SurfacePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeading(
                        'Account deletion',
                        icon: Icons.warning_amber_rounded,
                        subtitle: 'Permanently remove this account and its online tasks.',
                      ),
                      TextButton(
                        key: const Key('delete-account'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: busy ? null : delete,
                        child: const Text('Delete my account'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
