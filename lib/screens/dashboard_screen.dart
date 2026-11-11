import 'package:flutter/material.dart';
import 'package:efootball_clone_hub/core/constants/app_constants.dart';
import 'package:efootball_clone_hub/core/services/secure_storage_service.dart';
import 'package:efootball_clone_hub/models/account_model.dart';
import 'package:efootball_clone_hub/screens/accounts_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AccountModel? _active;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final accounts = await SecureStorageService.getAccounts();
    final active = accounts.where((a) => a.isActive).toList();
    if (!mounted) return;
    setState(() => _active = active.isEmpty ? null : active.first);
  }

  Future<void> _openAccounts() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccountsScreen()),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF2E7D32),
                      child: Icon(Icons.person, size: 35, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _active?.name ?? 'No active account',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _active == null
                                ? 'Add an account to get started'
                                : 'ID: ${_active!.konamiId}',
                            style: const TextStyle(color: Colors.greenAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _openAccounts,
              icon: const Icon(Icons.sports_soccer),
              label: const Text('ACCOUNT MANAGEMENT'),
            ),
          ],
        ),
      ),
    );
  }
}
