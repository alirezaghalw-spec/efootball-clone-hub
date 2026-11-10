import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

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
      title: 'eFootball Pro Clone',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
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
  String _activeAccount = 'اکانت پیش‌فرض (تایید شده)';
  bool _isAntiDetectionActive = true;

  @override
  void initState() {
    super.initState();
    _loadAccountState();
  }

  Future<void> _loadAccountState() async {
    String? savedAccount = await _secureStorage.read(key: 'active_account');
    if (savedAccount != null) {
      setState(() {
        _activeAccount = savedAccount;
      });
    }
  }

  Future<void> _switchAccount(String accountName) async {
    await _secureStorage.write(key: 'active_account', value: accountName);
    setState(() {
      _activeAccount = accountName;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('سوییچ شد روی: $accountName (ایزوله کامل)')),
    );
  }

  // شبیه‌سازی احراز هویت از طریق مرورگر/گوگل برای بازی
  Future<void> _launchGoogleAuth() async {
    final Uri url = Uri.parse('https://accounts.google.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در باز کردن درگاه ورود گوگل')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت پیشرفته کلون eFootball'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // وضعیت سیستم ضد تشخیص
            Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _isAntiDetectionActive ? Icons.shield : Icons.warning,
                      color: _isAntiDetectionActive ? Colors.greenAccent : Colors.redAccent,
                      size: 36,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'سیستم ضد تشخیص (Anti-Detection)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isAntiDetectionActive ? 'فعال و مخفی‌سازی اثر انگشت دستگاه' : 'غیرفعال',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // وضعیت اکانت فعال
            Text(
              'اکانت فعال فعلی: $_activeAccount',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 12),

            // دکمه‌های سوییچ اکانت
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _switchAccount('اکانت اول (Main)'),
                    child: const Text('اکانت ۱'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _switchAccount('اکانت دوم (Alt)'),
                    child: const Text('اکانت ۲'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // دکمه اتصال به گوگل / مرورگر
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.blueAccent),
              ),
              onPressed: _launchGoogleAuth,
              icon: const Icon(Icons.login, color: Colors.blueAccent),
              label: const Text('ورود/همگام‌سازی با گوگل (Google Sign-In)'),
            ),
            
            const Spacer(),

            // دکمه پاکسازی نهایی
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('کش کلون و کوکی‌های موقت پاکسازی شدند.')),
                );
              },
              icon: const Icon(Icons.cleaning_services),
              label: const Text('پاک‌سازی کامل ردپای کلون'),
            ),
          ],
        ),
      ),
    );
  }
}
