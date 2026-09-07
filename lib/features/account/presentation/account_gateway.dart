import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../tasks/data/local_task_repository.dart';
import '../../tasks/data/remote_task_repository.dart';
import '../../tasks/domain/task_repository.dart';
import '../../tasks/presentation/task_screen.dart';
import 'account_screen.dart';
import 'auth_screen.dart';

class AccountGateway extends StatefulWidget {
  const AccountGateway({super.key, required this.api, this.offlineRepository});
  final ApiClient api;
  final TaskRepository? offlineRepository;
  @override
  State<AccountGateway> createState() => _AccountGatewayState();
}

class _AccountGatewayState extends State<AccountGateway> {
  bool offline = false;
  String? accountId;
  RemoteTaskRepository? remote;
  late final TaskRepository local =
      widget.offlineRepository ?? LocalTaskRepository();
  @override
  void initState() {
    super.initState();
    accountId = widget.api.user?.id;
    widget.api.addListener(changed);
  }

  void changed() {
    if (mounted) {
      setState(() {
        if (accountId != widget.api.user?.id) {
          remote = null;
          accountId = widget.api.user?.id;
        }
      });
    }
  }

  @override
  void dispose() {
    widget.api.removeListener(changed);
    super.dispose();
  }

  Future<void> showRecovery(String code) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Save your recovery code'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Store this code privately. It can reset your password and is shown only once. A new recovery code replaces the old one after a reset.',
              ),
              const SizedBox(height: 16),
              SelectableText(code, key: const Key('recovery-code')),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I saved my recovery code'),
          ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    if (offline) {
      return TaskScreen(
        key: const ValueKey('offline'),
        repository: local,
        actions: [
          IconButton(
            tooltip: 'Return to sign in',
            onPressed: () => setState(() {
              offline = false;
            }),
            icon: const Icon(Icons.login),
          ),
        ],
      );
    }
    if (api.user == null) {
      return AuthScreen(
        offline: () => setState(() {
          offline = true;
        }),
        authenticate: (email, password, name) async {
          final code = await api.signIn(
            email: email,
            password: password,
            name: name,
          );
          if (code != null && mounted) await showRecovery(code);
        },
        recover: (email, code, password) async {
          final next = await api.recover(email, code, password);
          if (mounted) await showRecovery(next);
        },
      );
    }
    remote ??= RemoteTaskRepository(api);
    return TaskScreen(
      key: ValueKey(api.user!.id),
      repository: remote!,
      online: true,
      actions: [
        IconButton(
          tooltip: 'Account settings',
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => AccountScreen(api: api)),
          ),
        ),
      ],
    );
  }
}
