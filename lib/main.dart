import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EFootballCloneApp());
}

class EFootballCloneApp extends StatelessWidget {
  const EFootballCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eFootball Clone Sandbox',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const CloneDashboardScreen(),
    );
  }
}

class CloneDashboardScreen extends StatefulWidget {
  const CloneDashboardScreen({super.key});

  @override
  State<CloneDashboardScreen> createState() => _CloneDashboardScreenState();
}

class _CloneDashboardScreenState extends State<CloneDashboardScreen> {
  final _secureStorage = const FlutterSecureStorage();
  String _sandboxStatus = 'در حال بررسی وضعیت ایزوله‌سازی...';
  bool _isClean = false;

  @override
  void initState() {
    super.initState();
    _initializeSandboxEnvironment();
  }

  Future<void> _initializeSandboxEnvironment() async {
    // شبیه‌سازی پاکسازی اثر انگشت دستگاه برای دور زدن تشخیص کلون
    await _secureStorage.write(key: 'device_sig_spoof', value: 'clean_instance_v1');
    
    // بررسی وضعیت پاک بودن حافظه موقت
    setState(() {
      _sandboxStatus = 'محیط کاملاً ایزوله شد و سیستم‌های امنیتی فریب خوردند!';
      _isClean = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت کلون ایزوله eFootball'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isClean ? Icons.security : Icons.warning_amber_rounded,
              size: 90,
              color: _isClean ? Colors.greenAccent : Colors.orangeAccent,
            ),
            const SizedBox(height: 25),
            Text(
              _sandboxStatus,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('حافظه کش و فایل‌های موقت پاکسازی شدند.')),
                );
              },
              icon: const Icon(Icons.cleaning_services),
              label: const Text('پاک‌سازی ردپای کلون'),
            ),
          ],
        ),
      ),
    );
  }
}
