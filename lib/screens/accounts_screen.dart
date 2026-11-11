import 'package:flutter/material.dart';
import 'package:efootball_clone_hub/core/services/secure_storage_service.dart';
import 'package:efootball_clone_hub/models/account_model.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<AccountModel> _accounts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await SecureStorageService.getAccounts();
    if (!mounted) return;
    setState(() {
      _accounts = list;
      _loading = false;
    });
  }

  Future<void> _save(List<AccountModel> list) async {
    await SecureStorageService.saveAccounts(list);
    if (!mounted) return;
    setState(() => _accounts = list);
  }

  Future<void> _addAccount() async {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(labelText: 'Konami ID'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    final name = nameCtrl.text.trim();
    final konamiId = idCtrl.text.trim();
    nameCtrl.dispose();
    idCtrl.dispose();

    if (ok != true || name.isEmpty || konamiId.isEmpty) return;

    final account = AccountModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      konamiId: konamiId,
      isActive: _accounts.isEmpty,
      createdAt: DateTime.now(),
    );
    await _save([..._accounts, account]);
  }

  Future<void> _setActive(String id) async {
    await _save(
      _accounts.map((a) => a.copyWith(isActive: a.id == id)).toList(),
    );
  }

  Future<void> _delete(String id) async {
    final remaining = _accounts.where((a) => a.id != id).toList();
    if (remaining.isNotEmpty && !remaining.any((a) => a.isActive)) {
      remaining[0] = remaining[0].copyWith(isActive: true);
    }
    await _save(remaining);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAccount,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? const Center(child: Text('No accounts yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _accounts.length,
                  itemBuilder: (context, i) {
                    final a = _accounts[i];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          a.isActive
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: a.isActive ? Colors.greenAccent : null,
                        ),
                        title: Text(a.name),
                        subtitle: Text(a.konamiId),
                        onTap: () => _setActive(a.id),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(a.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
